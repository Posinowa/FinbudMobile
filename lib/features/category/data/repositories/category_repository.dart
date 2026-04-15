// lib/features/category/data/repositories/category_repository.dart

import 'package:dio/dio.dart';
import '../models/category_model.dart';

/// Category Repository - API çağrıları
class CategoryRepository {
  final Dio _dio;

  CategoryRepository(this._dio);

  /// Tüm kategorileri getir
  /// [type] - 'income' veya 'expense' ile filtreleme yapılabilir
  Future<List<CategoryModel>> getCategories({String? type}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) {
        queryParams['type'] = type;
      }

      final response = await _dio.get(
        '/categories',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      
      // API response: { "data": [...] }
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return (data['data'] as List<dynamic>)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      // Direkt liste dönerse
      if (data is List<dynamic>) {
        return data
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gelir kategorilerini getir
  Future<List<CategoryModel>> getIncomeCategories() async {
    return getCategories(type: 'income');
  }

  /// Gider kategorilerini getir
  Future<List<CategoryModel>> getExpenseCategories() async {
    return getCategories(type: 'expense');
  }

  /// Yeni kategori oluştur (POST /categories)
  Future<CategoryModel> createCategory({
    required String name,
    required String icon,
    required String type,
  }) async {
    try {
      final response = await _dio.post(
        '/categories',
        data: {
          'name': name,
          'icon': icon,
          'type': type,
        },
      );

      final data = response.data;

      // API response: { "data": {...} } veya direkt obje
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return CategoryModel.fromJson(data['data'] as Map<String, dynamic>);
      }

      return CategoryModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Tek bir kategori getir
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await _dio.get('/categories/$id');
      return CategoryModel.fromJson(response.data as Map<String, dynamic>);
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
          return CategoryException('Geçersiz istek: $message');
        case 401:
          return CategoryException('Oturum süresi doldu');
        case 403:
          return CategoryException('Bu işleme erişim izniniz yok');
        case 404:
          return CategoryException('Kategori bulunamadı');
        case 500:
          return CategoryException('Sunucu hatası');
        default:
          return CategoryException(message);
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return CategoryException('Bağlantı zaman aşımına uğradı');
    }

    if (e.type == DioExceptionType.connectionError) {
      return CategoryException('İnternet bağlantısı yok');
    }

    return CategoryException('Beklenmeyen bir hata oluştu');
  }
}

/// Category Exception
class CategoryException implements Exception {
  final String message;
  CategoryException(this.message);

  @override
  String toString() => message;
}