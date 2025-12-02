import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../bookings/bookings_screen.dart';

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
      const SafeArea(
        child: BookingsScreen(),
      ), // Using existing bookings screen as placeholder
      const SafeArea(child: _PlaceholderScreen(title: 'Profil')),
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
            setState(() => _currentIndex = 2); // Navigate to profile screen
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
                const SizedBox(height: 32),
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
              ),
            ),
            Text(
              '$userFirstName!',
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.hotPink,
              ),
            ),
          ],
        ),
      ],
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking flow - uskoro!'),
            backgroundColor: AppColors.hotPink,
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

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
