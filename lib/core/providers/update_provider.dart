import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/maintenance_service.dart';

/// Güncelleme durumunu API'den çeker
final updateStatusProvider = FutureProvider<AppStatus>((ref) async {
  return MaintenanceService.checkStatus();
});

/// Kullanıcı banner'ı kapattı mı? (oturum boyunca hatırlanır)
final updateBannerDismissedProvider = StateProvider<bool>((ref) => false);
