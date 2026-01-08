import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/firebase_providers.dart';
import '../models/app_user.dart';
import 'auth_service.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserRole?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<UserRole?> {
  late final AuthService _service;

  @override
  Future<UserRole?> build() async {
    _service = AuthService(
      ref.read(authProvider),
      ref.read(firestoreProvider),
    );
    return null; // initial state (not logged in)
  }

  Future<void> signUp(
      String email, String password, UserRole role) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _service.signUp(
        emailOrPhone: email,
        password: password,
        role: role,
      );
      return role;
    });
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _service.login(
        emailOrPhone: email,
        password: password,
      );
    });
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AsyncData(null);
  }
}
