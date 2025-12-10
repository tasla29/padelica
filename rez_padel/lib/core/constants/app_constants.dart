/// App-wide constants for Rez Padel
class AppConstants {
  // App Info
  static const String appName = 'Padel Space';
  static const String appVersion = '1.0.0';

  // Supabase
  static const String supabaseUrl = 'https://rxicnsdrmbeajlxzhxjl.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ4aWNuc2RybWJlYWpseHpoeGpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0NTI3OTEsImV4cCI6MjA4MDAyODc5MX0.qZrj-f-VKkErogQBl9thZ7ky_5-LYQiR3LCC4K1J2Bg';
  // Google Sign-In client IDs
  static const String googleWebClientId =
      '708748381588-qrgnpr9t4smvmee7c5cfvt9m7n8v9epc.apps.googleusercontent.com';
  static const String googleAndroidClientId =
      '708748381588-3gam5ir2qcj0gj315i62ap7l8193f9bt.apps.googleusercontent.com';
  static const String googleIosClientId =
      '708748381588-l056gf0a08874npk77r0liqe9iqvl2na.apps.googleusercontent.com';

  // User Roles
  static const String rolePlayer = 'player';
  static const String roleStaff = 'staff';
  static const String roleAdmin = 'admin';

  // Currency
  static const String currency = 'RSD';
  static const String currencySymbol = 'din';

  // Time Zone
  static const String timeZone = 'Europe/Belgrade';

  AppConstants._(); // Private constructor
}
