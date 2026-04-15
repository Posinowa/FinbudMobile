// lib/features/budget/presentation/screens/budget_screen.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:finbud_app/core/router/app_routes.dart';
import 'package:finbud_app/core/utils/app_snackbar.dart';
import 'package:finbud_app/features/budget/data/models/budget_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/budget_provider.dart';
import '../providers/budget_state.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_empty_state.dart';
import '../widgets/budget_shimmer.dart';
import '../widgets/month_selector.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  @override
  void initState() {
    super.initState();

    // İlk yükleme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetProvider.notifier).loadBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetProvider);

    return Scaffold(
    backgroundColor: AppColors.background,
    appBar: _buildAppBar(state),
    body: _buildBody(state),
    // ← YENİ: FAB eklendi
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _navigateToAddBudget(),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Bütçe Ekle',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}

  PreferredSizeWidget _buildAppBar(BudgetState state) {
    return AppBar(
      title: const Text(
        'Bütçeler',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: [
        // Özet bilgi badge'leri
        if (state.isLoaded && state.isNotEmpty) ...[
          if (state.overBudgetCount > 0)
            _buildStatusBadge(
              count: state.overBudgetCount,
              color: AppColors.danger,
              icon: Icons.warning_amber_rounded,
            ),
          if (state.warningCount > 0)
            _buildStatusBadge(
              count: state.warningCount,
              color: AppColors.warning,
              icon: Icons.info_outline_rounded,
            ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatusBadge({
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BudgetState state) {
    return Column(
      children: [
        // Ay seçici - her zaman göster
        Padding(
          padding: const EdgeInsets.all(16),
          child: MonthSelector(
            selectedMonth: state.selectedMonth,
            onPreviousMonth: () => ref.read(budgetProvider.notifier).previousMonth(),
            onNextMonth: () => ref.read(budgetProvider.notifier).nextMonth(),
            onMonthTap: () => _showMonthPicker(state.selectedMonth),
          ),
        ),

        // İçerik
        Expanded(
          child: _buildContent(state),
        ),
      ],
    );
  }

  Widget _buildContent(BudgetState state) {
    // İlk yükleme
    if (state.isLoading) {
      return const BudgetShimmer();
    }

    // Hata durumu
    if (state.hasError) {
      return _buildErrorState(state);
    }

    // Boş durum
    if (state.isEmpty) {
      return BudgetEmptyState(
        monthLabel: _formatMonth(state.selectedMonth),
        onAddBudget: _onAddBudget,
      );
    }

    // Liste
    return RefreshIndicator(
      onRefresh: () => ref.read(budgetProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: state.budgets.length,
        itemBuilder: (context, index) {
          final budget = state.budgets[index];
          return BudgetCard(
            budget: budget,
            onTap: () => _onBudgetTap(budget),
            onEdit: () => _onEditBudget(budget),
            onDelete: () => _onDeleteBudget(budget),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BudgetState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Bilinmeyen hata',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(budgetProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(String currentMonth) async {
    final parts = currentMonth.split('-');
    final currentYear = int.parse(parts[0]);
    final currentMonthNum = int.parse(parts[1]);

    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(currentYear, currentMonthNum),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      final newMonth = '${selected.year}-${selected.month.toString().padLeft(2, '0')}';
      ref.read(budgetProvider.notifier).setMonth(newMonth);
    }
  }

  void _onBudgetTap(budget) {
    // Budget detay sayfasına git veya düzenleme aç
    _onEditBudget(budget);
  }

  void _onAddBudget() {
  _navigateToAddBudget();
}

  void _onEditBudget(BudgetModel budget) {
    // KAN-88: Budget düzenleme ekranına git
    context.push(
      AppRoutes.editBudget,
      extra: budget,
    );
  }

  Future<void> _onDeleteBudget(BudgetModel budget) async {
  // Swipe'dan geliyorsa dialog zaten BudgetCard'da gösterildi
  // Burada sadece API çağrısı ve feedback ver
  final success = await ref.read(budgetProvider.notifier).deleteBudget(budget.id);
  
  if (mounted) {
    if (success) {
      AppSnackBar.showSuccess(context, 'Bütçe silindi');
    } else {
      AppSnackBar.showError(
        context,
        'Bütçe silinemedi',
        actionLabel: 'Tekrar Dene',
        onAction: () => _onDeleteBudget(budget),
      );
    }
  }
}


  void _navigateToAddBudget() {
  final currentMonth = ref.read(budgetProvider).selectedMonth;
  context.push('${AppRoutes.addBudget}?month=$currentMonth');
}


  String _formatMonth(String month) {
    final parts = month.split('-');
    if (parts.length != 2) return month;

    final year = parts[0];
    final monthNum = int.tryParse(parts[1]) ?? 1;

    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    return '${months[monthNum - 1]} $year';
  }
}