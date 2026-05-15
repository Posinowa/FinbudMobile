import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MaintenanceService {
  /// API'den bakım modu durumunu kontrol eder.
  /// true  → bakım modu aktif veya API ulaşılamaz
  /// false → uygulama normal çalışıyor
  static Future<bool> isMaintenance() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['API_BASE_URL'] ?? '',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await dio.get('/status');

      if (response.statusCode == 200) {
        return response.data['maintenance'] == true;
      }

      return true; // Beklenmeyen status code → bakım modu göster
    } catch (_) {
      return true; // API çökmüş veya ulaşılamıyor → bakım modu göster
    }
  }
}
