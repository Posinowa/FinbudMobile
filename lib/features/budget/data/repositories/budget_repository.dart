// lib/features/budget/data/repositories/budget_repository.dart

import 'package:dio/dio.dart';
import '../models/budget_model.dart';

/// Budget Repository - API çağrıları
class BudgetRepository {
  final Dio _dio;

  BudgetRepository(this._dio);

  /// Budget listesini getir (ay bazlı)
  /// [month] - YYYY-MM formatında (örn: "2026-04"), null ise mevcut ay
  Future<BudgetListResponse> getBudgets({String? month}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null && month.isNotEmpty) {
        queryParams['month'] = month;
      }

      final response = await _dio.get(
        '/api/v1/budgets',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return BudgetListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Tek bir budget getir
  Future<BudgetModel> getBudgetById(String id) async {
    try {
      final response = await _dio.get('/api/v1/budgets/$id');
      return BudgetModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Yeni budget oluştur
  Future<Map<String, dynamic>> createBudget({
    required String categoryId,
    required double limit,
    required String month,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/budgets',
        data: {
          'category_id': categoryId,
          'limit': limit,
          'month': month,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Budget güncelle (sadece limit)
  Future<Map<String, dynamic>> updateBudget({
    required String id,
    required double limit,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/budgets/$id',
        data: {'limit': limit},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Budget sil
  Future<void> deleteBudget(String id) async {
    try {
      await _dio.delete('/api/v1/budgets/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      String message = 'Bir hata oluştu';
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'] as String;
      }

      switch (statusCode) {
        case 400:
          return BudgetException('Geçersiz istek: $message');
        case 401:
          return BudgetException('Oturum süresi doldu');
        case 403:
          return BudgetException('Bu işleme erişim izniniz yok');
        case 404:
          return BudgetException('Bütçe bulunamadı');
        case 409:
          return BudgetException('Bu kategori için zaten bütçe tanımlı');
        case 500:
          return BudgetException('Sunucu hatası');
        default:
          return BudgetException(message);
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return BudgetException('Bağlantı zaman aşımına uğradı');
    }

    if (e.type == DioExceptionType.connectionError) {
      return BudgetException('İnternet bağlantısı yok');
    }

    return BudgetException('Beklenmeyen bir hata oluştu');
  }
}

/// Budget Exception
class BudgetException implements Exception {
  final String message;
  BudgetException(this.message);

  @override
  String toString() => message;
}