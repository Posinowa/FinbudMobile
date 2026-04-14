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
      // Backend "budget_summary" key'i ile gönderiyor
      budgets: (json['budget_summary'] as List<dynamic>?)
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
/// Backend: { id, category:{id,name,icon,type}, limit, spent, remaining, percent_used }
@immutable
class BudgetSummary {
  final String id;         // UUID string
  final String categoryName;
  final String? categoryIcon;
  final double allocatedAmount;  // backend: "limit"
  final double usedAmount;       // backend: "spent"
  final double remainingAmount;  // backend: "remaining"
  final double usagePercentage;  // backend: "percent_used"

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
    // Nested category objesi
    final category = json['category'] as Map<String, dynamic>? ?? {};

    final allocated = (json['limit'] as num?)?.toDouble() ?? 0.0;
    final used = (json['spent'] as num?)?.toDouble() ?? 0.0;
    final remaining = (json['remaining'] as num?)?.toDouble() ?? (allocated - used);
    final percentage = (json['percent_used'] as num?)?.toDouble() ??
        (allocated > 0 ? (used / allocated) * 100 : 0.0);

    return BudgetSummary(
      id: json['id']?.toString() ?? '',
      categoryName: category['name'] as String? ?? 'Diğer',
      categoryIcon: category['icon'] as String?,
      allocatedAmount: allocated,
      usedAmount: used,
      remainingAmount: remaining,
      usagePercentage: percentage,
    );
  }

  bool get isOverBudget => usedAmount > allocatedAmount;
  bool get isNearLimit => usagePercentage >= 80 && !isOverBudget;
}

/// Son işlem modeli
/// Backend: { id, amount, type, category:{id,name,icon,type}, description, date }
@immutable
class RecentTransaction {
  final String id;         // UUID string
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
    // Nested category objesi
    final category = json['category'] as Map<String, dynamic>? ?? {};

    return RecentTransaction(
      id: json['id']?.toString() ?? '',
      // description backend'de nullable (*string), null gelirse boş string
      description: json['description'] as String? ?? '',
      categoryName: category['name'] as String? ?? 'Diğer',
      categoryIcon: category['icon'] as String?,
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
