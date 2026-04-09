import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/dashboard_summary.dart';

class DashboardRepository {
  Future<Map<String, dynamic>> getDashboardSummary({String? month}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null && month.isNotEmpty) {
        queryParams['month'] = month;
      }

      final response = await DioClient.instance.get(
        '/dashboard/summary',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'data': DashboardSummary.fromJson(data as Map<String, dynamic>),
        };
      }

      return {
        'success': false,
        'error': 'Veriler yüklenirken bir hata oluştu',
      };
    } on DioException catch (e) {
      String errorMessage;

      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 401:
            errorMessage = 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.';
            break;
          case 403:
            errorMessage = 'Bu işlem için yetkiniz yok.';
            break;
          case 404:
            errorMessage = 'Dashboard verisi bulunamadı.';
            break;
          case 500:
            errorMessage = 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
            break;
          default:
            errorMessage = e.response?.data?['message'] ?? 'Bir hata oluştu.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Bağlantı zaman aşımına uğradı.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'İnternet bağlantınızı kontrol edin.';
      } else {
        errorMessage = 'Bağlantı hatası oluştu.';
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
}