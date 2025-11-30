import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Get a reference to the Supabase client
/// Use this throughout the app to access Supabase services
final supabase = Supabase.instance.client;

/// Riverpod provider for Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
