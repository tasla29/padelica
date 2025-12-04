import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../profile/presentation/profile_screen.dart';
import 'presentation/booking_controller.dart';
import 'domain/court_model.dart';
import 'domain/center_settings_model.dart';

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

  // Check if a time slot is available (placeholder - will be implemented with booking checks)
  bool _isTimeSlotAvailable(String timeSlot) {
    // TODO: Check against actual bookings in database
    // For now, return true (all slots appear available)
    return true;
  }

  // Get filtered time slots based on toggle
  List<String> get _filteredTimeSlots {
    if (_showAvailableTimesOnly) {
      return _timeSlots.where((slot) => _isTimeSlotAvailable(slot)).toList();
    }
    return _timeSlots;
  }

  // Get filtered courts based on toggle
  List<CourtModel> get _filteredCourts {
    // For now, return all courts (availability checking will be implemented later)
    return _courts;
  }

  // Calculate price based on duration and base price per hour
  // Note: This is a placeholder - actual pricing will use PricingModel
  int _calculatePrice(int basePricePerHour, int durationMinutes) {
    return (basePricePerHour * (durationMinutes / 60)).round();
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
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showBookingConfirmationModal(BuildContext context, CourtModel court) {
    // Calculate price - use selected duration or default to 60min
    final duration = _selectedDurationIndex != null 
        ? _durations[_selectedDurationIndex!] 
        : 60; // Default to 60 minutes
    // TODO: Use PricingModel to calculate actual price based on date, time, duration
    // For now, use placeholder calculation
    final basePricePerHour = 2000; // Placeholder
    final price = _calculatePrice(basePricePerHour, duration);
    
    final selectedDate = _dates[_selectedDateIndex];
    final formattedDate = '${selectedDate.day}. ${_getMonthName(selectedDate)} ${selectedDate.year}';
    final selectedTime = _selectedTimeIndex != null ? _timeSlots[_selectedTimeIndex!] : '';

    showModalBottomSheet(
      context: context,
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
        formatPrice: _formatPrice,
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
        backgroundColor: AppColors.hotPink,
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
                  });
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
    final slotsToShow = _showAvailableTimesOnly ? _filteredTimeSlots : _timeSlots;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
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
                  },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.hotPink 
                    : (isUnavailable ? AppColors.cardNavyLight.withOpacity(0.5) : AppColors.cardNavyLight),
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: AppColors.hotPink, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  timeSlot,
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
            ),
          );
        },
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

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDurationIndex = index;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.hotPink : AppColors.cardNavyLight,
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
                    color: isSelected ? Colors.white : Colors.white70,
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
                                    // Reset selection if selected court becomes hidden
                    if (value && _selectedCourtIndex != null) {
                      // TODO: Check actual availability when implemented
                      // For now, keep selection
                    }
                  });
                },
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.hotPink.withOpacity(0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
              // TODO: Check actual availability when booking checks are implemented
              // Calculate price - use selected duration or default to 60min
              final duration = _selectedDurationIndex != null 
                  ? _durations[_selectedDurationIndex!] 
                  : 60; // Default to 60 minutes
              // TODO: Use PricingModel to calculate actual price
              final basePricePerHour = 2000; // Placeholder
              final price = _calculatePrice(basePricePerHour, duration);
              final durationText = '$duration min';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
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
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardNavyLight,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.hotPink, width: 2)
                          : Border.all(color: Colors.white24, width: 1),
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
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  attributes.join(' | '),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white60,
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
                                  '${_formatPrice(price)} RSD',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  durationText,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
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

class _BookingConfirmationModal extends StatefulWidget {
  final CourtModel court;
  final String formattedDate;
  final String selectedTime;
  final int duration;
  final int price;
  final String Function(int) formatPrice;

  const _BookingConfirmationModal({
    required this.court,
    required this.formattedDate,
    required this.selectedTime,
    required this.duration,
    required this.price,
    required this.formatPrice,
  });

  @override
  State<_BookingConfirmationModal> createState() => _BookingConfirmationModalState();
}

class _BookingConfirmationModalState extends State<_BookingConfirmationModal> {
  String? selectedPaymentMethod; // 'cash' or 'card'
  bool termsAccepted = false;

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
              onPressed: (termsAccepted && selectedPaymentMethod != null) 
                  ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rezervacija uspešna!'),
                          backgroundColor: AppColors.hotPink,
                        ),
                      );
                    }
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
              child: Text(
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
}
