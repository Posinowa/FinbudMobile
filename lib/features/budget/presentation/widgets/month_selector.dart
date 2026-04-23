// lib/features/budget/presentation/widgets/month_selector.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  final String selectedMonth; // YYYY-MM formatında
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback? onMonthTap;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Önceki ay butonu
          _buildArrowButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPreviousMonth,
          ),

          // Ay gösterimi
          GestureDetector(
            onTap: onMonthTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: Image.asset(
                      'assets/icons/dashboard_takvim.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatMonth(selectedMonth),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sonraki ay butonu
          _buildArrowButton(
            icon: Icons.chevron_right_rounded,
            onTap: _canGoNext() ? onNextMonth : null,
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.background : AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isEnabled ? AppColors.textPrimary : AppColors.textHint,
            size: 24,
          ),
        ),
      ),
    );
  }

  /// Sonraki aya gidebilir mi? (Gelecek aylara izin verme)
  bool _canGoNext() {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return selectedMonth.compareTo(currentMonth) < 0;
  }

  /// Ay formatla (YYYY-MM -> Nisan 2026)
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