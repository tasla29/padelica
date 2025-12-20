import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../bookings/data/booking_repository.dart';
import '../../bookings/domain/booking_model.dart';

/// Activity screen - Shows user's booking history log
class ActivityScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const ActivityScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static final _userBookingsProvider = FutureProvider<List<BookingModel>>((
    ref,
  ) async {
    return ref.read(bookingRepositoryProvider).getUserBookings();
  });

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    // Always refresh bookings when entering this screen to pick up new reservations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final _ = ref.refresh(_userBookingsProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(_userBookingsProvider);
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
                _buildBookingsTab(bookingsAsync),
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

  Widget _buildBookingsTab(AsyncValue<List<BookingModel>> bookingsAsync) {
    return bookingsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
      error: (err, _) => _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Greška pri učitavanju',
        subtitle: 'Pokušaj ponovo kasnije',
      ),
      data: (bookings) {
        final now = DateTime.now();
        DateTime toDateTime(BookingModel b) {
          return DateTime.parse('${b.bookingDate} ${b.startTime}');
        }

        final upcoming = bookings.where((b) {
          final dt = toDateTime(b);
          final active = b.status == 'confirmed' || b.status == 'pending';
          return active && dt.isAfter(now);
        }).toList()..sort((a, b) => toDateTime(a).compareTo(toDateTime(b)));

        if (bookings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.calendar_today,
            title: 'Nema rezervacija',
            subtitle: 'Vaše rezervacije će se pojaviti ovde',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Nadolazeći mečevi',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (upcoming.isEmpty)
              _buildEmptyState(
                icon: Icons.calendar_today,
                title: 'Nema nadolazećih mečeva',
                subtitle: 'Kada rezervišeš termin, pojaviće se ovde.',
              )
            else
              ...upcoming.map(_buildBookingCard),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PlayedMatchesScreen(bookings: bookings),
                  ),
                );
              },
              child: Text(
                'Prikaži sve odigrane mečeve',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.hotPink,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrainingsTab() {
    return _buildEmptyState(
      icon: Icons.school,
      title: 'Treninzi - dolaze uskoro!',
      subtitle: 'Uskoro ćeš moći da pratiš svoje treninge i časove ovde.',
    );
  }

  Widget _buildTournamentsTab() {
    return _buildEmptyState(
      icon: Icons.emoji_events,
      title: 'Turniri - dolaze uskoro!',
      subtitle: 'Uskoro ćeš moći da pratiš i prijavljuješ turnire ovde.',
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final now = DateTime.now();
    final dt = DateTime.parse('${booking.bookingDate} ${booking.startTime}');
    final isUpcoming =
        dt.isAfter(now) &&
        (booking.status == 'confirmed' || booking.status == 'pending');
    final isCompleted = !isUpcoming && booking.status == 'completed';
    final duration = booking.durationMinutes;
    final price = booking.totalPrice.toInt();
    final courtName = booking.courtName ?? 'Teren';

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
                  Icon(Icons.calendar_today, size: 16, color: Colors.white60),
                  const SizedBox(width: 8),
                  Text(
                    booking.getFormattedDate(),
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.white60),
                  const SizedBox(width: 8),
                  Text(
                    booking.getFormattedTime(),
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.15)
                      : isUpcoming
                      ? AppColors.cardNavy
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
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? Colors.white
                        : isUpcoming
                        ? Colors.white
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.sports_tennis, size: 20, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                courtName,
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
                  Icon(Icons.timer, size: 16, color: Colors.white60),
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
                  Icon(Icons.payment, size: 16, color: Colors.white60),
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
              Text(
                booking.paymentMethod == 'onsite' ? 'Keš' : 'Kartica',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Note: detailed cards for trainings/turniri removed while placeholders are shown.

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
            Icon(icon, size: 64, color: Colors.white30),
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

class PlayedMatchesScreen extends StatelessWidget {
  final List<BookingModel> bookings;

  const PlayedMatchesScreen({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    DateTime toDateTime(BookingModel b) =>
        DateTime.parse('${b.bookingDate} ${b.startTime}');

    final upcoming = bookings.where((b) {
      final dt = toDateTime(b);
      final active = b.status == 'confirmed' || b.status == 'pending';
      return active && dt.isAfter(now);
    }).toList()..sort((a, b) => toDateTime(a).compareTo(toDateTime(b)));

    final past = bookings.where((b) {
      final dt = toDateTime(b);
      return dt.isBefore(now) && b.status == 'completed';
    }).toList()..sort((a, b) => toDateTime(b).compareTo(toDateTime(a)));

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.hotPink,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mečevi',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Nadolazeći mečevi',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (upcoming.isEmpty)
            _buildInlineEmptyState(
              icon: Icons.calendar_today,
              title: 'Nema nadolazećih mečeva',
              subtitle: 'Kada rezervišeš termin, pojaviće se ovde.',
            )
          else
            ...upcoming.map((b) => _buildCompactCard(b)),
          const SizedBox(height: 24),
          Text(
            'Odigrani mečevi (poslednjih 12 meseci)',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (past.isEmpty)
            _buildInlineEmptyState(
              icon: Icons.history,
              title: 'Nema odigranih mečeva',
              subtitle: 'Kada odigraš meč, pojaviće se ovde.',
            )
          else
            ...past.map((b) => _buildCompactCard(b)),
        ],
      ),
    );
  }

  Widget _buildCompactCard(BookingModel booking) {
    final duration = booking.durationMinutes;
    final price = booking.totalPrice.toInt();
    final courtName = booking.courtName ?? 'Teren';
    final now = DateTime.now();
    final dt = DateTime.parse('${booking.bookingDate} ${booking.startTime}');
    final isUpcoming =
        dt.isAfter(now) &&
        (booking.status == 'confirmed' || booking.status == 'pending');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
                  Icon(Icons.calendar_today, size: 14, color: Colors.white60),
                  const SizedBox(width: 6),
                  Text(
                    booking.getFormattedDate(),
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 14, color: Colors.white60),
                  const SizedBox(width: 6),
                  Text(
                    booking.getFormattedTime(),
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? AppColors.cardNavy
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isUpcoming ? 'Nadolazeći' : 'Odigran',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            courtName,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.timer, size: 14, color: Colors.white60),
              const SizedBox(width: 6),
              Text(
                '$duration min',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.payment, size: 14, color: Colors.white60),
              const SizedBox(width: 6),
              Text(
                '$price RSD',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                booking.paymentMethod == 'onsite' ? 'Kes' : 'Kartica',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardNavyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.white30),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
