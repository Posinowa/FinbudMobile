
import 'dart:io';

import '../../../../core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_color.dart';
import '../../../../core/providers/update_provider.dart';
import '../../domain/models/dashboard_summary.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/budget_card.dart';
import '../widgets/income_expense_chart.dart';
import '../widgets/month_selector.dart';
import '../widgets/recent_transactions_widget.dart';
import '../widgets/summary_card.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../budget/presentation/providers/budget_state.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/presentation/providers/transaction_state.dart';

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

  @override
  Widget build(BuildContext context) {
    // Ay değişince yenile
    ref.listen<String>(selectedMonthProvider, (previous, next) {
      if (previous != null && previous != next) {
        ref.read(dashboardProvider.notifier).loadDashboard();
      }
    });

    // Transaction eklenince/silinince/güncellenince dashboard'u yenile
    ref.listen<TransactionState>(transactionProvider, (previous, next) {
      if (previous != null &&
          previous.status != TransactionStatus.loaded &&
          next.status == TransactionStatus.loaded &&
          !ref.read(dashboardProvider).isLoading) {
        ref.read(dashboardProvider.notifier).refresh();
      }
    });

    // Budget eklenince/silinince/güncellenince dashboard'u yenile
    ref.listen<BudgetState>(budgetProvider, (previous, next) {
      if (previous != null &&
          previous.status != BudgetStatus.loaded &&
          next.isLoaded &&
          !ref.read(dashboardProvider).isLoading) {
        ref.read(dashboardProvider.notifier).refresh();
      }
    });

    final state = ref.watch(dashboardProvider);
    final month = ref.watch(selectedMonthProvider);
    final summary = state.summary ?? DashboardSummary.empty(month: month);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Finbud',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: state.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Güncelleme banner'ı
          const _UpdateBanner(),
          if (state.hasError)
            _DashboardErrorBanner(
              message: state.errorMessage ?? 'Bir hata oluştu',
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
                          const _SectionTitle('Bütçeler'),
                          const SizedBox(height: 12),
                          BudgetCardList(
                            budgets: ref.watch(budgetListProvider),
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle('Son işlemler'),
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

  // LOGOUT DIALOG - DOGRU YER BURASI
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cikis Yap'),
        content: const Text('Hesabinizdan cikis yapmak istediginize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Iptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
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

class _UpdateBanner extends ConsumerWidget {
  const _UpdateBanner();

  // Play Store veya App Store'u açar
  Future<void> _openStore(String? androidUrl, String? iosUrl) async {
    try {
      if (Platform.isAndroid) {
        // Önce Play Store uygulamasını dene (market:// scheme)
        const packageName = 'com.finbud.finbud_app';
        final marketUri = Uri.parse('market://details?id=$packageName');
        if (await canLaunchUrl(marketUri)) {
          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
          return;
        }
        // Play Store uygulaması yoksa web URL'ye düş
        final webUrl = androidUrl?.isNotEmpty == true
            ? androidUrl!
            : 'https://play.google.com/store/apps/details?id=$packageName';
        await launchUrl(Uri.parse(webUrl),
            mode: LaunchMode.externalApplication);
      } else if (Platform.isIOS) {
        final url = iosUrl?.isNotEmpty == true ? iosUrl! : '';
        if (url.isEmpty) return;
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dismissed = ref.watch(updateBannerDismissedProvider);
    if (dismissed) return const SizedBox.shrink();

    final statusAsync = ref.watch(updateStatusProvider);

    return statusAsync.when(
      data: (status) {
        if (!status.updateAvailable) return const SizedBox.shrink();

        // Platform'a göre store URL'si belirle
        final hasStoreUrl = Platform.isIOS
            ? (status.iosStoreUrl?.isNotEmpty == true)
            : true; // Android'de market:// her zaman çalışır

        return Material(
          color: AppColors.primary.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            child: Row(
              children: [
                const Icon(Icons.system_update_outlined,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Yeni güncelleme mevcut!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (hasStoreUrl)
                  TextButton(
                    onPressed: () => _openStore(
                      status.androidStoreUrl,
                      status.iosStoreUrl,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Güncelle',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 18, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => ref
                      .read(updateBannerDismissedProvider.notifier)
                      .state = true,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
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
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
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
