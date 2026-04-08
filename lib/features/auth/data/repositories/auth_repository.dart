import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';

class AuthRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioClient.instance.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Token'ları güvenli depolamaya kaydet
        await _storage.write(key: 'access_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);
        
        return {
          'success': true,
          'access_token': data['access_token'],
          'refresh_token': data['refresh_token'],
        };
      }
      
      return {
        'success': false,
        'error': 'Beklenmeyen bir hata oluştu',
      };
    } on DioException catch (e) {
      String errorMessage;
      
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 401:
            errorMessage = 'E-posta veya şifre hatalı';
            break;
          case 404:
            errorMessage = 'Kullanıcı bulunamadı';
            break;
          case 422:
            errorMessage = 'Geçersiz giriş bilgileri';
            break;
          case 500:
            errorMessage = 'Sunucu hatası, lütfen daha sonra tekrar deneyin';
            break;
          default:
            errorMessage = e.response?.data?['message'] ?? 'Giriş başarısız';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Bağlantı zaman aşımına uğradı';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'İnternet bağlantınızı kontrol edin';
      } else {
        errorMessage = 'Bağlantı hatası oluştu';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Beklenmeyen bir hata oluştu: $e',
      };
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }
}