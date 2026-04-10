import 'package:flutter/foundation.dart';

enum TransactionType {
  income('income'),
  expense('expense');

  final String value;
  const TransactionType(this.value);

  static TransactionType fromString(String? value) {
    final normalized = (value ?? '').toLowerCase();
    if (normalized == 'income' || normalized == 'gelir') {
      return TransactionType.income;
    }
    return TransactionType.expense;
  }
}

@immutable
class TransactionModel {
  final int id;
  final String description;
  final String categoryName;
  final String? categoryIcon;
  final double amount;
  final DateTime date;
  final TransactionType type;

  const TransactionModel({
    required this.id,
    required this.description,
    required this.categoryName,
    this.categoryIcon,
    required this.amount,
    required this.date,
    required this.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      description: (json['description'] as String?)?.trim().isNotEmpty == true
          ? (json['description'] as String).trim()
          : (json['name'] as String?)?.trim() ?? '',
      categoryName: (json['category_name'] as String?) ??
          (json['category']?['name'] as String?) ??
          'Diger',
      categoryIcon: (json['category_icon'] as String?) ??
          (json['category']?['icon'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: _parseDate(json['date'] ?? json['created_at']),
      type: TransactionType.fromString(json['type'] as String?),
    );
  }

  bool get isIncome => type == TransactionType.income;

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }
}

@immutable
class TransactionPage {
  final List<TransactionModel> items;
  final int currentPage;
  final bool hasMore;

  const TransactionPage({
    required this.items,
    required this.currentPage,
    required this.hasMore,
  });

  factory TransactionPage.fromResponse({
    required dynamic payload,
    required int requestedPage,
    required int requestedLimit,
  }) {
    List<dynamic> rawItems = const [];
    int currentPage = requestedPage;
    bool hasMore = false;

    if (payload is List) {
      rawItems = payload;
      hasMore = payload.length >= requestedLimit;
    } else if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      final pagination = payload['pagination'];
      final meta = payload['meta'];

      if (data is List) {
        rawItems = data;
      } else if (data is Map<String, dynamic>) {
        rawItems = (data['items'] as List<dynamic>?) ??
            (data['transactions'] as List<dynamic>?) ??
            const [];
        currentPage = (data['current_page'] as num?)?.toInt() ??
            (data['page'] as num?)?.toInt() ??
            currentPage;
        hasMore =
            (data['has_more'] as bool?) ?? (data['next_page_url'] != null);
      } else {
        rawItems = (payload['items'] as List<dynamic>?) ??
            (payload['transactions'] as List<dynamic>?) ??
            const [];
      }

      currentPage = (payload['current_page'] as num?)?.toInt() ??
          (pagination?['current_page'] as num?)?.toInt() ??
          (meta?['current_page'] as num?)?.toInt() ??
          currentPage;

      hasMore = (payload['has_more'] as bool?) ??
          (pagination?['has_more'] as bool?) ??
          (meta?['has_more'] as bool?) ??
          (payload['next_page_url'] != null) ||
              (pagination?['next_page_url'] != null) ||
              (meta?['next_page_url'] != null) ||
          hasMore;

      if (!hasMore) {
        final totalPages = (payload['total_pages'] as num?)?.toInt() ??
            (pagination?['total_pages'] as num?)?.toInt() ??
            (meta?['last_page'] as num?)?.toInt();
        if (totalPages != null) {
          hasMore = currentPage < totalPages;
        } else {
          hasMore = rawItems.length >= requestedLimit;
        }
      }
    }

    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(TransactionModel.fromJson)
        .toList();

    return TransactionPage(
      items: items,
      currentPage: currentPage,
      hasMore: hasMore,
    );
  }
}
