import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, UserModel?>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    
    // Listen to auth state changes
    final sub = repository.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.signedOut) {
        ref.invalidateSelf();
      }
    });
    
    ref.onDispose(() {
      sub.cancel();
    });
    
    return await repository.getCurrentUser();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password);
      return await ref.read(authRepositoryProvider).getCurrentUser();
    });
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
      return await ref.read(authRepositoryProvider).getCurrentUser();
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return null;
    });
  }
}

