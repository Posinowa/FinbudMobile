// lib/features/category/data/models/category_model.dart

import 'package:equatable/equatable.dart';

/// Kategori modeli - Backend Category yapısına uygun
class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final String type; // 'income' veya 'expense'
  final String? userId; // null ise sistem kategorisi

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    required this.type,
    this.userId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      type: json['type'] as String,
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type,
      'user_id': userId,
    };
  }

  /// Gelir kategorisi mi?
  bool get isIncome => type == 'income';

  /// Gider kategorisi mi?
  bool get isExpense => type == 'expense';

  /// Sistem kategorisi mi?
  bool get isSystemCategory => userId == null;

  @override
  List<Object?> get props => [id, name, icon, type, userId];
}

/// Kategori listesi response
class CategoryListResponse extends Equatable {
  final List<CategoryModel> data;

  const CategoryListResponse({required this.data});

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    return CategoryListResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isEmpty => data.isEmpty;

  /// Gelir kategorilerini filtrele
  List<CategoryModel> get incomeCategories =>
      data.where((c) => c.isIncome).toList();

  /// Gider kategorilerini filtrele
  List<CategoryModel> get expenseCategories =>
      data.where((c) => c.isExpense).toList();

  @override
  List<Object?> get props => [data];
}