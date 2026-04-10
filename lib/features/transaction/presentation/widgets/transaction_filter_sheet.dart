import 'package:flutter/material.dart';
import '../../../../core/constants/app_color.dart';
import '../../data/models/transaction_model.dart';

class TransactionFilterResult {
  final TransactionType? type;
  final String? month;

  const TransactionFilterResult({
    required this.type,
    required this.month,
  });
}

class TransactionFilterSheet extends StatefulWidget {
  final TransactionType? selectedType;
  final String? selectedMonth;

  const TransactionFilterSheet({
    super.key,
    required this.selectedType,
    required this.selectedMonth,
  });

  static Future<TransactionFilterResult?> show(
    BuildContext context, {
    required TransactionType? selectedType,
    required String? selectedMonth,
  }) {
    return showModalBottomSheet<TransactionFilterResult>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TransactionFilterSheet(
        selectedType: selectedType,
        selectedMonth: selectedMonth,
      ),
    );
  }

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late TransactionType? _type;
  late String? _month;

  @override
  void initState() {
    super.initState();
    _type = widget.selectedType;
    _month = widget.selectedMonth;
  }

  @override
  Widget build(BuildContext context) {
    final months = _buildLast12Months();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filtrele',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Islem tipi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TypeChip(
                  label: 'Tum',
                  selected: _type == null,
                  onTap: () => setState(() => _type = null),
                ),
                _TypeChip(
                  label: 'Gelir',
                  selected: _type == TransactionType.income,
                  color: AppColors.income,
                  onTap: () => setState(() => _type = TransactionType.income),
                ),
                _TypeChip(
                  label: 'Gider',
                  selected: _type == TransactionType.expense,
                  color: AppColors.expense,
                  onTap: () => setState(() => _type = TransactionType.expense),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Ay',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: months.map((month) {
                final selected = _month == month.value;
                return ChoiceChip(
                  label: Text(month.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _month = month.value),
                  backgroundColor: AppColors.background,
                  selectedColor: AppColors.primary.withValues(alpha: 0.14),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _type = null;
                        _month = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: const Text('Temizle'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        TransactionFilterResult(type: _type, month: _month),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                    child: const Text('Uygula'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_MonthItem> _buildLast12Months() {
    final now = DateTime.now();
    const monthNames = [
      'Ocak',
      'Subat',
      'Mart',
      'Nisan',
      'Mayis',
      'Haziran',
      'Temmuz',
      'Agustos',
      'Eylul',
      'Ekim',
      'Kasim',
      'Aralik',
    ];

    return List.generate(12, (index) {
      final date = DateTime(now.year, now.month - index, 1);
      final value = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final label = '${monthNames[date.month - 1]} ${date.year}';
      return _MonthItem(value: value, label: label);
    });
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.background,
      selectedColor: color.withValues(alpha: 0.14),
      labelStyle: TextStyle(
        color: selected ? color : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? color : AppColors.border,
      ),
    );
  }
}

class _MonthItem {
  final String value;
  final String label;

  const _MonthItem({
    required this.value,
    required this.label,
  });
}
