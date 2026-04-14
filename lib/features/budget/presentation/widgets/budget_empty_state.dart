// lib/features/budget/presentation/widgets/budget_empty_state.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class BudgetEmptyState extends StatelessWidget {
  final String monthLabel;
  final VoidCallback? onAddBudget;

  const BudgetEmptyState({
    super.key,
    required this.monthLabel,
    this.onAddBudget,
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
              '$monthLabel için bütçe yok',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Harcamalarınızı kontrol altında tutmak için\nkategorilere bütçe limiti belirleyin.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (onAddBudget != null) _buildAddBudgetButton(),
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
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: AppColors.primary.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildAddBudgetButton() {
    return ElevatedButton.icon(
      onPressed: onAddBudget,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Bütçe Ekle'),
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