import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

    _dio.interceptors.add(AuthInterceptor());
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}

// Auth Interceptor - Token'ı otomatik ekler
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Public endpoint'ler için token ekleme
    final publicPaths = ['/auth/login', '/auth/register', '/auth/refresh'];
    if (publicPaths.any((path) => options.path.contains(path))) {
      return handler.next(options);
    }

    // Token'ı SharedPreferences'tan al
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 hatası durumunda token'ı temizle (opsiyonel)
    if (err.response?.statusCode == 401) {
      // Token refresh logic burada implement edilebilir
    }
    return handler.next(err);
  }
}