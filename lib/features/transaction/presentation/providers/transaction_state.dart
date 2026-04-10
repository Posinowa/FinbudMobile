import '../../data/models/transaction_model.dart';

class TransactionState {
  final bool isInitialLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? loadMoreError;
  final List<TransactionModel> transactions;
  final int currentPage;
  final int limit;
  final bool hasMore;

  const TransactionState({
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError,
    this.transactions = const [],
    this.currentPage = 1,
    this.limit = 20,
    this.hasMore = true,
  });

  TransactionState copyWith({
    bool? isInitialLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? loadMoreError,
    List<TransactionModel>? transactions,
    int? currentPage,
    int? limit,
    bool? hasMore,
    bool clearError = false,
    bool clearLoadMoreError = false,
  }) {
    return TransactionState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadMoreError: clearLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasLoadMoreError =>
      loadMoreError != null && loadMoreError!.isNotEmpty;
  bool get isEmpty => !isInitialLoading && transactions.isEmpty && !hasError;
}
