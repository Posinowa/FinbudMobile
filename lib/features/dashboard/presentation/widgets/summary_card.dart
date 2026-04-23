import 'package:flutter/material.dart';
import '../../../../core/constants/app_color.dart';

/// Dashboard özet kartı widget'ı
class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showSign;
  final String? imagePath;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.showSign = false,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.card,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imagePath != null
                    ? Image.asset(imagePath!, width: 20, height: 20)
                    : Icon(
                        icon,
                        color: iconColor ?? AppColors.primary,
                        size: 20,
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatAmount(amount),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: showSign
                  ? (amount >= 0 ? AppColors.income : AppColors.expense)
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatted = amount.abs().toStringAsFixed(2);
    final parts = formatted.split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    String prefix = '';
    if (showSign && amount != 0) {
      prefix = amount > 0 ? '+' : '-';
    } else if (amount < 0) {
      prefix = '-';
    }

    return '$prefix₺$wholePart,${parts[1]}';
  }
}

/// Dashboard üst kısımdaki 3'lü özet kartları
class DashboardSummaryCards extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;

  const DashboardSummaryCards({
    super.key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bakiye kartı - Tam genişlik
        SummaryCard(
          title: 'Bakiye',
          amount: balance,
          icon: Icons.account_balance_wallet,
          iconColor: AppColors.primary,
          showSign: true,
          imagePath: 'assets/icons/dashboard_bakiye.png',
        ),
        const SizedBox(height: 12),
        // Gelir ve Gider kartları - Yan yana
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Gelir',
                amount: totalIncome,
                icon: Icons.arrow_upward,
                iconColor: AppColors.income,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Gider',
                amount: totalExpense,
                icon: Icons.arrow_downward,
                iconColor: AppColors.expense,
              ),
            ),
          ],
        ),
      ],
    );
  }
}