import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Bağlantı zaman aşımına uğradı',
          statusCode: null,
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'İstek gönderme zaman aşımına uğradı',
          statusCode: null,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Yanıt alma zaman aşımına uğradı',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return ApiException(
          message: 'İstek iptal edildi',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'İnternet bağlantısı yok',
          statusCode: null,
        );
      default:
        return ApiException(
          message: 'Beklenmeyen bir hata oluştu',
          statusCode: null,
        );
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message;
    switch (statusCode) {
      case 400:
        message = data?['message'] ?? 'Geçersiz istek';
        break;
      case 401:
        message = data?['message'] ?? 'Oturum süresi doldu';
        break;
      case 403:
        message = data?['message'] ?? 'Bu işlem için yetkiniz yok';
        break;
      case 404:
        message = data?['message'] ?? 'Kayıt bulunamadı';
        break;
      case 409:
        message = data?['message'] ?? 'Kayıt zaten mevcut';
        break;
      case 500:
        message = 'Sunucu hatası';
        break;
      default:
        message = data?['message'] ?? 'Bir hata oluştu';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  @override
  String toString() => message;
}