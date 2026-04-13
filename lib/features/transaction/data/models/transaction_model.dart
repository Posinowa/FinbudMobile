// lib/features/transaction/data/models/transaction_model.dart

import 'package:equatable/equatable.dart';

/// Transaction tipi enum
enum TransactionType { income, expense }

/// Kategori response modeli
class CategoryResponse extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final String type;

  const CategoryResponse({
    required this.id,
    required this.name,
    this.icon,
    required this.type,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      type: json['type'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, type];
}

/// Transaction modeli - Backend TransactionResponse yapısına uygun
class TransactionModel extends Equatable {
  final String id;
  final double amount;
  final TransactionType type;
  final String date; // "2006-01-02" formatında
  final String? description;
  final CategoryResponse category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income' 
          ? TransactionType.income 
          : TransactionType.expense,
      date: json['date'] as String,
      description: json['description'] as String?,
      category: CategoryResponse.fromJson(json['category'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Gelir mi kontrol
  bool get isIncome => type == TransactionType.income;
  
  /// Gider mi kontrol
  bool get isExpense => type == TransactionType.expense;

  /// Tarihi DateTime olarak al
  DateTime get dateTime => DateTime.parse(date);

  @override
  List<Object?> get props => [id, amount, type, date, description, category, createdAt, updatedAt];
}

/// Pagination meta verisi
class PaginationMeta extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  /// Daha fazla sayfa var mı?
  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

/// Transaction listesi response
class TransactionListResponse extends Equatable {
  final List<TransactionModel> data;
  final PaginationMeta meta;

  const TransactionListResponse({
    required this.data,
    required this.meta,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    return TransactionListResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  bool get isEmpty => data.isEmpty;
  bool get hasMore => meta.hasMore;

  @override
  List<Object?> get props => [data, meta];
}

/// Transaction filtre modeli
class TransactionFilter extends Equatable {
  final String? type;
  final String? categoryId;
  final String? month;
  final int page;
  final int limit;

  const TransactionFilter({
    this.type,
    this.categoryId,
    this.month,
    this.page = 1,
    this.limit = 20,
  });

  TransactionFilter copyWith({
    String? type,
    String? categoryId,
    String? month,
    int? page,
    int? limit,
    bool clearType = false,
    bool clearCategoryId = false,
    bool clearMonth = false,
  }) {
    return TransactionFilter(
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      month: clearMonth ? null : (month ?? this.month),
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (type != null && type!.isNotEmpty) params['type'] = type;
    if (categoryId != null && categoryId!.isNotEmpty) params['category_id'] = categoryId;
    if (month != null && month!.isNotEmpty) params['month'] = month;
    return params;
  }

  bool get hasActiveFilters => type != null || categoryId != null || month != null;

  @override
  List<Object?> get props => [type, categoryId, month, page, limit];
}