// lib/features/transaction/presentation/widgets/transaction_filter_sheet.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/transaction_provider.dart';

class TransactionFilterSheet extends ConsumerStatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  ConsumerState<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends ConsumerState<TransactionFilterSheet> {
  String? _selectedType;
  int? _selectedMonth;
  int? _selectedYear;

  final List<String> _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  @override
  void initState() {
    super.initState();
    _initFromState();
  }

  void _initFromState() {
    final state = ref.read(transactionProvider);
    _selectedType = state.filter.type;
    
    final monthFilter = state.filter.month;
    if (monthFilter != null && monthFilter.contains('-')) {
      final parts = monthFilter.split('-');
      _selectedYear = int.tryParse(parts[0]);
      _selectedMonth = int.tryParse(parts[1]);
    }
  }

  void _applyFilters() {
    final notifier = ref.read(transactionProvider.notifier);
    
    notifier.setTypeFilter(_selectedType);
    
    if (_selectedMonth != null && _selectedYear != null) {
      final monthStr = _selectedMonth.toString().padLeft(2, '0');
      notifier.setMonthFilter('$_selectedYear-$monthStr');
    } else {
      notifier.setMonthFilter(null);
    }
    
    Navigator.pop(context);
  }

  void _clearFilters() {
    ref.read(transactionProvider.notifier).clearFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - i);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtrele',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = null;
                        _selectedMonth = null;
                        _selectedYear = null;
                      });
                    },
                    child: const Text(
                      'Sıfırla',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // İşlem Tipi
              _buildSectionTitle('İşlem Tipi'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTypeChip(
                    label: 'Tümü',
                    isSelected: _selectedType == null,
                    onTap: () => setState(() => _selectedType = null),
                  ),
                  const SizedBox(width: 10),
                  _buildTypeChip(
                    label: 'Gelir',
                    isSelected: _selectedType == 'income',
                    color: AppColors.income,
                    icon: Icons.arrow_downward_rounded,
                    onTap: () => setState(() => _selectedType = 'income'),
                  ),
                  const SizedBox(width: 10),
                  _buildTypeChip(
                    label: 'Gider',
                    isSelected: _selectedType == 'expense',
                    color: AppColors.expense,
                    icon: Icons.arrow_upward_rounded,
                    onTap: () => setState(() => _selectedType = 'expense'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Yıl
              _buildSectionTitle('Yıl'),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildOptionChip(
                      label: 'Tümü',
                      isSelected: _selectedYear == null,
                      onTap: () => setState(() {
                        _selectedYear = null;
                        _selectedMonth = null;
                      }),
                    ),
                    ...years.map((year) => Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _buildOptionChip(
                        label: year.toString(),
                        isSelected: _selectedYear == year,
                        onTap: () => setState(() => _selectedYear = year),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Ay (sadece yıl seçiliyse)
              if (_selectedYear != null) ...[
                _buildSectionTitle('Ay'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _months.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildOptionChip(
                          label: 'Tümü',
                          isSelected: _selectedMonth == null,
                          onTap: () => setState(() => _selectedMonth = null),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _buildOptionChip(
                          label: _months[index - 1],
                          isSelected: _selectedMonth == index,
                          onTap: () => setState(() => _selectedMonth = index),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Butonlar
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Temizle',
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Uygula',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required bool isSelected,
    Color? color,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    final effectiveColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? effectiveColor.withOpacity(0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? effectiveColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: isSelected ? effectiveColor : AppColors.textSecondary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? effectiveColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}