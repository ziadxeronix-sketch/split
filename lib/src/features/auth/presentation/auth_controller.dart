import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_providers.dart';
import '../../../core/user_bootstrap.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthRepository(auth);
});

final authControllerProvider =
NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmail(
        email: email,
        password: password,
      );

      await ref.read(userBootstrapProvider).ensureUserDoc();
    });
  }

  Future<void> signUp(
      String email,
      String password,
      String displayName,
      ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      await ref.read(userBootstrapProvider).ensureUserDoc();
    });
  }

  Future<void> signOut() {
    return ref.read(authRepositoryProvider).signOut();
  }
}