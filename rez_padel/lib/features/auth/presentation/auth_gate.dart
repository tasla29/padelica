import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'auth_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../../core/theme/app_colors.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.deepNavy,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.hotPink,
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.deepNavy,
        body: Center(
          child: Text(
            'Greška: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

