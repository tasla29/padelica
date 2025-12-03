import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../profile/presentation/profile_screen.dart';

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

  // Mock courts data
  final List<Map<String, dynamic>> _courts = [
    {
      'name': 'Padel 1',
      'isBooked': false,
      'attributes': ['Zatvoren', 'Dupli'],
      'basePricePerHour': 2000,
    },
    {
      'name': 'Padel 2',
      'isBooked': false,
      'attributes': ['Otvoren', 'Dupli'],
      'basePricePerHour': 2500,
    },
    {
      'name': 'Padel 3',
      'isBooked': false,
      'attributes': ['Zatvoren', 'Dupli'],
      'basePricePerHour': 2000,
    },
    {
      'name': 'Padel 4',
      'isBooked': true, // Mock booked
      'attributes': ['Zatvoren', 'Singl'],
      'basePricePerHour': 1800,
    },
    {
      'name': 'Padel 5',
      'isBooked': true, // Mock booked
      'attributes': ['Otvoren', 'Dupli'],
      'basePricePerHour': 2500,
    },
    {
      'name': 'Padel 6',
      'isBooked': false,
      'attributes': ['Zatvoren', 'Dupli'],
      'basePricePerHour': 2000,
    },
  ];

  // Duration options in minutes
  final List<int> _durations = [60, 90, 120];

  // Generate list of dates (today + 30 days)
  List<DateTime> get _dates {
    final now = DateTime.now();
    return List.generate(30, (index) => now.add(Duration(days: index)));
  }

  // Generate time slots from 09:00 to 22:00 (30 min intervals)
  List<String> get _timeSlots {
    final slots = <String>[];
    for (int hour = 9; hour < 22; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      slots.add('${hour.toString().padLeft(2, '0')}:30');
    }
    slots.add('22:00'); // Last slot
    return slots;
  }

  // Mock data for unavailable time slots (for demonstration)
  final Set<String> _unavailableTimeSlots = {
    '10:00',
    '14:30',
    '18:00',
  };

  // Check if a time slot is available
  bool _isTimeSlotAvailable(String timeSlot) {
    return !_unavailableTimeSlots.contains(timeSlot);
  }

  // Get filtered time slots based on toggle
  List<String> get _filteredTimeSlots {
    if (_showAvailableTimesOnly) {
      return _timeSlots.where((slot) => _isTimeSlotAvailable(slot)).toList();
    }
    return _timeSlots;
  }

  // Get filtered courts based on toggle
  List<Map<String, dynamic>> get _filteredCourts {
    if (_showAvailableOnly) {
      return _courts.where((court) => court['isBooked'] == false).toList();
    }
    return _courts;
  }

  // Calculate price based on duration and base price per hour
  int _calculatePrice(int basePricePerHour, int durationMinutes) {
    return (basePricePerHour * (durationMinutes / 60)).round();
  }

  // Format price with thousand separators (Serbian format)
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showBookingConfirmationModal(BuildContext context, Map<String, dynamic> court) {
    // Calculate price - use selected duration or default to 60min
    final duration = _selectedDurationIndex != null 
        ? _durations[_selectedDurationIndex!] 
        : 60; // Default to 60 minutes
    final basePricePerHour = (court['basePricePerHour'] as int?) ?? 0;
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
                      final selectedCourt = _courts[_selectedCourtIndex!];
                      if (selectedCourt['isBooked'] == true) {
                        _selectedCourtIndex = null;
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
              final courtName = court['name'] as String? ?? '';
              // Find original index by matching court name
              final originalIndex = _courts.indexWhere((c) => c['name'] == courtName);
              final isBooked = court['isBooked'] as bool? ?? false;
              final isSelected = originalIndex >= 0 && originalIndex == _selectedCourtIndex;
              final attributes = (court['attributes'] as List<dynamic>?)?.cast<String>() ?? <String>[];
              final basePricePerHour = (court['basePricePerHour'] as int?) ?? 0;
              
              // Calculate price - use selected duration or default to 60min
              final duration = _selectedDurationIndex != null 
                  ? _durations[_selectedDurationIndex!] 
                  : 60; // Default to 60 minutes
              final price = _calculatePrice(basePricePerHour, duration);
              final durationText = '$duration min';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: isBooked
                      ? null
                      : () {
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
                            _selectedCourtIndex = originalIndex;
                          });
                          
                          // Show confirmation modal
                          _showBookingConfirmationModal(context, _courts[originalIndex]);
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardNavyLight,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.hotPink, width: 2)
                          : Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Stack(
                      children: [
                        Padding(
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
                                      courtName,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isBooked ? Colors.white30 : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      attributes.join(' | '),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isBooked ? Colors.white24 : Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Right side: Price card
                              if (!isBooked)
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
                        // Booked overlay
                        if (isBooked)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Nije dostupno',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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
        ),
      ],
    );
  }

  // Removed _buildBookButton method as it's replaced by modal
  // Widget _buildBookButton() { ... }
}

class _BookingConfirmationModal extends StatefulWidget {
  final Map<String, dynamic> court;
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
                _buildSummaryRow(Icons.sports_baseball, widget.court['name']),
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
