import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  Future<Map<String, dynamic>> getTransactions({
    required int page,
    required int limit,
    String? month,
    TransactionType? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (month != null && month.isNotEmpty) {
        queryParams['month'] = month;
      }
      if (type != null) {
        queryParams['type'] = type.value;
      }

      final response = await DioClient.instance.get(
        '/transactions',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': TransactionPage.fromResponse(
            payload: response.data,
            requestedPage: page,
            requestedLimit: limit,
          ),
        };
      }

      return {
        'success': false,
        'error': 'Islemler yuklenirken bir hata olustu',
      };
    } on DioException catch (e) {
      String errorMessage;
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 401:
            errorMessage = 'Oturum sureniz doldu. Lutfen tekrar giris yapin.';
            break;
          case 403:
            errorMessage = 'Bu islemi yapma yetkiniz bulunmuyor.';
            break;
          case 404:
            errorMessage = 'Islem kayitlari bulunamadi.';
            break;
          case 500:
            errorMessage = 'Sunucu hatasi olustu. Daha sonra tekrar deneyin.';
            break;
          default:
            errorMessage = e.response?.data?['message'] as String? ??
                'Islemler yuklenemedi.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Baglanti zaman asimina ugradi.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Internet baglantinizi kontrol edin.';
      } else {
        errorMessage = 'Baglanti hatasi olustu.';
      }

      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (_) {
      return {
        'success': false,
        'error': 'Beklenmeyen bir hata olustu.',
      };
    }
  }
}
