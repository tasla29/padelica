import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../bookings/bookings_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/presentation/activity_screen.dart';
import '../../bookings/data/booking_repository.dart';
import '../../bookings/domain/booking_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authControllerProvider);
    final user = userAsync.value;

    final screens = [
      _HomeContent(userFirstName: user?.firstName ?? 'Igrač'),
      const BookingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.hotPink,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_tennis),
                label: 'Rezervacije',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
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
        'Padel Space',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w800, // ExtraBold
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
}

class _HomeContent extends ConsumerWidget {
  final String userFirstName;

  const _HomeContent({required this.userFirstName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.hotPink, // Pink background for the curve effect
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.deepNavy,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref),
                const SizedBox(height: 24),
                // Upcoming Activities Section
                const _UpcomingActivitiesSection(),
                const SizedBox(height: 28),
                // Section Title for Cards
                Text(
                  'Idemo na padel?',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Action Cards Section
                const _ActionCardsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ćao',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            Text(
              '$userFirstName!',
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.hotPink,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Upcoming Activities Section with empty state
final _upcomingBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repo = ref.read(bookingRepositoryProvider);
  final bookings = await repo.getUserBookings(); // includes court name if joined
  final now = DateTime.now();

  DateTime toDateTime(BookingModel b) {
    final date = DateTime.parse(b.bookingDate);
    final parts = b.startTime.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, h, m);
  }

  final upcoming = bookings
      .where((b) => (b.status == 'confirmed' || b.status == 'pending') && toDateTime(b).isAfter(now))
      .toList()
    ..sort((a, b) => toDateTime(a).compareTo(toDateTime(b)));

  return upcoming;
});

class _UpcomingActivitiesSection extends ConsumerWidget {
  const _UpcomingActivitiesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBookings = ref.watch(_upcomingBookingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'Sledeći termin',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        asyncBookings.when(
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
          error: (err, _) => _EmptyStateCard(
            title: 'Greška pri učitavanju',
            subtitle: 'Pokušaj ponovo kasnije',
            icon: Icons.error_outline,
          ),
          data: (bookings) {
            if (bookings.isEmpty) {
              return _EmptyStateCard(
                title: 'Nemaš zakazane termine',
                subtitle: 'Rezerviši termin i pojaviće se ovde',
                icon: Icons.calendar_today_rounded,
              );
            }

            final first = bookings.first;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BookingPreviewCard(
                  booking: first,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ActivityScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Pokaži sve moje termine',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.hotPink,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.hotPink,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardNavyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.5),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingPreviewCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingPreviewCard({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.parse(booking.bookingDate);
    final weekday = [
      'Ponedeljak',
      'Utorak',
      'Sreda',
      'Četvrtak',
      'Petak',
      'Subota',
      'Nedelja'
    ][parsedDate.weekday - 1];
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Maj',
      'Jun',
      'Jul',
      'Avg',
      'Sep',
      'Okt',
      'Nov',
      'Dec'
    ];
    final dateStr =
        '$weekday, ${parsedDate.day.toString().padLeft(2, '0')} ${monthNames[parsedDate.month - 1]} ${parsedDate.year}';
    final timeStr = booking.startTime.substring(0, 5); // HH:mm
    final duration = booking.durationMinutes;
    final court = booking.courtName ?? 'Teren';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardNavyLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                '$timeStr • ${duration}min',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.sports_tennis, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  court,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Action Cards Section - Hero + Two Grid Cards
class _ActionCardsSection extends StatelessWidget {
  const _ActionCardsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero Card - Rezerviši termin
        const _HeroCard(),
        const SizedBox(height: 16),
        // Bottom Grid - Turniri & Treninzi
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Turniri',
                subtitle: 'Takmičenja i eventi',
                imagePath: 'assets/images/illustration_tournaments.png',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Turniri - uskoro!'),
                      backgroundColor: AppColors.hotPink,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionCard(
                title: 'Treninzi',
                subtitle: 'Unapredi svoju igru',
                imagePath: 'assets/images/illustration_training.png',
                imageHeight: 68,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Treninzi - uskoro!'),
                      backgroundColor: AppColors.hotPink,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Hero Card with pink gradient accent
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to BookingsScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BookingsScreen(),
          ),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Base navy color
              Container(
                decoration: const BoxDecoration(color: AppColors.cardNavy),
              ),
              // Subtle pink gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.hotPink.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Illustration on the right (slightly out of frame)
              Positioned(
                right: -45,
                bottom: -30,
                child: Image.asset(
                  'assets/images/illustration_booking.png',
                  height: 160, // Test: half size (was ~160)
                  fit: BoxFit.contain,
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Rezerviši termin',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Izaberi termin i vreme',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action Card for secondary actions (Turniri, Treninzi)
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;
  final double imageHeight;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
    this.imageHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.cardNavyLight,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Illustration on the right
              Positioned(
                right: 0,
                bottom: -10,
                child: Image.asset(
                  imagePath,
                  height: imageHeight,
                  fit: BoxFit.contain,
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white60,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

