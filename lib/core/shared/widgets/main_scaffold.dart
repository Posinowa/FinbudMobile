import 'package:finbud_app/core/providers/navigation_provider.dart';
import 'package:finbud_app/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Ana sayfa scaffold'u - Bottom Navigation Bar içerir
/// KAN-80: Bottom navigation bar oluştur
class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
          
          switch (index) {
            case 0:
              context.go(AppRoutes.dashboard);
              break;
            case 1:
              context.go(AppRoutes.transactions);
              break;
            case 2:
              context.go(AppRoutes.budget);
              break;
            case 3:
              context.go(AppRoutes.profile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'İşlemler',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Bütçe',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}