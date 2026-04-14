import '../../domain/models/user_model.dart';

enum UserStatus { initial, loading, loaded, error }

class UserState {
  final UserStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isUpdating;
  final bool isChangingPassword;

  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.errorMessage,
    this.isUpdating = false,
    this.isChangingPassword = false,
  });

  factory UserState.initial() => const UserState();

  UserState copyWith({
    UserStatus? status,
    UserModel? user,
    String? errorMessage,
    bool clearError = false,
    bool? isUpdating,
    bool? isChangingPassword,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isUpdating: isUpdating ?? this.isUpdating,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
    );
  }
}
