import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/google_sign_in_service.dart';
import '../../data/services/apple_sign_in_service.dart';
import '../../domain/models/auth_state.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Loading başlat
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.login(
      email: email,
      password: password,
    );

    if (result['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        accessToken: result['access_token'],
        refreshToken: result['refresh_token'],
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: result['error'],
      );
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    // Google sign-in akışını başlat
    final idToken = await GoogleSignInService.signIn();

    if (idToken == null) {
      // Kullanıcı iptal etti
      state = state.copyWith(isLoading: false);
      return false;
    }

    final result = await _repository.loginWithGoogle(idToken: idToken);

    if (result['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        accessToken: result['access_token'],
        refreshToken: result['refresh_token'],
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: result['error'],
      );
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await AppleSignInService.signIn();

    if (result == null) {
      // Kullanıcı iptal etti
      state = state.copyWith(isLoading: false);
      return false;
    }

    final response = await _repository.loginWithApple(
      identityToken: result.identityToken,
      email: result.email,
      fullName: result.fullName,
    );

    if (response['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        accessToken: response['access_token'],
        refreshToken: response['refresh_token'],
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: response['error'],
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    await GoogleSignInService.signOut();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      final token = await _repository.getAccessToken();
      state = state.copyWith(
        isAuthenticated: true,
        accessToken: token,
      );
    }
  }
}

// Auth notifier provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

// Convenience providers
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});