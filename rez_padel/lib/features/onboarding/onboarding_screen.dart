import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../auth/presentation/auth_screen.dart';

/// Onboarding screen with logo intro and 3 capability pages
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String onboardingCompleteKey = 'onboarding_complete';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showIntro = true;

  // Total capability pages: 3
  static const int _totalCapabilityPages = 3;

  final List<_OnboardingPageData> _pages = [
    // Page 0: Book courts
    _OnboardingPageData(
      title: 'Rezerviši terene',
      description:
          'Brzo i lako pronađi slobodan termin i rezerviši svoj teren za padel.',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    // Page 1: Schedule lessons
    _OnboardingPageData(
      title: 'Zakaži treninge',
      description:
          'Unapredi svoju igru sa profesionalnim trenerima. Zakaži individualne ili grupne treninge.',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    // Page 2: Compete in tournaments
    _OnboardingPageData(
      title: 'Takmič se na turnirima',
      description: 'Prijavi se na turnire, prati rezultate i osvoji nagrade!',
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_showIntro) {
      setState(() {
        _showIntro = false;
        _currentPage = 0;
      });
      // Wait for PageView to attach before jumping to page 0
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
      return;
    }

    if (_currentPage < _totalCapabilityPages - 1) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.onboardingCompleteKey, true);

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator (only show on capability pages)
            if (!_showIntro)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _ProgressIndicator(
                  currentPage: _currentPage,
                  totalPages: _totalCapabilityPages,
                ),
              )
            else
              const SizedBox(height: 56), // Placeholder space when on intro
            // Page content
            Expanded(
              child: _showIntro
                  ? _IntroPage(onStart: _nextPage)
                  : PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _totalCapabilityPages,
                      itemBuilder: (context, index) {
                        final pageData = _pages[index];
                        return _CapabilityPage(data: pageData);
                      },
                    ),
            ),

            // Bottom CTA (only for capability pages)
            if (!_showIntro)
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.hotPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == _totalCapabilityPages - 1
                          ? 'Započni'
                          : 'Dalje',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 80), // Space for intro page
          ],
        ),
      ),
    );
  }
}

/// Progress indicator with animated segments
class _ProgressIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _ProgressIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalPages, (index) {
        final isActive = index <= currentPage;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: EdgeInsets.only(right: index < totalPages - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.hotPink : Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

/// Intro page with logo and "Kreni" button
class _IntroPage extends StatelessWidget {
  final VoidCallback onStart;

  const _IntroPage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Logo
          Image.asset(
            'assets/icon/padelspace_logo_nobg.png',
            width: 240,
            height: 240,
            fit: BoxFit.contain,
          ),
          const Spacer(flex: 2),
          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.hotPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kreni',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

/// Capability page with illustration, title, and description
class _CapabilityPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _CapabilityPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Illustration
          Expanded(
            flex: 5,
            child: Center(
              child: OverflowBox(
                maxWidth: screenWidth * 2.0,
                child: SizedBox(
                  width: screenWidth * 1.8,
                  child: Image.asset(data.imagePath, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

/// Data model for onboarding pages
class _OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
