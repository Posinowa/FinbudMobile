import '../../../../core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_color.dart';
import '../../domain/models/dashboard_summary.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/budget_card.dart';
import '../widgets/income_expense_chart.dart';
import '../widgets/month_selector.dart';
import '../widgets/recent_transactions_widget.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cikis Yap'),
        content: const Text('Hesabinizdan cikis yapmak istediginize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Iptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AppRouter.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cikis Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(selectedMonthProvider, (previous, next) {
      if (previous != null && previous != next) {
        ref.read(dashboardProvider.notifier).loadDashboard();
      }
    });

    final state = ref.watch(dashboardProvider);
    final month = ref.watch(selectedMonthProvider);
    final summary = state.summary ?? DashboardSummary.empty(month: month);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ozet'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout, color: AppColors.expense),
            tooltip: 'Cikis Yap',
          ),
        ],
        bottom: state.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.hasError)
            _DashboardErrorBanner(
              message: state.errorMessage ?? 'Bir hata olustu',
              onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: MonthSelector(),
                          ),
                          const SizedBox(height: 20),
                          DashboardSummaryCards(
                            balance: summary.balance,
                            totalIncome: summary.totalIncome,
                            totalExpense: summary.totalExpense,
                          ),
                          const SizedBox(height: 20),
                          IncomeExpenseChart(
                            income: summary.totalIncome,
                            expense: summary.totalExpense,
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle('Butceler'),
                          const SizedBox(height: 12),
                          BudgetCardList(
                            budgets: ref.watch(budgetListProvider),
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle('Son islemler'),
                          const SizedBox(height: 12),
                          RecentTransactionsList(
                            transactions: ref.watch(recentTransactionsProvider),
                            maxItems: 10,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _DashboardErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorBanner({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dangerLight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 22, color: AppColors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
