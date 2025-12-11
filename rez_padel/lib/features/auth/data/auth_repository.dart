import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
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
      data: {'first_name': firstName, 'last_name': lastName, 'phone': phone},
    );
  }

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await _supabase.auth.signInWithOAuth(OAuthProvider.google);
      return;
    }

    final googleSignIn = GoogleSignIn(
      // clientId (iOS) and serverClientId (web) both provided to ensure tokens
      clientId: AppConstants.googleIosClientId,
      serverClientId: AppConstants.googleWebClientId,
    );
    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw AuthException('Korisnik je otkazao Google prijavu');
    }

    final googleAuth = await googleUser.authentication;

    if (googleAuth.idToken == null) {
      throw AuthException('Google prijava nije vratila token');
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
  }

  Future<void> signInWithFacebook() async {
    await _supabase.auth.signInWithOAuth(OAuthProvider.facebook);
  }

  Future<void> resendEmailConfirmation(String email) async {
    await _supabase.auth.resend(type: OtpType.signup, email: email);
  }

  Future<void> updateEmail(String email) async {
    await _supabase.auth.updateUser(UserAttributes(email: email));
  }

  Future<void> updatePassword(String password) async {
    await _supabase.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    await _supabase
        .from('users')
        .update({
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
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
          return response;
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
