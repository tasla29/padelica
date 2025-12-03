import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

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

  // Mock courts data
  final List<Map<String, dynamic>> _courts = [
    {'name': 'A1', 'isBooked': false},
    {'name': 'A2', 'isBooked': false},
    {'name': 'B1', 'isBooked': false},
    {'name': 'B2', 'isBooked': true}, // Mock booked
    {'name': 'C1', 'isBooked': true}, // Mock booked
    {'name': 'C2', 'isBooked': false},
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
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
                                  fontSize: 14,
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Court Grid
                        _buildCourtGrid(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // Book button (Fixed at bottom)
                _buildBookButton(),
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
            // TODO: Navigate to profile
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
                  fontSize: 14,
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
        itemCount: _timeSlots.length,
        itemBuilder: (context, index) {
          final timeSlot = _timeSlots[index];
          final isSelected = index == _selectedTimeIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeIndex = index;
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
                  timeSlot,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
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

  Widget _buildCourtGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        itemCount: _courts.length,
        itemBuilder: (context, index) {
          final court = _courts[index];
          final isBooked = court['isBooked'] as bool;
          final isSelected = index == _selectedCourtIndex;
          final courtName = court['name'] as String;

          return GestureDetector(
            onTap: isBooked
                ? null
                : () {
                    setState(() {
                      _selectedCourtIndex = index;
                    });
                  },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.hotPink : AppColors.cardNavyLight,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: AppColors.hotPink, width: 2)
                    : Border.all(color: Colors.white24, width: 1),
              ),
              child: Stack(
                children: [
                  // Court Name
                  Center(
                    child: Text(
                      courtName,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isBooked ? Colors.white30 : (isSelected ? Colors.white : Colors.white),
                      ),
                    ),
                  ),
                  // Booked Label
                  if (isBooked)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Nije dostupno',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookButton() {
    final hasSelection =
        _selectedTimeIndex != null && _selectedDurationIndex != null && _selectedCourtIndex != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: hasSelection
                ? () {
                    final selectedDate = _dates[_selectedDateIndex];
                    final selectedTime = _timeSlots[_selectedTimeIndex!];
                    final selectedDuration = _durations[_selectedDurationIndex!];
                    final selectedCourt = _courts[_selectedCourtIndex!]['name'];
                    final formattedDate =
                        '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}';

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Rezervacija: $formattedDate u $selectedTime (${selectedDuration}min, $selectedCourt) - uskoro!',
                        ),
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
            elevation: hasSelection ? 4 : 0,
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
    );
  }
}
