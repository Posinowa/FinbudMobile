import 'package:flutter/material.dart';
import '../../../../core/constants/app_color.dart';

class TransactionEmptyState extends StatelessWidget {
  final VoidCallback? onClearFilters;
  final bool hasFilters;

  const TransactionEmptyState({
    super.key,
    this.onClearFilters,
    this.hasFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Islem bulunamadi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Secili filtrelere uygun islem yok. Filtreleri temizleyip tekrar deneyebilirsiniz.'
                  : 'Henuz kayitli bir islem bulunmuyor.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters && onClearFilters != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onClearFilters,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Filtreleri temizle'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
