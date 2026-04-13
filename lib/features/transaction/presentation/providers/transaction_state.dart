// lib/features/transaction/presentation/providers/transaction_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/transaction_model.dart';

/// Transaction yükleme durumu
enum TransactionStatus { initial, loading, loaded, loadingMore, error }

/// Transaction state - Immutable state class
class TransactionState extends Equatable {
  final List<TransactionModel> transactions;
  final TransactionStatus status;
  final String? errorMessage;
  final PaginationMeta? meta;
  final TransactionFilter filter;

  const TransactionState({
    this.transactions = const [],
    this.status = TransactionStatus.initial,
    this.errorMessage,
    this.meta,
    this.filter = const TransactionFilter(),
  });

  /// Liste boş mu?
  bool get isEmpty => status == TransactionStatus.loaded && transactions.isEmpty;

  /// Yükleniyor mu?
  bool get isLoading => status == TransactionStatus.loading;

  /// Daha fazla yükleniyor mu?
  bool get isLoadingMore => status == TransactionStatus.loadingMore;

  /// Hata var mı?
  bool get hasError => status == TransactionStatus.error;

  /// Daha fazla sayfa var mı?
  bool get hasMore => meta?.hasMore ?? true;

  /// Aktif filtre var mı?
  bool get hasActiveFilters => filter.hasActiveFilters;

  /// Toplam gelir
  double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Toplam gider
  double get totalExpense => transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Net bakiye
  double get netBalance => totalIncome - totalExpense;

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    TransactionStatus? status,
    String? errorMessage,
    PaginationMeta? meta,
    TransactionFilter? filter,
    bool clearError = false,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      meta: meta ?? this.meta,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [transactions, status, errorMessage, meta, filter];
}