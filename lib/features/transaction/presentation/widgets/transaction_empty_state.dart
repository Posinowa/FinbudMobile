// lib/features/transaction/presentation/widgets/transaction_empty_state.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';


class TransactionEmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback? onClearFilters;
  final VoidCallback? onAddTransaction;

  const TransactionEmptyState({
    super.key,
    this.hasFilters = false,
    this.onClearFilters,
    this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 32),
            Text(
              hasFilters ? 'Sonuç bulunamadı' : 'Henüz işlem yok',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'Seçilen filtrelere uygun işlem bulunamadı.\nFiltreleri değiştirmeyi deneyin.'
                  : 'İlk işleminizi ekleyerek\ngelir ve giderlerinizi takip etmeye başlayın.',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (hasFilters && onClearFilters != null)
              _buildClearFiltersButton()
            else if (!hasFilters && onAddTransaction != null)
              _buildAddTransactionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            hasFilters ? Icons.search_off_rounded : Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.primary.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildClearFiltersButton() {
    return OutlinedButton.icon(
      onPressed: onClearFilters,
      icon: const Icon(Icons.filter_alt_off_rounded),
      label: const Text('Filtreleri Temizle'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAddTransactionButton() {
    return ElevatedButton.icon(
      onPressed: onAddTransaction,
      icon: const Icon(Icons.add_rounded),
      label: const Text('İşlem Ekle'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}