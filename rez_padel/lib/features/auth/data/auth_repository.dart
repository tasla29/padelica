import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    // Pass user metadata so the DB Trigger can create the profile
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      },
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final profile = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromSupabase(user, profile);
    } catch (e) {
      // If profile doesn't exist yet or fetch fails
      return null;
    }
  }
}
