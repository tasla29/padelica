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
                // Date selector section (Fixed at top)
                _buildDateSelector(),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // Time Section Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Izaberi vreme',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Time slots grid
                        _buildTimeSlotGrid(),

                        const SizedBox(height: 32),

                        // Court Section Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Izaberi teren',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Court Grid
                        _buildCourtGrid(),
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
          child: Text(
            'Izaberi datum',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = index == _selectedDateIndex;
              final dayName = _getDayName(date);
              final dayNumber = date.day.toString();

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
                          fontWeight: FontWeight.w500,
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
                color: AppColors.cardNavyLight,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(
                        color: AppColors.brightBlue,
                        width: 2,
                      ) // Blue border for selection
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
                        color: isBooked ? Colors.white30 : Colors.white,
                      ),
                    ),
                  ),
                  // Selection Checkmark
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.brightBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
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
                          'Booked',
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
        _selectedTimeIndex != null && _selectedCourtIndex != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
        height: 56,
        child: ElevatedButton(
          onPressed: hasSelection
              ? () {
                  final selectedDate = _dates[_selectedDateIndex];
                  final selectedTime = _timeSlots[_selectedTimeIndex!];
                  final selectedCourt = _courts[_selectedCourtIndex!]['name'];
                  final formattedDate =
                      '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Rezervacija: $formattedDate u $selectedTime ($selectedCourt) - uskoro!',
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
