import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'auth_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../../core/theme/app_colors.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      data: (user) {
        debugPrint('✅ AuthGate: User state - ${user != null ? "Logged in" : "Logged out"}');
        if (user != null) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
      loading: () {
        debugPrint('⏳ AuthGate: Loading...');
        return const Scaffold(
          backgroundColor: AppColors.deepNavy,
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.hotPink,
            ),
          ),
        );
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
}