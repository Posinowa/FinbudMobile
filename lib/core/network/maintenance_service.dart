import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppStatus {
  final bool isMaintenance;
  final bool updateAvailable;
  final String? androidStoreUrl;
  final String? iosStoreUrl;

  const AppStatus({
    required this.isMaintenance,
    required this.updateAvailable,
    this.androidStoreUrl,
    this.iosStoreUrl,
  });

  factory AppStatus.maintenance() => const AppStatus(
        isMaintenance: true,
        updateAvailable: false,
      );

  factory AppStatus.fromJson(Map<String, dynamic> json) => AppStatus(
        isMaintenance: json['maintenance'] == true,
        updateAvailable: json['update_available'] == true,
        androidStoreUrl: json['android_store_url'] as String?,
        iosStoreUrl: json['ios_store_url'] as String?,
      );
}

class MaintenanceService {
  /// API'den uygulama durumunu kontrol eder.
  static Future<AppStatus> checkStatus() async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      print('[Maintenance] API_BASE_URL: $baseUrl');

      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await dio.get('/status');
      print('[Maintenance] response: ${response.data}');

      if (response.statusCode == 200) {
        return AppStatus.fromJson(response.data as Map<String, dynamic>);
      }

      print('[Maintenance] unexpected status code: ${response.statusCode}');
      return AppStatus.maintenance();
    } catch (e) {
      print('[Maintenance] HATA: $e');
      return AppStatus.maintenance();
    }
  }

  /// Geriye dönük uyumluluk için — sadece bakım modunu kontrol eder.
  static Future<bool> isMaintenance() async {
    final status = await checkStatus();
    return status.isMaintenance;
  }
}
