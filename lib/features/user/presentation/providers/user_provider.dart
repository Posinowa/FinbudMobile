import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finbud_app/core/network/dio_client.dart';
import 'package:finbud_app/core/router/app_router.dart';
import 'package:finbud_app/features/category/presentation/providers/category_provider.dart';
import 'package:finbud_app/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finbud_app/features/budget/presentation/providers/budget_provider.dart';
import 'package:finbud_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/repositories/user_repository.dart';
import 'user_state.dart';

/// Repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(DioClient.instance);
});

/// Ana user provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository, ref);
});

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _repository;
  final Ref _ref;

  UserNotifier(this._repository, this._ref) : super(UserState.initial());

  /// GET /users/me — kullanıcı bilgilerini yükle
  Future<void> loadUser() async {
    if (state.status == UserStatus.loading) return;
    state = state.copyWith(status: UserStatus.loading, clearError: true);
    try {
      final user = await _repository.getMe();
      state = state.copyWith(status: UserStatus.loaded, user: user);
    } catch (e) {
      state = state.copyWith(
        status: UserStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// PUT /users/me — isim güncelle
  Future<bool> updateName(String name) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final updatedUser = await _repository.updateName(name);
      state = state.copyWith(
        isUpdating: false,
        user: updatedUser,
        status: UserStatus.loaded,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// PUT /users/me/password — şifre değiştir
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isChangingPassword: true, clearError: true);
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isChangingPassword: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isChangingPassword: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Çıkış yap — token'ları sil, tüm provider'ları sıfırla, login'e yönlendir
  Future<void> logout() async {
    _ref.invalidate(categoryProvider);
    _ref.invalidate(transactionProvider);
    _ref.invalidate(budgetProvider);
    _ref.invalidate(dashboardProvider);
    state = UserState.initial();
    await AppRouter.logout();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
