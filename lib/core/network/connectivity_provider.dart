import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// İnternet bağlantısı durumunu takip eden provider
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityNotifier() : super(true) {
    _init();
  }

  Future<void> _init() async {
    // Başlangıç durumunu kontrol et
    final result = await Connectivity().checkConnectivity();
    state = _isConnected(result);

    // Değişimleri dinle
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      state = _isConnected(results);
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
