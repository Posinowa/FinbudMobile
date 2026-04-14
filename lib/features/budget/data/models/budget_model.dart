// lib/features/budget/data/models/budget_model.dart

import 'package:equatable/equatable.dart';

/// Kategori response modeli (Budget içinde)
class BudgetCategoryResponse extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final String type;

  const BudgetCategoryResponse({
    required this.id,
    required this.name,
    this.icon,
    required this.type,
  });

  factory BudgetCategoryResponse.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      type: json['type'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, type];
}

/// Budget modeli - Backend BudgetResponse yapısına uygun
class BudgetModel extends Equatable {
  final String id;
  final BudgetCategoryResponse category;
  final double limit;
  final double spent;
  final double remaining;
  final double percentUsed;

  const BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.spent,
    required this.remaining,
    required this.percentUsed,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      category: BudgetCategoryResponse.fromJson(json['category'] as Map<String, dynamic>),
      limit: (json['limit'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      percentUsed: (json['percent_used'] as num).toDouble(),
    );
  }

  /// Bütçe aşıldı mı? (%100 veya üzeri)
  bool get isOverBudget => percentUsed >= 100;

  /// Bütçe uyarı durumunda mı? (%80-99)
  bool get isWarning => percentUsed >= 80 && percentUsed < 100;

  /// Bütçe normal durumda mı? (%80'in altı)
  bool get isNormal => percentUsed < 80;

  /// Progress bar için 0-1 arası değer (max 1.0)
  double get progressValue => (percentUsed / 100).clamp(0.0, 1.0);

  /// Tam progress değeri (1.0'ı geçebilir, UI'da göstermek için)
  double get fullProgressValue => percentUsed / 100;

  @override
  List<Object?> get props => [id, category, limit, spent, remaining, percentUsed];
}

/// Budget listesi response - Backend BudgetListResponse yapısına uygun
class BudgetListResponse extends Equatable {
  final String month;
  final List<BudgetModel> data;

  const BudgetListResponse({
    required this.month,
    required this.data,
  });

  factory BudgetListResponse.fromJson(Map<String, dynamic> json) {
    return BudgetListResponse(
      month: json['month'] as String,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;

  /// Toplam bütçe limiti
  double get totalLimit => data.fold(0.0, (sum, b) => sum + b.limit);

  /// Toplam harcanan
  double get totalSpent => data.fold(0.0, (sum, b) => sum + b.spent);

  /// Toplam kalan
  double get totalRemaining => data.fold(0.0, (sum, b) => sum + b.remaining);

  @override
  List<Object?> get props => [month, data];
}