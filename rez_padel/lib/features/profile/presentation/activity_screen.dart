import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Activity screen - Shows user's booking history log
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsTab(),
                _buildTournamentsTab(),
                _buildTrainingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.hotPink,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Vaša aktivnost',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.hotPink,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Mečevi'),
          Tab(text: 'Turniri'),
          Tab(text: 'Treninzi'),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    // Mock booking data - log of all court bookings
    final bookings = [
      {
        'date': '18. Jan 2024',
        'time': '17:00',
        'court': 'Teren 1',
        'duration': 90,
        'price': 3500,
        'status': 'upcoming',
        'paymentMethod': 'Kartica',
      },
      {
        'date': '15. Jan 2024',
        'time': '18:00',
        'court': 'Teren 1',
        'duration': 60,
        'price': 2500,
        'status': 'completed',
        'paymentMethod': 'Gotovina',
      },
      {
        'date': '12. Jan 2024',
        'time': '20:00',
        'court': 'Teren 3',
        'duration': 90,
        'price': 3500,
        'status': 'completed',
        'paymentMethod': 'Kartica',
      },
      {
        'date': '10. Jan 2024',
        'time': '19:00',
        'court': 'Teren 2',
        'duration': 120,
        'price': 4500,
        'status': 'completed',
        'paymentMethod': 'Kartica',
      },
      {
        'date': '8. Jan 2024',
        'time': '16:00',
        'court': 'Teren 4',
        'duration': 60,
        'price': 2500,
        'status': 'completed',
        'paymentMethod': 'Gotovina',
      },
      {
        'date': '5. Jan 2024',
        'time': '18:30',
        'court': 'Teren 1',
        'duration': 90,
        'price': 3500,
        'status': 'completed',
        'paymentMethod': 'Kartica',
      },
    ];

    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today,
        title: 'Nema rezervacija',
        subtitle: 'Vaše rezervacije će se pojaviti ovde',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildTrainingsTab() {
    // Mock training/class booking data
    final trainings = [
      {
        'date': '20. Jan 2024',
        'time': '10:00',
        'title': 'Osnovni kurs padel tenisa',
        'instructor': 'Miloš Popović',
        'duration': 60,
        'price': 3000,
        'status': 'upcoming',
        'paymentMethod': 'Kartica',
      },
      {
        'date': '13. Jan 2024',
        'time': '10:00',
        'title': 'Osnovni kurs padel tenisa',
        'instructor': 'Miloš Popović',
        'duration': 60,
        'price': 3000,
        'status': 'completed',
        'paymentMethod': 'Gotovina',
      },
      {
        'date': '6. Jan 2024',
        'time': '10:00',
        'title': 'Osnovni kurs padel tenisa',
        'instructor': 'Miloš Popović',
        'duration': 60,
        'price': 3000,
        'status': 'completed',
        'paymentMethod': 'Kartica',
      },
    ];

    if (trainings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.school,
        title: 'Nema treninga',
        subtitle: 'Vaši rezervisani treninzi će se pojaviti ovde',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: trainings.length,
      itemBuilder: (context, index) {
        final training = trainings[index];
        return _buildTrainingCard(training);
      },
    );
  }

  Widget _buildTournamentsTab() {
    // Mock tournament booking data
    final tournaments = [
      {
        'date': '25. Jan 2024',
        'time': '10:00',
        'title': 'PadelSpace Turnir - Januar 2024',
        'type': 'Singl',
        'price': 5000,
        'status': 'registered',
        'paymentMethod': 'Kartica',
      },
      {
        'date': '15. Feb 2024',
        'time': '09:00',
        'title': 'Zimski Kup 2024',
        'type': 'Dupli',
        'price': 8000,
        'status': 'registered',
        'paymentMethod': 'Kartica',
      },
    ];

    if (tournaments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events,
        title: 'Nema turnira',
        subtitle: 'Vaše prijavljene turnire će se pojaviti ovde',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return _buildTournamentCard(tournament);
      },
    );
  }


  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final isCompleted = booking['status'] == 'completed';
    final isUpcoming = booking['status'] == 'upcoming';
    final duration = booking['duration'] as int;
    final price = booking['price'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardNavyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking['date'],
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking['time'],
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : isUpcoming
                          ? AppColors.hotPink.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCompleted
                      ? 'Završeno'
                      : isUpcoming
                          ? 'Nadolazeći'
                          : 'Otkazano',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? Colors.green.shade300
                        : isUpcoming
                            ? AppColors.hotPink
                            : Colors.red.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.sports_tennis,
                size: 20,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                booking['court'],
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$duration min',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.payment,
                    size: 16,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$price RSD',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardNavy,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking['paymentMethod'],
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(Map<String, dynamic> training) {
    final isCompleted = training['status'] == 'completed';
    final isUpcoming = training['status'] == 'upcoming';
    final duration = training['duration'] as int;
    final price = training['price'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardNavyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    training['date'],
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    training['time'],
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : isUpcoming
                          ? AppColors.hotPink.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCompleted
                      ? 'Završeno'
                      : isUpcoming
                          ? 'Nadolazeći'
                          : 'Otkazano',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? Colors.green.shade300
                        : isUpcoming
                            ? AppColors.hotPink
                            : Colors.red.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            training['title'],
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white60,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Instruktor: ${training['instructor']}',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.white60,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$duration min',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$price RSD',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardNavy,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      training['paymentMethod'],
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentCard(Map<String, dynamic> tournament) {
    final price = tournament['price'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardNavyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.hotPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                size: 24,
                color: AppColors.hotPink,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tournament['title'],
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.white60,
              ),
              const SizedBox(width: 8),
              Text(
                tournament['date'],
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.white60,
              ),
              const SizedBox(width: 8),
              Text(
                tournament['time'],
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.hotPink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tournament['type'],
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hotPink,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    '$price RSD',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Prijavljeno',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardNavy,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tournament['paymentMethod'],
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.white30,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

