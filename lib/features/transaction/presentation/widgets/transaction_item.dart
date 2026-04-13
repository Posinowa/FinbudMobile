// lib/features/transaction/presentation/widgets/transaction_item.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Renk kodlaması: Gelir = Yeşil (income), Gider = Kırmızı (expense)
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final backgroundColor = isIncome ? AppColors.successLight : AppColors.dangerLight;
    final sign = isIncome ? '+' : '-';

    // Tarih formatı
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');
    final formattedDate = dateFormat.format(transaction.dateTime);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        onDelete?.call();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Sol: İkon
              _buildIcon(color, backgroundColor),
              const SizedBox(width: 14),

              // Orta: Açıklama ve tarih
              Expanded(child: _buildContent(formattedDate)),

              // Sağ: Tutar
              _buildAmount(sign, color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, Color backgroundColor) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(
          transaction.isIncome
              ? Icons.arrow_downward_rounded
              : Icons.arrow_upward_rounded,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildContent(String formattedDate) {
    final title = transaction.description?.isNotEmpty == true
        ? transaction.description!
        : transaction.category.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (transaction.category.icon != null) ...[
              Text(transaction.category.icon!, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                transaction.category.name,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.textHint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmount(String sign, Color color) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    final formattedAmount = formatter.format(transaction.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$sign$formattedAmount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            transaction.isIncome ? 'Gelir' : 'Gider',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}