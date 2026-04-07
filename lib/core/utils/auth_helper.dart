import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';

class AuthHelper {
  static const _storage = FlutterSecureStorage();

  /// Login sonrası token kaydet ve dashboard'a git
  static Future<void> onLoginSuccess(BuildContext context, String token) async {
    await _storage.write(key: 'auth_token', value: token);
    if (context.mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  /// Logout - token sil ve login'e git
  static Future<void> logout(BuildContext context) async {
    await _storage.delete(key: 'auth_token');
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  /// Token kontrolü
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }
}