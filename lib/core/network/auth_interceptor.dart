import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/navigation_service.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isRefreshing = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path.contains('/auth/refresh') || options.path.contains('/auth/login')) {
      handler.next(options);
      return;
    }

    final accessToken = await _storage.read(key: 'access_token');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.path.contains('/auth/login') || 
        err.requestOptions.path.contains('/auth/register')) {
      handler.next(err);
      return;
    }

    if (err.response?.statusCode == 401 && !_isRefreshing) {
      if (err.requestOptions.path.contains('/auth/refresh')) {
        await _performLogout();
        handler.next(err);
        return;
      }

      _isRefreshing = true;

      try {
        final refreshed = await _refreshToken();

        if (refreshed) {
          final response = await _retryRequest(err.requestOptions);
          _isRefreshing = false;
          handler.resolve(response);
          return;
        } else {
          _isRefreshing = false;
          await _performLogout();
          handler.next(err);
          return;
        }
      } catch (e) {
        _isRefreshing = false;
        await _performLogout();
        handler.next(err);
        return;
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['API_BASE_URL'] ?? '',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'access_token', value: data['access_token']);
        if (data['refresh_token'] != null) {
          await _storage.write(key: 'refresh_token', value: data['refresh_token']);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final accessToken = await _storage.read(key: 'access_token');

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    final retryDio = Dio(
      BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''),
    );

    return retryDio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _performLogout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    NavigationService.toLoginAndClearStack();
  }
}