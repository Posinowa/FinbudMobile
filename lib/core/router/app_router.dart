import 'package:finbud_app/core/router/app_routes.dart';
import 'package:finbud_app/core/shared/widgets/main_scaffold.dart';
import 'package:finbud_app/features/auth/presentation/screens/login_screen.dart';
import 'package:finbud_app/features/auth/presentation/screens/register_screen.dart';
import 'package:finbud_app/features/budget/presentation/screens/add_budget_screen.dart';
import 'package:finbud_app/features/budget/presentation/screens/budget_screen.dart';
import 'package:finbud_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:finbud_app/features/transaction/presentation/screens/transaction_screen.dart';
import 'package:finbud_app/features/user/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

/// Uygulama router yönetimi
/// KAN-79: Uygulama açılışında token kontrolü
/// KAN-80: Bottom navigation bar için ShellRoute
class AppRouter {
  static final _storage = const FlutterSecureStorage();
  static late final GoRouter router;
  static bool _isInitialized = false;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final token = await _storage.read(key: _accessTokenKey);
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

  static Future<String?> _guardRoute(
    BuildContext context,
    GoRouterState state,
  ) async {
    final token = await _storage.read(key: _accessTokenKey);
    final isLoggedIn = token != null && token.isNotEmpty;

    final isAuthRoute = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register;

    if (!isLoggedIn && !isAuthRoute) {
      return AppRoutes.login;
    }

    if (isLoggedIn && isAuthRoute) {
      return AppRoutes.dashboard;
    }

    return null;
  }

  static Future<void> logout() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    router.go(AppRoutes.login);
  }

  static Future<bool> hasValidToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// KAN-80: ShellRoute ile bottom navigation bar
  static final List<RouteBase> _routes = [
    // Auth routes - bottom nav bar YOK
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

    // Main routes - bottom nav bar VAR
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          name: 'dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.transactions,
          name: 'transactions',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TransactionScreen(),
          ),
        ),
        GoRoute(
  path: AppRoutes.budget,
  name: 'budget',
  pageBuilder: (context, state) => const NoTransitionPage(
    child: BudgetScreen(),
  ),
  routes: [
    // ← YENİ: Alt route olarak ekleme ekranı
    GoRoute(
      path: 'add',
      name: 'addBudget',
      builder: (context, state) {
        // Mevcut ayı parametre olarak al (opsiyonel)
        final month = state.uri.queryParameters['month'];
        return AddBudgetScreen(initialMonth: month);
      },
    ),
  ],
),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),
  ];

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