import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import 'transaction_state.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final selectedTransactionTypeProvider =
    StateProvider<TransactionType?>((ref) => null);

final selectedTransactionMonthProvider = StateProvider<String?>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionRepository _repository;
  final Ref _ref;

  TransactionNotifier(this._repository, this._ref)
      : super(const TransactionState());

  Future<void> loadInitial() async {
    final selectedMonth = _ref.read(selectedTransactionMonthProvider);
    final selectedType = _ref.read(selectedTransactionTypeProvider);

    state = state.copyWith(
      isInitialLoading: true,
      clearError: true,
      clearLoadMoreError: true,
      currentPage: 1,
      hasMore: true,
      transactions: const [],
    );

    final result = await _repository.getTransactions(
      page: 1,
      limit: state.limit,
      month: selectedMonth,
      type: selectedType,
    );

    if (result['success'] == true) {
      final pageData = result['data'] as TransactionPage;
      state = state.copyWith(
        isInitialLoading: false,
        transactions: pageData.items,
        currentPage: pageData.currentPage,
        hasMore: pageData.hasMore,
      );
      return;
    }

    state = state.copyWith(
      isInitialLoading: false,
      errorMessage: result['error'] as String?,
    );
  }

  Future<void> loadMore() async {
    if (state.isInitialLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(
      isLoadingMore: true,
      clearLoadMoreError: true,
    );

    final nextPage = state.currentPage + 1;
    final result = await _repository.getTransactions(
      page: nextPage,
      limit: state.limit,
      month: _ref.read(selectedTransactionMonthProvider),
      type: _ref.read(selectedTransactionTypeProvider),
    );

    if (result['success'] == true) {
      final pageData = result['data'] as TransactionPage;
      state = state.copyWith(
        isLoadingMore: false,
        transactions: [...state.transactions, ...pageData.items],
        currentPage: pageData.currentPage,
        hasMore: pageData.hasMore,
      );
      return;
    }

    state = state.copyWith(
      isLoadingMore: false,
      loadMoreError: result['error'] as String?,
    );
  }

  Future<void> retryInitial() => loadInitial();

  Future<void> retryLoadMore() => loadMore();

  Future<void> refresh() => loadInitial();

  Future<void> updateFilters({
    TransactionType? type,
    required String? month,
  }) async {
    _ref.read(selectedTransactionTypeProvider.notifier).state = type;
    _ref.read(selectedTransactionMonthProvider.notifier).state = month;
    await loadInitial();
  }

  Future<void> clearFilters() async {
    _ref.read(selectedTransactionTypeProvider.notifier).state = null;
    _ref.read(selectedTransactionMonthProvider.notifier).state = null;
    await loadInitial();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository, ref);
});
