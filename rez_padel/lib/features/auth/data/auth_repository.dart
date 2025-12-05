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

  Future<void> resendEmailConfirmation(String email) async {
    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('📍 AuthRepository: No current user');
      return null;
    }

    print('📍 AuthRepository: Found auth user ${user.id}, fetching profile...');

    try {
      // Try fetching profile with timeout and retry logic
      final profile = await _fetchProfileWithRetry(user.id, maxAttempts: 3);
      
      if (profile == null) {
        print('⚠️ AuthRepository: Profile not found after retries');
        return null;
      }

      print('✅ AuthRepository: Profile fetched successfully');
      return UserModel.fromSupabase(user, profile);
    } catch (e) {
      print('❌ AuthRepository: Error fetching profile - $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchProfileWithRetry(
    String userId, {
    int maxAttempts = 3,
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        print('📍 Attempt $attempt/$maxAttempts to fetch profile...');
        
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle() // Use maybeSingle instead of single to avoid exception on empty result
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                print('⏰ Profile fetch timeout on attempt $attempt');
                return null;
              },
            );

        if (response != null) {
          return response as Map<String, dynamic>;
        }

        // If profile doesn't exist yet, wait before retrying
        if (attempt < maxAttempts) {
          print('⏳ Profile not found, waiting before retry...');
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      } catch (e) {
        print('❌ Error on attempt $attempt: $e');
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        } else {
          rethrow;
        }
      }
    }

    return null;
  }
}