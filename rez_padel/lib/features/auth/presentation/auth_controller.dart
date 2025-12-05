import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, UserModel?>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<UserModel?> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  FutureOr<UserModel?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    
    // Set up auth state listener only once
    _authSubscription ??= repository.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || 
          event == AuthChangeEvent.tokenRefreshed) {
        // Only refresh if we're not already loading
        if (!state.isLoading) {
          ref.invalidateSelf();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AsyncValue.data(null);
      }
    });
    
    ref.onDispose(() {
      _authSubscription?.cancel();
      _authSubscription = null;
    });
    
    return await repository.getCurrentUser();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password);
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      return user;
    });
    // Don't call ref.invalidateSelf() here - the listener will handle it
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUpWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      return user;
    });
    // Don't call ref.invalidateSelf() here - the listener will handle it
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return null;
    });
    // Don't call ref.invalidateSelf() here - the listener will handle it
  }
}