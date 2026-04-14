// lib/features/budget/presentation/providers/budget_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/budget_model.dart';

/// Budget durumları
enum BudgetStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Budget State - Immutable state class
class BudgetState extends Equatable {
  final List<BudgetModel> budgets;
  final String selectedMonth; // YYYY-MM formatında
  final BudgetStatus status;
  final String? errorMessage;

  const BudgetState({
    this.budgets = const [],
    required this.selectedMonth,
    this.status = BudgetStatus.initial,
    this.errorMessage,
  });

  /// Factory: Mevcut ay ile başlat
  factory BudgetState.initial() {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return BudgetState(selectedMonth: currentMonth);
  }

  // ============ DURUM KONTROL ============

  bool get isLoading => status == BudgetStatus.loading;
  bool get isLoaded => status == BudgetStatus.loaded;
  bool get hasError => status == BudgetStatus.error;
  bool get isEmpty => budgets.isEmpty && isLoaded;
  bool get isNotEmpty => budgets.isNotEmpty;

  // ============ HESAPLAMALAR ============

  /// Toplam bütçe limiti
  double get totalLimit => budgets.fold(0.0, (sum, b) => sum + b.limit);

  /// Toplam harcanan
  double get totalSpent => budgets.fold(0.0, (sum, b) => sum + b.spent);

  /// Toplam kalan
  double get totalRemaining => budgets.fold(0.0, (sum, b) => sum + b.remaining);

  /// Genel yüzde
  double get overallPercentUsed {
    if (totalLimit <= 0) return 0;
    return (totalSpent / totalLimit) * 100;
  }

  /// Uyarı durumundaki bütçe sayısı (%80+)
  int get warningCount => budgets.where((b) => b.isWarning).length;

  /// Aşılan bütçe sayısı (%100+)
  int get overBudgetCount => budgets.where((b) => b.isOverBudget).length;

  // ============ COPY WITH ============

  BudgetState copyWith({
    List<BudgetModel>? budgets,
    String? selectedMonth,
    BudgetStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [budgets, selectedMonth, status, errorMessage];
}