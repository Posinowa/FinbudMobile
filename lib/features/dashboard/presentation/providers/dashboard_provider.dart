import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../domain/models/dashboard_summary.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../budget/presentation/providers/budget_state.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/presentation/providers/transaction_state.dart';

// Repository provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

// Seçili ay provider - YYYY-MM formatında
final selectedMonthProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

// Dashboard state
class DashboardState {
  final bool isLoading;
  final String? errorMessage;
  final DashboardSummary? summary;

  const DashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.summary,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    DashboardSummary? summary,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      summary: summary ?? this.summary,
    );
  }

  bool get hasData => summary != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
}

// Dashboard notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;
  final Ref _ref;

  DashboardNotifier(this._repository, this._ref)
      : super(
          DashboardState(
            summary: DashboardSummary.empty(
              month: _ref.read(selectedMonthProvider),
            ),
          ),
        );

  Future<void> loadDashboard() async {
    final month = _ref.read(selectedMonthProvider);
    final current = state.summary;
    final shouldReset =
        current == null ||
            current.month.isEmpty ||
            current.month != month;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      summary: shouldReset
          ? DashboardSummary.empty(month: month)
          : current,
    );

    final result = await _repository.getDashboardSummary(month: month);

    if (result['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        summary: result['data'] as DashboardSummary,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['error'] as String?,
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}

// Dashboard provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final notifier = DashboardNotifier(repository, ref);

  // Transaction eklenince/silinince/güncellenince dashboard'u otomatik yenile
  ref.listen<TransactionState>(transactionProvider, (previous, next) {
    if (previous != null &&
        previous.isLoading &&
        next.status == TransactionStatus.loaded &&
        !notifier.state.isLoading) {
      notifier.refresh();
    }
  });

  // Budget eklenince/silinince/güncellenince dashboard'u otomatik yenile
  ref.listen<BudgetState>(budgetProvider, (previous, next) {
    if (previous != null &&
        previous.isLoading &&
        next.isLoaded &&
        !notifier.state.isLoading) {
      notifier.refresh();
    }
  });

  return notifier;
});

// Convenience providers
final dashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardProvider).isLoading;
});

final dashboardErrorProvider = Provider<String?>((ref) {
  return ref.watch(dashboardProvider).errorMessage;
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(dashboardProvider).summary?.balance ?? 0.0;
});

final totalIncomeProvider = Provider<double>((ref) {
  return ref.watch(dashboardProvider).summary?.totalIncome ?? 0.0;
});

final totalExpenseProvider = Provider<double>((ref) {
  return ref.watch(dashboardProvider).summary?.totalExpense ?? 0.0;
});

final budgetListProvider = Provider<List<BudgetSummary>>((ref) {
  return ref.watch(dashboardProvider).summary?.budgets ?? [];
});

final recentTransactionsProvider = Provider<List<RecentTransaction>>((ref) {
  return ref.watch(dashboardProvider).summary?.recentTransactions ?? [];
});