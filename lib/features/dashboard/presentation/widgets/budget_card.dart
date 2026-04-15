import 'package:flutter/material.dart';
import '../../../../core/constants/app_color.dart';
import '../../domain/models/dashboard_summary.dart';

/// Tek bir bütçe özet kartı
class BudgetCard extends StatelessWidget {
  final BudgetSummary budget;

  const BudgetCard({
    super.key,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst kısım: Kategori adı ve ikon
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _getProgressColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  budget.categoryIcon ?? '📦',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  budget.categoryName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Yüzde göstergesi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProgressColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getProgressColor().withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (budget.isOverBudget)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 12,
                          color: _getProgressColor(),
                        ),
                      ),
                    Text(
                      '%${budget.usagePercentage.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (budget.usagePercentage / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          // Alt kısım: Tutar bilgileri
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAmountInfo('Kullanılan', budget.usedAmount),
              _buildAmountInfo('Kalan', budget.remainingAmount, isRemaining: true),
              _buildAmountInfo('Bütçe', budget.allocatedAmount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInfo(String label, double amount, {bool isRemaining = false}) {
    Color amountColor = AppColors.textPrimary;
    if (isRemaining) {
      amountColor = amount < 0 ? AppColors.expense : AppColors.income;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatAmount(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    final formatted = amount.abs().toStringAsFixed(0);
    final withSeparator = formatted.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '${amount < 0 ? '-' : ''}₺$withSeparator';
  }

  Color _getProgressColor() {
    if (budget.isOverBudget) return AppColors.expense;
    if (budget.isNearLimit) return AppColors.warning;
    return AppColors.income;
  }

  Color _getBorderColor() {
    if (budget.isOverBudget) return AppColors.expense.withOpacity(0.3);
    if (budget.isNearLimit) return AppColors.warning.withOpacity(0.3);
    return AppColors.border;
  }

  IconData _getCategoryIcon() {
    final iconMap = {
      'food': Icons.restaurant,
      'transport': Icons.directions_car,
      'shopping': Icons.shopping_bag,
      'entertainment': Icons.movie,
      'health': Icons.medical_services,
      'education': Icons.school,
      'bills': Icons.receipt_long,
      'home': Icons.home,
      'travel': Icons.flight,
      'savings': Icons.savings,
    };
    return iconMap[budget.categoryIcon?.toLowerCase()] ?? Icons.category;
  }
}

/// Bütçe kartları listesi
class BudgetCardList extends StatelessWidget {
  final List<BudgetSummary> budgets;

  const BudgetCardList({
    super.key,
    required this.budgets,
  });

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: AppColors.textHint,
            ),
            SizedBox(height: 12),
            Text(
              'Henüz bütçe oluşturmadınız',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: budgets.map((budget) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BudgetCard(budget: budget),
        );
      }).toList(),
    );
  }
}