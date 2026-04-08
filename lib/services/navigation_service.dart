import 'package:flutter/material.dart';
import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';

class NavigationService {
  // go_router için artık GlobalKey'e gerek yok ama
  // eski kodlarla uyumluluk için tutabiliriz
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Login ekranına git ve tüm stack'i temizle
  static void toLoginAndClearStack() {
    // go_router kullanarak navigasyon
    AppRouter.router.go(AppRoutes.login);
  }

  /// Dashboard'a git
  static void toDashboard() {
    AppRouter.router.go(AppRoutes.dashboard);
  }

  /// Herhangi bir route'a git
  static void goTo(String route) {
    AppRouter.router.go(route);
  }

  /// Geri dönülebilir şekilde sayfa aç
  static void pushTo(String route) {
    AppRouter.router.push(route);
  }

  /// Geri dön
  static void goBack() {
    AppRouter.router.pop();
  }
}