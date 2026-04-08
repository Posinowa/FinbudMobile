import 'package:flutter/foundation.dart';

@immutable
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;
  final String? accessToken;
  final String? refreshToken;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
    this.accessToken,
    this.refreshToken,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
    String? accessToken,
    String? refreshToken,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}