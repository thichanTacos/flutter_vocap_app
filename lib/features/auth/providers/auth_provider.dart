import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = const AsyncData(null);
      return true; // thành công
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false; // thất bại
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return true; // thành công
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false; // thất bại
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<bool> updateDisplayName(String newName) async {
    try {
      await ref.read(authRepositoryProvider).updateDisplayName(newName);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final authNotifierProvider =
AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);