// lib/features/budget/presentation/widgets/budget_card.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/budget_model.dart';

class BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  /// Para formatı
  static final _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  /// Yüzde formatı
  static final _percentFormat = NumberFormat.decimalPattern('tr_TR');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildProgressBar(),
                const SizedBox(height: 12),
                _buildAmounts(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Kategori ikonu
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              budget.category.icon ?? '📊',
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Kategori adı ve limit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                budget.category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Limit: ${_currencyFormat.format(budget.limit)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Yüzde badge
        _buildPercentBadge(),
      ],
    );
  }

  Widget _buildPercentBadge() {
    final color = _getStatusColor();
    final percent = budget.percentUsed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (budget.isOverBudget)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: color,
              ),
            ),
          Text(
            '%${_percentFormat.format(percent.clamp(0, 999))}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final color = _getStatusColor();
    final progress = budget.progressValue;

    return Column(
      children: [
        // Progress bar
        Stack(
          children: [
            // Arkaplan
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Doluluk
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  gradient: budget.isOverBudget
                      ? LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmounts() {
    return Row(
      children: [
        // Harcanan
        Expanded(
          child: _buildAmountItem(
            label: 'Harcanan',
            amount: budget.spent,
            color: AppColors.textPrimary,
          ),
        ),

        // Ayırıcı
        Container(
          width: 1,
          height: 32,
          color: AppColors.divider,
        ),

        // Kalan
        Expanded(
          child: _buildAmountItem(
            label: 'Kalan',
            amount: budget.remaining,
            color: budget.remaining >= 0 ? AppColors.success : AppColors.danger,
            showSign: budget.remaining < 0,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountItem({
    required String label,
    required double amount,
    required Color color,
    bool showSign = false,
  }) {
    String formattedAmount = _currencyFormat.format(amount.abs());
    if (showSign && amount < 0) {
      formattedAmount = '-$formattedAmount';
    }

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formattedAmount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Duruma göre renk döndür
  Color _getStatusColor() {
    if (budget.isOverBudget) {
      return AppColors.danger; // Kırmızı - %100+
    } else if (budget.isWarning) {
      return AppColors.warning; // Sarı - %80-99
    } else {
      return AppColors.success; // Yeşil - %0-79
    }
  }
}