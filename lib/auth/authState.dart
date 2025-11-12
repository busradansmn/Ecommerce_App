import '../model/userModel.dart';

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool isRefreshingToken;

  AuthState({
    required this.isLoading,
    this.user,
    this.error,
    required this.isRefreshingToken,
  });

  // Başlangıç durumu
  factory AuthState.initial() => AuthState(
    isLoading: true,
    user: null,
    error: null,
    isRefreshingToken: false,
  );

  // Nullable parametreler için özel kontrol
  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? isRefreshingToken,
    bool clearUser = false,  // User'ı temizlemek için flag
    bool clearError = false, // Error'u temizlemek için flag
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : error,
      isRefreshingToken: isRefreshingToken ?? this.isRefreshingToken,
    );
  }
}