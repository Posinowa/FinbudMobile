import 'package:flutter/foundation.dart';

/// Dashboard özet verisi modeli
/// GET /dashboard/summary endpoint'inden dönen veri yapısı
@immutable
class DashboardSummary {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final String month;
  final List<BudgetSummary> budgets;
  final List<RecentTransaction> recentTransactions;

  const DashboardSummary({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.month,
    this.budgets = const [],
    this.recentTransactions = const [],
  });

  /// Backend henüz veri döndürmediğinde veya yükleme sırasında gösterilecek boş özet.
  factory DashboardSummary.empty({required String month}) {
    return DashboardSummary(
      balance: 0,
      totalIncome: 0,
      totalExpense: 0,
      month: month,
      budgets: const [],
      recentTransactions: const [],
    );
  }

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0.0,
      month: json['month'] as String? ?? '',
      budgets: (json['budgets'] as List<dynamic>?)
              ?.map((e) => BudgetSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentTransactions: (json['recent_transactions'] as List<dynamic>?)
              ?.map((e) => RecentTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Bütçe özeti modeli
@immutable
class BudgetSummary {
  final int id;
  final String categoryName;
  final String? categoryIcon;
  final double allocatedAmount;
  final double usedAmount;
  final double remainingAmount;
  final double usagePercentage;

  const BudgetSummary({
    required this.id,
    required this.categoryName,
    this.categoryIcon,
    required this.allocatedAmount,
    required this.usedAmount,
    required this.remainingAmount,
    required this.usagePercentage,
  });

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    final allocated = (json['allocated_amount'] as num?)?.toDouble() ?? 0.0;
    final used = (json['used_amount'] as num?)?.toDouble() ?? 0.0;
    final remaining = (json['remaining_amount'] as num?)?.toDouble() ?? (allocated - used);
    final percentage = allocated > 0 ? (used / allocated) * 100 : 0.0;

    return BudgetSummary(
      id: json['id'] as int? ?? 0,
      categoryName: json['category_name'] as String? ?? 'Diğer',
      categoryIcon: json['category_icon'] as String?,
      allocatedAmount: allocated,
      usedAmount: used,
      remainingAmount: remaining,
      usagePercentage: (json['usage_percentage'] as num?)?.toDouble() ?? percentage,
    );
  }

  bool get isOverBudget => usedAmount > allocatedAmount;
  bool get isNearLimit => usagePercentage >= 80 && !isOverBudget;
}

/// Son işlem modeli
@immutable
class RecentTransaction {
  final int id;
  final String description;
  final String categoryName;
  final String? categoryIcon;
  final double amount;
  final DateTime date;
  final TransactionType type;

  const RecentTransaction({
    required this.id,
    required this.description,
    required this.categoryName,
    this.categoryIcon,
    required this.amount,
    required this.date,
    required this.type,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      id: json['id'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? 'Diğer',
      categoryIcon: json['category_icon'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      type: TransactionType.fromString(json['type'] as String? ?? 'expense'),
    );
  }

  bool get isIncome => type == TransactionType.income;
}

enum TransactionType {
  income('income'),
  expense('expense');

  final String value;
  const TransactionType(this.value);

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => TransactionType.expense,
    );
  }
}