import 'package:flutter/material.dart';

/// Brand colors for Rez Padel - PadelSpace theme
/// Cosmic/space theme with energetic, playful aesthetic
class AppColors {
  // Primary Brand Colors
  static const Color hotPink = Color(0xFFFF0099);
  static const Color deepNavy = Color(0xFF1a2332);

  // Accent Colors
  static const Color limeGreen = Color(0xFF00FF66); // For decorative elements
  static const Color brightBlue = Color(0xFF3366FF); // For badges/accents

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Semantic Colors
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF1744);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Background & Surface Colors
  static const Color backgroundDark = deepNavy;
  static const Color surfaceDark = Color(0xFF252d3d);

  // Card Colors (navy shades that stand out from background)
  static const Color cardNavy = Color(
    0xFF2a3547,
  ); // Lighter navy for hero cards
  static const Color cardNavyLight = Color(
    0xFF323d52,
  ); // Even lighter for secondary cards

  // Text Colors
  static const Color textPrimary = white;
  static const Color textSecondary = Color(0xFFB0B8C8);
  static const Color textOnPink = white;

  AppColors._(); // Private constructor to prevent instantiation
}
