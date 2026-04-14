import 'package:flutter/material.dart';
import '../../../../core/constants/app_color.dart';

/// Basit gelir-gider sütun grafiği
class IncomeExpenseChart extends StatelessWidget {
  final double income;
  final double expense;

  const IncomeExpenseChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = income > expense ? income : expense;
    final incomeHeight = maxValue > 0 ? (income / maxValue) : 0.0;
    final expenseHeight = maxValue > 0 ? (expense / maxValue) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gelir - Gider Karşılaştırması',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 185,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(
                  label: 'Gelir',
                  value: income,
                  heightRatio: incomeHeight,
                  color: AppColors.income,
                  icon: Icons.arrow_downward,
                ),
                const SizedBox(width: 48),
                _buildBar(
                  label: 'Gider',
                  value: expense,
                  heightRatio: expenseHeight,
                  color: AppColors.expense,
                  icon: Icons.arrow_upward,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildNetStatus(),
        ],
      ),
    );
  }

  Widget _buildBar({
    required String label,
    required double value,
    required double heightRatio,
    required Color color,
    required IconData icon,
  }) {
    const maxBarHeight = 120.0;
    final barHeight = (heightRatio * maxBarHeight).clamp(8.0, maxBarHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          _formatAmount(value),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          width: 56,
          height: barHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNetStatus() {
    final net = income - expense;
    final isPositive = net >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.income.withOpacity(0.1)
            : AppColors.expense.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? AppColors.income : AppColors.expense,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Net: ${isPositive ? '+' : ''}${_formatAmount(net)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
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
}