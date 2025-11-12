import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'authRepository.dart';
import 'authNotifier.dart';
import 'authState.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

// Şifre Görünürlüğü için basit bir StateProvider
final obscurePasswordProvider = StateProvider.autoDispose<bool>((ref) => true);