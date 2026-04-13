// lib/features/transaction/data/repositories/transaction_repository.dart

import 'package:dio/dio.dart';
import '../models/transaction_model.dart';

/// Transaction Repository - API çağrıları
class TransactionRepository {
  final Dio _dio;

  TransactionRepository(this._dio);

  /// Transaction listesini getir
  Future<TransactionListResponse> getTransactions({
    TransactionFilter filter = const TransactionFilter(),
  }) async {
    try {
      final response = await _dio.get(
        '/transactions',
        queryParameters: filter.toQueryParameters(),
      );
      return TransactionListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Tek bir transaction getir
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final response = await _dio.get('/transactions/$id');
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Yeni transaction oluştur
  Future<TransactionModel> createTransaction({
    required double amount,
    required String type,
    required String categoryId,
    required String date,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/transactions',
        data: {
          'amount': amount,
          'type': type,
          'category_id': categoryId,
          'date': date,
          if (description != null) 'description': description,
        },
      );
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Transaction güncelle
  Future<TransactionModel> updateTransaction({
    required String id,
    double? amount,
    String? categoryId,
    String? description,
    String? date,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (amount != null) data['amount'] = amount;
      if (categoryId != null) data['category_id'] = categoryId;
      if (description != null) data['description'] = description;
      if (date != null) data['date'] = date;

      final response = await _dio.put('/transactions/$id', data: data);
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Transaction sil
  Future<void> deleteTransaction(String id) async {
    try {
      await _dio.delete('/transactions/$id');
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
          return TransactionException('Geçersiz istek: $message');
        case 401:
          return TransactionException('Oturum süresi doldu');
        case 403:
          return TransactionException('Bu işleme erişim izniniz yok');
        case 404:
          return TransactionException('İşlem bulunamadı');
        case 500:
          return TransactionException('Sunucu hatası');
        default:
          return TransactionException(message);
      }
    }
    
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TransactionException('Bağlantı zaman aşımına uğradı');
    }
    
    if (e.type == DioExceptionType.connectionError) {
      return TransactionException('İnternet bağlantısı yok');
    }

    return TransactionException('Beklenmeyen bir hata oluştu');
  }
}

/// Transaction Exception
class TransactionException implements Exception {
  final String message;
  TransactionException(this.message);
  
  @override
  String toString() => message;
}