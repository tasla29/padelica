import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_controller.dart';
import 'auth_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool? _hasCompletedOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    // Add a timeout failsafe - if loading takes too long, force a refresh
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final authState = ref.read(authControllerProvider);
        if (authState.isLoading) {
          debugPrint('⚠️ AuthGate: Loading timeout - forcing refresh');
          ref.invalidate(authControllerProvider);
        }
      }
    });
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed =
        prefs.getBool(OnboardingScreen.onboardingCompleteKey) ?? false;
    if (mounted) {
      setState(() {
        _hasCompletedOnboarding = completed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking onboarding status
    if (_hasCompletedOnboarding == null) {
      return _buildLoadingScreen();
    }

    // Show onboarding if not completed
    if (!_hasCompletedOnboarding!) {
      return const OnboardingScreen();
    }

    final authState = ref.watch(authControllerProvider);

    return authState.when(
      data: (user) {
        debugPrint(
          '✅ AuthGate: User state - ${user != null ? "Logged in" : "Logged out"}',
        );
        if (user != null) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
      loading: () {
        debugPrint('⏳ AuthGate: Loading...');
        return _buildLoadingScreen();
      },
      error: (error, stack) {
        debugPrint('❌ AuthGate: Error - $error');
        return Scaffold(
          backgroundColor: AppColors.deepNavy,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Greška pri učitavanju',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(authControllerProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hotPink,
                  ),
                  child: const Text('Pokušaj ponovo'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PADEL SPACE',
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.hotPink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
