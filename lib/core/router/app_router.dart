import 'package:finbud_app/core/router/app_routes.dart';
import 'package:finbud_app/features/auth/presentation/screens/login_screen.dart';
import 'package:finbud_app/features/auth/presentation/screens/register_screen.dart';
import 'package:finbud_app/features/budget/presentation/screens/budget_screen.dart';
import 'package:finbud_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:finbud_app/features/transaction/presentation/screens/transaction_screen.dart';
import 'package:finbud_app/features/user/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';



class AppRouter {
  static final _storage = const FlutterSecureStorage();
  static late final GoRouter router;
  static bool _isInitialized = false;

  /// Router'ı başlat
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final token = await _storage.read(key: 'auth_token');
    final isLoggedIn = token != null && token.isNotEmpty;

    router = GoRouter(
      initialLocation: isLoggedIn ? AppRoutes.dashboard : AppRoutes.login,
      debugLogDiagnostics: true,
      redirect: _guardRoute,
      routes: _routes,
      errorBuilder: _errorBuilder,
    );

    _isInitialized = true;
  }

  /// Route guard - Token kontrolü
  static Future<String?> _guardRoute(
    BuildContext context,
    GoRouterState state,
  ) async {
    final token = await _storage.read(key: 'access_token');
    final isLoggedIn = token != null && token.isNotEmpty;

    final isAuthRoute = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register;

    // Token yoksa ve auth route'ta değilse -> login'e yönlendir
    if (!isLoggedIn && !isAuthRoute) {
      return AppRoutes.login;
    }

    // Token varsa ve auth route'taysa -> dashboard'a yönlendir
    if (isLoggedIn && isAuthRoute) {
      return AppRoutes.dashboard;
    }

    return null; // Yönlendirme yok, devam et
  }

  /// Tüm route tanımları
  static final List<RouteBase> _routes = [
    // ========== Auth Routes ==========
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // ========== Main App Routes ==========
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.transactions,
      name: 'transactions',
      builder: (context, state) => const TransactionScreen(),
    ),
    GoRoute(
      path: AppRoutes.budget,
      name: 'budget',
      builder: (context, state) => const BudgetScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ];

  /// Hata sayfası
  static Widget _errorBuilder(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hata')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Sayfa bulunamadı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('${state.uri}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    );
  }
}