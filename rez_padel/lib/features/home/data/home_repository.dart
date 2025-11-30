import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';
import '../../bookings/domain/court_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(supabaseClientProvider));
});

class HomeRepository {
  final SupabaseClient _supabase;

  HomeRepository(this._supabase);

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
}

