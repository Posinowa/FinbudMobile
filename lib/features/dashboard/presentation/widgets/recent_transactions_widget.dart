import 'package:flutter/material.dart';
import '../../../../core/constants/app_color.dart';
import '../../domain/models/dashboard_summary.dart';

/// Tek bir işlem satırı
class TransactionItem extends StatelessWidget {
  final RecentTransaction transaction;

  const TransactionItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Kategori ikonu
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.isIncome
                  ? AppColors.income.withOpacity(0.1)
                  : AppColors.expense.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(),
              color: transaction.isIncome ? AppColors.income : AppColors.expense,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // İşlem detayları
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isNotEmpty
                      ? transaction.description
                      : transaction.categoryName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: transaction.isIncome
                            ? AppColors.successLight
                            : AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        transaction.isIncome ? 'Gelir' : 'Gider',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: transaction.isIncome
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transaction.categoryName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatDate(transaction.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tutar
          Text(
            _formatAmount(transaction.amount, transaction.isIncome),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: transaction.isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount, bool isIncome) {
    final formatted = amount.abs().toStringAsFixed(2);
    final parts = formatted.split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    final prefix = isIncome ? '+' : '-';
    return '$prefix₺$wholePart,${parts[1]}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Bugün';
    } else if (transactionDate == yesterday) {
      return 'Dün';
    } else {
      return '${date.day} ${_getMonthName(date.month)}';
    }
  }

  String _getMonthName(int month) {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return months[month - 1];
  }

  IconData _getCategoryIcon() {
    final iconMap = {
      'food': Icons.restaurant,
      'transport': Icons.directions_car,
      'shopping': Icons.shopping_bag,
      'entertainment': Icons.movie,
      'health': Icons.medical_services,
      'salary': Icons.work,
      'investment': Icons.trending_up,
    };
    return iconMap[transaction.categoryIcon?.toLowerCase()] ??
        (transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward);
  }
}

/// Son işlemler listesi widget'ı
class RecentTransactionsList extends StatelessWidget {
  final List<RecentTransaction> transactions;
  final int maxItems;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textHint,
            ),
            SizedBox(height: 12),
            Text(
              'Henüz işlem yok',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final displayedTransactions = transactions.take(maxItems).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: displayedTransactions.map((transaction) {
            return TransactionItem(transaction: transaction);
          }).toList(),
        ),
      ),
    );
  }
}