import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import '../model/userModel.dart';
import 'authRepository.dart';
import 'authState.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  Timer? _tokenRefreshTimer;

  AuthNotifier(this._authRepository) : super(AuthState.initial()) {
    checkInitialAuth();
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> checkInitialAuth() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userData = await _authRepository.getCurrentUser();
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        state = state.copyWith(user: user, isLoading: false);
        _startTokenRefreshTimer();
      } else {
        state = state.copyWith(user: null, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Oturum kontrolünde hata: ${e.toString()}",
      );
    }
  }

  // --- Login ---
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      print("DEBUG: Login işlemi başlatılıyor...");
      final result = await _authRepository.login(
        username: username,
        password: password,
      );
      if (result != null) {
        final user = UserModel.fromJson(result);
        state = state.copyWith(user: user, isLoading: false);
        _startTokenRefreshTimer();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Kullanıcı adı veya şifre hatalı!",
        );
        return false;
      }
    } catch (e) {
      print("DEBUG: Hata yakalandı: $e");
      state = state.copyWith(
        isLoading: false,
        error: "Giriş hatası: ${e.toString()}",
      );
      return false;
    }
  }

  // --- Logout ---
  Future<void> logout() async {
    _tokenRefreshTimer?.cancel();
    await _authRepository.logout();
    state = AuthState.initial().copyWith(isLoading: false, user: null);
  }

  // --- Token Yenileme---
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();

    _tokenRefreshTimer = Timer.periodic(
      const Duration(minutes: 30),
      (timer) => _autoRefreshToken(),
    );
  }

  Future<void> _autoRefreshToken() async {
    if (state.isRefreshingToken) return;
    state = state.copyWith(isRefreshingToken: true, error: null);
    try {
      final success = await _authRepository.refreshToken();
      if (success) {
        final userData = await _authRepository.getCurrentUser();
        if (userData != null) {
          final user = UserModel.fromJson(userData);
          state = state.copyWith(user: user);
        }
      }
    } catch (e) {
      state = state.copyWith(error: "Token yenileme hatası: ${e.toString()}");
      await logout();
    } finally {
      state = state.copyWith(isRefreshingToken: false);
    }
  }
}
