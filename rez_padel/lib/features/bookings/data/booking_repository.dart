import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';
import '../domain/court_model.dart';
import '../domain/pricing_model.dart';
import '../domain/center_settings_model.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.read(supabaseClientProvider));
});

class BookingRepository {
  final SupabaseClient _supabase;

  BookingRepository(this._supabase);

  /// Fetch all active courts from the database
  Future<List<CourtModel>> getActiveCourts() async {
    try {
      final response = await _supabase
          .from('courts')
          .select()
          .eq('status', 'active')
          .order('display_order', ascending: true);

      return (response as List<dynamic>)
          .map((json) => CourtModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Greška pri učitavanju terena: $e');
    }
  }

  /// Fetch all active pricing rules from the database
  Future<List<PricingModel>> getActivePricingRules() async {
    try {
      final response = await _supabase
          .from('pricing')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return (response as List<dynamic>)
          .map((json) => PricingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Greška pri učitavanju cenovnika: $e');
    }
  }

  /// Fetch center settings from the database (single row)
  Future<CenterSettingsModel?> getCenterSettings() async {
    try {
      final response = await _supabase
          .from('center_settings')
          .select()
          .single();

      return CenterSettingsModel.fromJson(response);
    } catch (e) {
      // If settings don't exist, return null (will use defaults)
      throw Exception('Greška pri učitavanju podešavanja centra: $e');
    }
  }
}

