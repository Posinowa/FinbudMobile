import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/user_model.dart';

/// User Repository
/// GET  /users/me          → kullanıcı bilgilerini getir
/// PUT  /users/me          → isim güncelle
/// PUT  /users/me/password → şifre değiştir
class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  /// GET /users/me
  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get('/users/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /users/me — sadece isim güncellenir
  Future<UserModel> updateName(String name) async {
    try {
      final response = await _dio.put(
        '/users/me',
        data: {'name': name},
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /users/me/password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put(
        '/users/me/password',
        data: {
          'old_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      String message = 'Bir hata oluştu';
      if (data is Map<String, dynamic>) {
        message = (data['message'] ?? data['error'] ?? message).toString();
      }
      switch (e.response!.statusCode) {
        case 400:
          return UserException('Geçersiz istek: $message');
        case 401:
          return UserException('Oturum süresi doldu');
        case 403:
          return UserException('Bu işleme izniniz yok');
        case 404:
          return UserException('Kullanıcı bulunamadı');
        case 422:
          return UserException(message);
        case 500:
          return UserException('Sunucu hatası');
        default:
          return UserException(message);
      }
    }
    if (e.type == DioExceptionType.connectionError) {
      return UserException('İnternet bağlantısı yok');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return UserException('Bağlantı zaman aşımına uğradı');
    }
    return UserException('Beklenmeyen bir hata oluştu');
  }
}

class UserException implements Exception {
  final String message;
  const UserException(this.message);

  @override
  String toString() => message;
}