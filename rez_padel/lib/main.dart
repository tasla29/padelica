import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Wrap app with ProviderScope for Riverpod
  runApp(const ProviderScope(child: RezPadelApp()));
}

/// Main app widget for Rez Padel
/// Booking management app for Padel centers in Serbia
class RezPadelApp extends StatelessWidget {
  const RezPadelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Theme demo - showcasing brand colors and Montserrat typography
      home: const AuthGate(),
    );
  }
}
