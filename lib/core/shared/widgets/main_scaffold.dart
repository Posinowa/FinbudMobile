import 'package:finbud_app/core/constants/app_color.dart';
import 'package:finbud_app/core/router/app_routes.dart';
import 'package:finbud_app/features/transaction/presentation/widgets/add_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  
  const MainScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.dashboard)) return 0;
    if (location.startsWith(AppRoutes.transactions)) return 1;
    if (location.startsWith(AppRoutes.budget)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
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
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    
    return Scaffold(
      body: child,
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          NavigationDestination(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/icons/bottomnav_home.png', fit: BoxFit.contain),
            ),
            selectedIcon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/icons/bottomnav_home.png', fit: BoxFit.contain),
            ),
            label: 'Anasayfa',
          ),
          NavigationDestination(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/icons/bottomnav_transaction.png', fit: BoxFit.contain),
            ),
            selectedIcon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/icons/bottomnav_transaction.png', fit: BoxFit.contain),
            ),
            label: 'Islemler',
          ),
          NavigationDestination(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/icons/bottomnav_budget.png', fit: BoxFit.contain),
            ),
            selectedIcon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/icons/bottomnav_budget.png', fit: BoxFit.contain),
            ),
            label: 'Butceler',
          ),
          NavigationDestination(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/icons/bottomnav_profile.png', fit: BoxFit.contain),
            ),
            selectedIcon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/icons/bottomnav_profile.png', fit: BoxFit.contain),
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddTransactionSheet(),
    );
  }
}