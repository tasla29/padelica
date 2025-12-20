import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../profile/presentation/profile_screen.dart';
import 'presentation/booking_controller.dart';
import 'presentation/booking_success_screen.dart';
import 'domain/court_model.dart';
import 'domain/center_settings_model.dart';
import 'domain/booking_model.dart';
import 'data/booking_repository.dart';

/// Bookings screen - View and manage court bookings
class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  // Selected date index (0 = today)
  int _selectedDateIndex = 0;
  // Selected time slot index
  int? _selectedTimeIndex;
  // Selected duration index (0 = 60min, 1 = 90min, 2 = 120min)
  int? _selectedDurationIndex;
  // Selected court index
  int? _selectedCourtIndex;
  // Toggle for showing only available courts
  bool _showAvailableOnly = true;
  // Toggle for showing only available time slots
  bool _showAvailableTimesOnly = true;
  // Availability cache per day: slot -> available (for duration used when fetched)
  Map<String, bool> _availabilityBySlot = {};
  String? _availabilityDateKey;
  bool _availabilityLoading = false;
  // Cached bookings for the selected date (courtId -> bookings)
  Map<String, List<BookingModel>> _bookingsByCourt = {};
  String? _bookingsDateKey;
  // Per-court availability for the current selection (courtId -> available)
  Map<String, bool> _courtAvailability = {};
  // Key to ensure cache matches current selection (e.g., "2024-12-06|09:00|60")
  String? _courtAvailabilityKey;
  bool _courtAvailabilityLoading = false;

  // Get courts from provider
  List<CourtModel> get _courts {
    final courtsAsync = ref.read(courtsProvider);
    return courtsAsync.value ?? [];
  }

  // Get center settings from provider
  CenterSettingsModel? get _centerSettings {
    final settingsAsync = ref.read(centerSettingsProvider);
    return settingsAsync.value;
  }

  // Generate list of dates based on center settings
  List<DateTime> get _dates {
    final settings = _centerSettings;
    final advanceDays = settings?.advanceBookingDays ?? 30;
    final now = DateTime.now();
    return List.generate(advanceDays, (index) => now.add(Duration(days: index)));
  }

  // Generate time slots based on center settings
  List<String> get _timeSlots {
    final settings = _centerSettings;
    if (settings == null) {
      // Fallback to default if settings not loaded
      final slots = <String>[];
      for (int hour = 9; hour < 22; hour++) {
        slots.add('${hour.toString().padLeft(2, '0')}:00');
        slots.add('${hour.toString().padLeft(2, '0')}:30');
      }
      slots.add('22:00');
      return slots;
    }
    return settings.generateTimeSlots();
  }

  // Get valid durations based on center settings
  List<int> get _durations {
    final settings = _centerSettings;
    if (settings == null) {
      return [60, 90, 120]; // Default fallback
    }
    return settings.getValidDurations();
  }

  // Minimum booking duration (fallback to 60min when settings are not loaded)
  int get _minDuration {
    return _centerSettings?.minBookingDuration ?? 60;
  }

  int? get _selectedDurationMinutes {
    if (_selectedDurationIndex == null) return null;
    return _durations[_selectedDurationIndex!];
  }

  double? _cardPrice;
  bool _isPriceLoading = false;
  String? _priceError;

  int _closingMinutes() {
    final settings = _centerSettings;
    final closing = settings?.closingTime ?? '22:00:00';
    final parts = closing.split(':');
    var hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    // Treat 24:00 as end-of-day
    if (hour == 24) hour = 24;
    return hour * 60 + minute;
  }

  bool _isSlotFitsDuration(String timeSlot, int durationMinutes) {
    final parts = timeSlot.split(':');
    final startHour = int.parse(parts[0]);
    final startMinute = int.parse(parts[1]);
    final startTotal = startHour * 60 + startMinute;
    final endTotal = startTotal + durationMinutes;
    return endTotal <= _closingMinutes();
  }

  bool _isSlotInPast(String timeSlot) {
    // Only check if today is selected
    if (_selectedDateIndex != 0) return false;

    final now = DateTime.now();
    final parts = timeSlot.split(':');
    final slotHour = int.parse(parts[0]);
    final slotMinute = int.parse(parts[1]);

    // Current time + 30 minute buffer
    final bufferTime = now.add(const Duration(minutes: 30));
    final bufferHour = bufferTime.hour;
    final bufferMinute = bufferTime.minute;

    if (slotHour < bufferHour) return true;
    if (slotHour == bufferHour && slotMinute < bufferMinute) return true;

    return false;
  }

  Future<void> _updatePriceForSelection() async {
    if (_selectedTimeIndex == null || _selectedDurationIndex == null) {
      if (_cardPrice != null || _priceError != null) {
        setState(() {
          _cardPrice = null;
          _priceError = null;
        });
      }
      return;
    }

    final selectedDate = _dates[_selectedDateIndex];
    final bookingDate = selectedDate.toIso8601String().split('T')[0];
    final selectedTime = _timeSlots[_selectedTimeIndex!];
    final startTime = '$selectedTime:00';
    final duration = _durations[_selectedDurationIndex!];

    setState(() {
      _isPriceLoading = true;
      _priceError = null;
    });

    try {
      final price = await _calculatePrice(
        bookingDate,
        startTime,
        duration,
      );
      if (!mounted) return;
      setState(() {
        _cardPrice = price;
        _priceError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cardPrice = null;
        _priceError = 'Greška pri izračunavanju cene';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPriceLoading = false;
        });
      }
    }
  }

  bool _isTimeSlotAvailable(String timeSlot) {
    if (_isSlotInPast(timeSlot)) return false;
    
    if (_availabilityDateKey == _currentBookingDateKey && _availabilityBySlot.containsKey(timeSlot)) {
      return _availabilityBySlot[timeSlot] ?? false;
    }
    // Optimistic while loading / not fetched yet
    return true;
  }

  String get _currentBookingDateKey {
    final selectedDate = _dates[_selectedDateIndex];
    return selectedDate.toIso8601String().split('T')[0];
  }

  Future<void> _loadAvailabilityForSelectedDate({int? durationMinutes}) async {
    if (_availabilityLoading) return;

    final settings = _centerSettings;
    final courts = _courts;
    if (settings == null || courts.isEmpty) {
      return;
    }

    final bookingDate = _currentBookingDateKey;
    final durationToUse = durationMinutes ?? (_selectedDurationMinutes ?? _minDuration);

    // Ensure we have bookings for the day; if not, fetch them
    if (_bookingsDateKey != bookingDate) {
      await _loadBookingsForDate();
      if (_bookingsDateKey != bookingDate) {
        // If still not set, abort to avoid bad state
        return;
      }
    }

    setState(() {
      _availabilityLoading = true;
    });

    final availability = _computeAvailabilityForDuration(durationToUse, courts);

    if (!mounted) return;

    setState(() {
      _availabilityBySlot = availability;
      _availabilityDateKey = bookingDate;
      _availabilityLoading = false;
    });
  }

  String _formatTimeWithSeconds(int hour, int minute) {
    final normalizedHour = hour % 24;
    return '${normalizedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
  }

  int _parseMinutes(String hhmmss) {
    final parts = hhmmss.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return h * 60 + m;
  }

  Map<String, bool> _computeAvailabilityForDuration(int durationMinutes, List<CourtModel> courts) {
    final slots = _timeSlots.where((slot) => _isSlotFitsDuration(slot, durationMinutes));
    final availability = <String, bool>{};

    for (final slot in slots) {
      if (_isSlotInPast(slot)) {
        availability[slot] = false;
        continue;
      }
      final parts = slot.split(':');
      final startHour = int.parse(parts[0]);
      final startMinute = int.parse(parts[1]);
      final startTotal = startHour * 60 + startMinute;
      final endTotal = startTotal + durationMinutes;

      bool slotAvailable = false;

      for (final court in courts) {
        final bookings = _bookingsByCourt[court.id] ?? [];
        bool overlaps = false;
        for (final b in bookings) {
          final bStart = _parseMinutes(b.startTime);
          final bEnd = _parseMinutes(b.endTime);
          // overlap if bStart < end && bEnd > start
          if (bStart < endTotal && bEnd > startTotal) {
            overlaps = true;
            break;
          }
        }
        if (!overlaps) {
          slotAvailable = true;
          break;
        }
      }

      availability[slot] = slotAvailable;
    }

    return availability;
  }

  bool _isDurationSelectable(int durationMinutes) {
    if (_selectedTimeIndex == null) return true;
    final timeSlot = _timeSlots[_selectedTimeIndex!];
    return _isSlotFitsDuration(timeSlot, durationMinutes);
  }

  Future<void> _loadBookingsForDate() async {
    final bookingDate = _currentBookingDateKey;
    final repository = ref.read(bookingRepositoryProvider);

    try {
      final allBookings = await repository.getAllBookingsForDate(bookingDate: bookingDate);
      final grouped = <String, List<BookingModel>>{};
      for (final b in allBookings) {
        grouped.putIfAbsent(b.courtId, () => []).add(b);
      }
      // Sort bookings by start time per court for faster checks
      for (final list in grouped.values) {
        list.sort((a, b) => _parseMinutes(a.startTime).compareTo(_parseMinutes(b.startTime)));
      }
      setState(() {
        _bookingsByCourt = grouped;
        _bookingsDateKey = bookingDate;
      });
    } catch (_) {
      // If fetch fails, clear cache so we don't use stale data
      setState(() {
        _bookingsByCourt = {};
        _bookingsDateKey = null;
      });
    }
  }

  String? get _currentSelectionKey {
    if (_selectedTimeIndex == null || _selectedDurationIndex == null) return null;
    final date = _currentBookingDateKey;
    final time = _timeSlots[_selectedTimeIndex!];
    final duration = _durations[_selectedDurationIndex!];
    return '$date|$time|$duration';
  }

  Future<void> _loadCourtAvailabilityForSelection() async {
    if (_courtAvailabilityLoading) return;
    if (!_hasTimeAndDurationSelected) return;

    final courts = _courts;
    if (courts.isEmpty) return;

    final bookingDate = _currentBookingDateKey;
    final selectedTime = _timeSlots[_selectedTimeIndex!];
    final duration = _durations[_selectedDurationIndex!];
    final timeParts = selectedTime.split(':');
    final startHour = int.parse(timeParts[0]);
    final startMinute = int.parse(timeParts[1]);
    final startDateTime = DateTime(2000, 1, 1, startHour, startMinute);
    final endDateTime = startDateTime.add(Duration(minutes: duration));
    final startTime = _formatTimeWithSeconds(startDateTime.hour, startDateTime.minute);
    final endTime = _formatTimeWithSeconds(endDateTime.hour, endDateTime.minute);

    final repository = ref.read(bookingRepositoryProvider);
    final selectionKey = _currentSelectionKey;

    setState(() {
      _courtAvailabilityLoading = true;
      _courtAvailability = {};
    });

    final availability = <String, bool>{};

    for (final court in courts) {
      try {
        final isAvailable = await repository.checkSlotAvailability(
          courtId: court.id,
          bookingDate: bookingDate,
          startTime: startTime,
          endTime: endTime,
        );
        availability[court.id] = isAvailable;
      } catch (_) {
        // If error, keep optimistic availability to avoid blocking UX
        availability[court.id] = true;
      }
    }

    if (!mounted) return;

    setState(() {
      _courtAvailability = availability;
      _courtAvailabilityKey = selectionKey;
      _courtAvailabilityLoading = false;
    });
  }

  void _scheduleCourtAvailabilityLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCourtAvailabilityForSelection());
  }

  // Get filtered time slots based on toggle
  List<String> get _filteredTimeSlots {
    // If duration is selected, use it; otherwise use minimum duration so late slots are hidden
    final durationForFilter = _selectedDurationMinutes ?? _minDuration;
    final baseSlots = _timeSlots.where((slot) {
      return _isSlotFitsDuration(slot, durationForFilter) && !_isSlotInPast(slot);
    });

    // If we have availability for this date, honor it
    if (_availabilityDateKey == _currentBookingDateKey) {
      if (_showAvailableTimesOnly) {
        return baseSlots.where((slot) => _availabilityBySlot[slot] ?? false).toList();
      }
      // Show all duration-valid slots; availability info used for styling
      return baseSlots.toList();
    }

    // No cache yet; conservative: show duration-valid slots only
    return baseSlots.toList();
  }

  // Time slots filtered only by duration/closing, ignoring availability toggle
  List<String> get _durationFilteredTimeSlots {
    final durationForFilter = _selectedDurationMinutes ?? _minDuration;
    return _timeSlots.where((slot) {
      return _isSlotFitsDuration(slot, durationForFilter) && !_isSlotInPast(slot);
    }).toList();
  }

  // Get filtered courts based on toggle
  List<CourtModel> get _filteredCourts {
    if (_showAvailableOnly && _hasTimeAndDurationSelected) {
      if (_courtAvailabilityKey == _currentSelectionKey) {
        return _courts.where((court) => _courtAvailability[court.id] ?? false).toList();
      }
      // Availability not loaded yet for current selection
      return [];
    }
    return _courts;
  }

  bool get _hasTimeAndDurationSelected {
    return _selectedTimeIndex != null && _selectedDurationIndex != null;
  }

  // Get court attributes as list of strings
  List<String> _getCourtAttributes(CourtModel court) {
    final attributes = <String>[];
    if (court.isIndoor) {
      attributes.add('Zatvoren');
    } else {
      attributes.add('Otvoren');
    }
    if (court.isSingle) {
      attributes.add('Singl');
    } else {
      attributes.add('Dupli');
    }
    return attributes;
  }

  // Format price with thousand separators (Serbian format)
  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _getPriceBadgeText() {
    if (_priceError != null) {
      return _priceError!;
    }
    if (_cardPrice != null) {
      return '${_formatPrice(_cardPrice!)} RSD';
    }
    return 'Izaberi vreme';
  }

  Future<double> _calculatePrice(String bookingDate, String startTime, int durationMinutes) {
    final repository = ref.read(bookingRepositoryProvider);
    return repository.calculatePrice(
      bookingDate: bookingDate,
      startTime: startTime,
      durationMinutes: durationMinutes,
    );
  }

  Future<void> _showBookingConfirmationModal(BuildContext context, CourtModel court) async {
    // Ensure we have all required selections
    if (_selectedTimeIndex == null || _selectedDurationIndex == null) {
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final sheetContext = context;

    final duration = _durations[_selectedDurationIndex!];
    final selectedDate = _dates[_selectedDateIndex];
    final bookingDate = selectedDate.toIso8601String().split('T')[0]; // Format: YYYY-MM-DD
    final selectedTime = _timeSlots[_selectedTimeIndex!];

    // Final check for past slots
    if (_isSlotInPast(selectedTime)) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Izabrani termin više nije dostupan.'),
          backgroundColor: AppColors.hotPink,
        ),
      );
      return;
    }

    final startTime = '$selectedTime:00'; // Convert to HH:mm:ss format
    
    // Calculate end time
    final timeParts = selectedTime.split(':');
    final startHour = int.parse(timeParts[0]);
    final startMinute = int.parse(timeParts[1]);
    final startDateTime = DateTime(2000, 1, 1, startHour, startMinute);
    final endDateTime = startDateTime.add(Duration(minutes: duration));
    final endTime = '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}:00';

    // Calculate price using repository
    final price = await _calculatePrice(bookingDate, startTime, duration);
    
    if (price == 0.0) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Greška pri izračunavanju cene. Molimo pokušajte ponovo.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final formattedDate = '${selectedDate.day}. ${_getMonthName(selectedDate)} ${selectedDate.year}';

    if (!mounted) return;

    showModalBottomSheet(
      context: sheetContext,
      isScrollControlled: true,
      backgroundColor: AppColors.deepNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _BookingConfirmationModal(
        court: court,
        formattedDate: formattedDate,
        selectedTime: selectedTime,
        duration: duration,
        price: price,
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
        formatPrice: _formatPrice,
        onBookingCreated: () {
          // Refresh courts to update availability
          ref.invalidate(courtsProvider);
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Watch providers for data
    final courtsAsync = ref.watch(courtsProvider);
    final centerSettingsAsync = ref.watch(centerSettingsProvider);

    // Show loading state if any data is loading
    if (courtsAsync.isLoading || centerSettingsAsync.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.deepNavy,
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // Show error state if any data failed to load
    if (courtsAsync.hasError || centerSettingsAsync.hasError) {
      return Scaffold(
        backgroundColor: AppColors.hotPink,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                courtsAsync.hasError 
                    ? 'Greška pri učitavanju terena: ${courtsAsync.error}'
                    : 'Greška pri učitavanju podešavanja: ${centerSettingsAsync.error}',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(courtsProvider);
                  ref.invalidate(centerSettingsProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hotPink,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Pokušaj ponovo',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Ensure availability is loaded for the current date if not loaded yet
    if (!_availabilityLoading && _availabilityDateKey != _currentBookingDateKey) {
      _loadAvailabilityForSelectedDate(durationMinutes: _selectedDurationMinutes);
    }

    return Scaffold(
      backgroundColor: AppColors.hotPink,
      appBar: _buildAppBar(),
      body: Container(
        color: AppColors.hotPink, // Pink background for the curve effect
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scrollable content (including date selector)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date selector section (now scrollable with rest of content)
                        _buildDateSelector(),

                        const SizedBox(height: 24),
                        // Time Section Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Izaberi vreme',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Toggle switch for available times only
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Prikaži samo dostupna vremena',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                              Switch(
                                value: _showAvailableTimesOnly,
                                onChanged: (value) {
                                  setState(() {
                                    _showAvailableTimesOnly = value;
                                    // Reset time selection if selected time becomes hidden
                                    if (value && _selectedTimeIndex != null) {
                                      final selectedTime = _timeSlots[_selectedTimeIndex!];
                                      if (!_isTimeSlotAvailable(selectedTime)) {
                                        _selectedTimeIndex = null;
                                      }
                                    }
                                  });
                                },
                                activeThumbColor: Colors.white,
                                activeTrackColor: AppColors.hotPink.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Time slots grid
                        _buildTimeSlotGrid(),

                        const SizedBox(height: 32),

                        // Duration Section Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Izaberi trajanje',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Duration Grid
                        _buildDurationGrid(),

                        const SizedBox(height: 32),

                        // Court Section Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sports_baseball,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Izaberi teren',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Court Section with toggle and list
                        _buildCourtSection(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // Book button (Removed fixed bottom button)
                // _buildBookButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.hotPink,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Rezervacije',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Izaberi datum',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = index == _selectedDateIndex;
              final dayName = _getDayName(date);
              final dayNumber = date.day.toString();
              final monthName = _getMonthName(date);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateIndex = index;
                        _selectedTimeIndex = null; // Reset time selection
                        _availabilityBySlot = {};
                        _availabilityDateKey = null;
                        _courtAvailability = {};
                        _courtAvailabilityKey = null;
                  });
                  _updatePriceForSelection();
                  _loadAvailabilityForSelectedDate(durationMinutes: _selectedDurationMinutes);
                  _scheduleCourtAvailabilityLoad();
                },
                child: Container(
                  width: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.hotPink
                        : AppColors.cardNavyLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayNumber,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        monthName,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white70 : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getDayName(DateTime date) {
    // Serbian day names abbreviated
    const days = ['Pon', 'Uto', 'Sre', 'Čet', 'Pet', 'Sub', 'Ned'];
    return days[date.weekday - 1];
  }

  String _getMonthName(DateTime date) {
    // Serbian month names abbreviated
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Maj', 'Jun', 'Jul', 'Avg', 'Sep', 'Okt', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  Widget _buildTimeSlotGrid() {
    // Show filtered slots when toggle is ON, all slots when toggle is OFF
    final slotsToShow = _showAvailableTimesOnly ? _filteredTimeSlots : _durationFilteredTimeSlots;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemCount: slotsToShow.length,
            itemBuilder: (context, index) {
              final timeSlot = slotsToShow[index];
              // Find the original index in _timeSlots
              final originalIndex = _timeSlots.indexOf(timeSlot);
              final isSelected = originalIndex >= 0 && originalIndex == _selectedTimeIndex;
              final isUnavailable = !_isTimeSlotAvailable(timeSlot);

              return GestureDetector(
                onTap: isUnavailable
                    ? null
                    : () {
                      setState(() {
                        _selectedTimeIndex = originalIndex;
                      });
                      // If current duration makes this slot invalid, reset selection
                      final currentDuration = _selectedDurationMinutes ?? _minDuration;
                      if (!_isSlotFitsDuration(timeSlot, currentDuration)) {
                        setState(() {
                          _selectedTimeIndex = null;
                        });
                        return;
                      }
                      _updatePriceForSelection();
                      _scheduleCourtAvailabilityLoad();
                    },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.hotPink
                        : (isUnavailable ? AppColors.cardNavyLight.withOpacity(0.35) : AppColors.cardNavyLight),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: AppColors.hotPink, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            timeSlot,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isUnavailable
                                  ? Colors.white30
                                  : (isSelected ? Colors.white : Colors.white70),
                              decoration: isUnavailable ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.white30,
                            ),
                          ),
                        ),
                        if (isUnavailable)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Nije dostupno',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.white60,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_availabilityLoading || _availabilityDateKey != _currentBookingDateKey)
            Positioned.fill(
              child: Container(
                color: AppColors.deepNavy,
                child: const Center(
                  child: SizedBox(
                    height: 32,
                    width: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDurationGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.0,
        ),
        itemCount: _durations.length,
        itemBuilder: (context, index) {
          final duration = _durations[index];
          final isSelected = index == _selectedDurationIndex;
          final isDurationAvailable = _isDurationSelectable(duration);

          return GestureDetector(
            onTap: isDurationAvailable
                ? () {
                  setState(() {
                    _selectedDurationIndex = index;
                    // If the previously selected time no longer fits this duration, clear it
                    if (_selectedTimeIndex != null) {
                      final timeSlot = _timeSlots[_selectedTimeIndex!];
                      if (!_isSlotFitsDuration(timeSlot, _durations[index])) {
                        _selectedTimeIndex = null;
                      }
                    }
                  });
                    _loadAvailabilityForSelectedDate(durationMinutes: _durations[index]);
                    _updatePriceForSelection();
                    _scheduleCourtAvailabilityLoad();
                  }
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.hotPink
                    : (isDurationAvailable ? AppColors.cardNavyLight : AppColors.cardNavyLight.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: AppColors.hotPink, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '${duration}min',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDurationAvailable
                        ? (isSelected ? Colors.white : Colors.white70)
                        : Colors.white38,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourtSection() {
    if (!_hasTimeAndDurationSelected) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardNavyLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Text(
            'Izaberi datum, vreme i trajanje pre izbora terena',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle switch for available courts only
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prikaži samo dostupne terene',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Switch(
                value: _showAvailableOnly,
                onChanged: (value) {
                  setState(() {
                    _showAvailableOnly = value;
                  });
                },
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.hotPink.withOpacity(0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_showAvailableOnly &&
            _hasTimeAndDurationSelected &&
            _courtAvailabilityKey != _currentSelectionKey) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardNavyLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Učitavam dostupne terene...',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Court list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredCourts.length,
            itemBuilder: (context, index) {
              final court = _filteredCourts[index];
              final isSelected = index == _selectedCourtIndex;
              final attributes = _getCourtAttributes(court);
              // Calculate duration - use selected duration or default to 60min
              final duration = _selectedDurationIndex != null
                  ? _durations[_selectedDurationIndex!]
                  : 60; // Default to 60 minutes
              final durationText = '$duration min';
              final isCourtAvailable = _courtAvailabilityKey == _currentSelectionKey
                  ? (_courtAvailability[court.id] ?? true)
                  : true;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: isCourtAvailable
                      ? () {
                          // Check if time and duration are selected
                          if (_selectedTimeIndex == null || _selectedDurationIndex == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Molimo izaberite vreme i trajanje pre izbora terena'),
                                backgroundColor: AppColors.hotPink,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            _selectedCourtIndex = index;
                          });

                          // Show confirmation modal
                          _showBookingConfirmationModal(context, court);
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCourtAvailable ? AppColors.cardNavyLight : AppColors.cardNavyLight.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.hotPink, width: 2)
                          : Border.all(
                              color: isCourtAvailable ? Colors.white24 : Colors.white24.withOpacity(0.4),
                              width: 1,
                            ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side: Court name and attributes
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  court.name,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isCourtAvailable ? Colors.white : Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  attributes.join(' | '),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isCourtAvailable ? Colors.white60 : Colors.white38,
                                  ),
                                ),
                                if (!isCourtAvailable)
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Nije dostupno',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Right side: Price card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardNavy,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 5,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  durationText,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _isPriceLoading
                                    ? const SizedBox(
                                        height: 12,
                                        width: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        _getPriceBadgeText(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isCourtAvailable ? Colors.white : Colors.white54,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Removed _buildBookButton method as it's replaced by modal
  // Widget _buildBookButton() { ... }
}

class _BookingConfirmationModal extends ConsumerStatefulWidget {
  final CourtModel court;
  final String formattedDate;
  final String selectedTime;
  final int duration;
  final double price;
  final String bookingDate; // Format: "YYYY-MM-DD"
  final String startTime; // Format: "HH:mm:ss"
  final String endTime; // Format: "HH:mm:ss"
  final String Function(double) formatPrice;
  final VoidCallback onBookingCreated;

  const _BookingConfirmationModal({
    required this.court,
    required this.formattedDate,
    required this.selectedTime,
    required this.duration,
    required this.price,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.formatPrice,
    required this.onBookingCreated,
  });

  @override
  ConsumerState<_BookingConfirmationModal> createState() => _BookingConfirmationModalState();
}

class _BookingConfirmationModalState extends ConsumerState<_BookingConfirmationModal> {
  String? selectedPaymentMethod; // 'cash' or 'card'
  bool termsAccepted = false;
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Potvrda rezervacije',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Booking Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardNavyLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSummaryRow(Icons.calendar_today, widget.formattedDate),
                const SizedBox(height: 12),
                _buildSummaryRow(Icons.schedule, '${widget.selectedTime} (${widget.duration} min)'),
                const SizedBox(height: 12),
                _buildSummaryRow(Icons.sports_baseball, widget.court.name),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Total Price
          Center(
            child: Column(
              children: [
                Text(
                  'Ukupna cena',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.formatPrice(widget.price)} RSD',
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.hotPink,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Payment Method Selector
          Text(
            'Način plaćanja',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPaymentOption(
                  title: 'Keš (na terenu)',
                  icon: Icons.money,
                  isSelected: selectedPaymentMethod == 'cash',
                  onTap: () => setState(() => selectedPaymentMethod = 'cash'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentOption(
                  title: 'Kartica',
                  icon: Icons.credit_card,
                  isSelected: selectedPaymentMethod == 'card',
                  onTap: () => setState(() => selectedPaymentMethod = 'card'),
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Terms Checkbox
          GestureDetector(
            onTap: () => setState(() => termsAccepted = !termsAccepted),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: termsAccepted,
                    onChanged: (value) => setState(() => termsAccepted = value ?? false),
                    activeColor: AppColors.hotPink,
                    side: const BorderSide(color: Colors.white70, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Prihvatam uslove korišćenja',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (!_isCreating && termsAccepted && selectedPaymentMethod != null) 
                  ? () => _createBooking()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.hotPink,
                disabledBackgroundColor: AppColors.cardNavyLight,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'REZERVIŠI',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.hotPink : AppColors.cardNavyLight,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: AppColors.hotPink, width: 2)
              : Border.all(color: Colors.white24, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isSelected ? Colors.white : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBooking() async {
    if (!mounted) return;

    setState(() {
      _isCreating = true;
    });

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final repository = ref.read(bookingRepositoryProvider);
      
      // Map payment method
      final paymentMethod = selectedPaymentMethod == 'card' ? 'online' : 'onsite';

      // Create booking
      await repository.createBooking(
        courtId: widget.court.id,
        bookingDate: widget.bookingDate,
        startTime: widget.startTime,
        endTime: widget.endTime,
        durationMinutes: widget.duration,
        paymentMethod: paymentMethod,
        totalPrice: widget.price,
        racketRentalCount: 0, // TODO: Add racket rental selection
        racketRentalPrice: 0.0,
      );

      if (!mounted) return;

      // Close modal
      navigator.pop();

      // Call callback to refresh data
      widget.onBookingCreated();

      // Navigate to success screen
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(
            courtName: widget.court.name,
            formattedDate: widget.formattedDate,
            selectedTime: widget.selectedTime,
            durationMinutes: widget.duration,
            price: widget.price,
            contactPhone: '+381 60 123 4567',
            latitude: 44.834105521834175,
            longitude: 20.359217255455203,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCreating = false;
      });

      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
