// lib/features/budget/presentation/screens/edit_budget_screen.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:finbud_app/core/utils/app_snackbar.dart';
import 'package:finbud_app/features/budget/data/models/budget_model.dart';
import 'package:finbud_app/features/category/presentation/widgets/category_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/budget_provider.dart';

/// KAN-88: Budget düzenleme ekranı
/// Mevcut budget verilerini form'a doldurur ve PUT /budgets/{id} ile günceller
class EditBudgetScreen extends ConsumerStatefulWidget {
  final BudgetModel budget;

  const EditBudgetScreen({super.key, required this.budget});

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mevcut budget limitini form'a doldur
    _limitController = TextEditingController(
      text: widget.budget.limit.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bütçe Düzenle',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Kategori Bilgisi (salt okunur)
            _buildSectionTitle('Kategori'),
            const SizedBox(height: 12),
            _buildCategoryInfo(),

            const SizedBox(height: 28),

            // Mevcut Durum Özeti
            _buildSectionTitle('Mevcut Durum'),
            const SizedBox(height: 12),
            _buildCurrentStatus(),

            const SizedBox(height: 28),

            // Limit Girişi (düzenlenebilir)
            _buildSectionTitle('Yeni Bütçe Limiti'),
            const SizedBox(height: 12),
            _buildLimitField(),

            const SizedBox(height: 12),

            // Limit değişikliği bilgisi
            _buildLimitChangeInfo(),

            const SizedBox(height: 40),

            // Kaydet Butonu
            _buildSaveButton(),
          ],
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
      ),
    );
  }

  Widget _buildCategoryInfo() {
    final category = widget.budget.category;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Kategori ikonu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CategoryIconWidget(
                icon: category.icon ?? kDefaultCategoryIcon,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Kategori adı ve tipi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.type == 'expense' ? 'Gider Kategorisi' : 'Gelir Kategorisi',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Kilitleme ikonu (değiştirilemez)
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus() {
    final budget = widget.budget;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: budget.progressValue,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                budget.isOverBudget
                    ? AppColors.danger
                    : budget.isWarning
                        ? AppColors.warning
                        : AppColors.success,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          // İstatistikler
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Harcanan',
                  '₺${budget.spent.toStringAsFixed(2)}',
                  AppColors.textPrimary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.border,
              ),
              Expanded(
                child: _buildStatItem(
                  'Kalan',
                  '₺${budget.remaining.toStringAsFixed(2)}',
                  budget.remaining >= 0 ? AppColors.success : AppColors.danger,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.border,
              ),
              Expanded(
                child: _buildStatItem(
                  'Kullanım',
                  '%${budget.percentUsed.toStringAsFixed(1)}',
                  budget.isOverBudget
                      ? AppColors.danger
                      : budget.isWarning
                          ? AppColors.warning
                          : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLimitField() {
    return TextFormField(
      controller: _limitController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        hintText: '0.00',
        prefixText: '₺ ',
        prefixStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bir limit girin';
        }
        final limit = double.tryParse(value);
        if (limit == null || limit <= 0) {
          return 'Geçerli bir tutar girin';
        }
        return null;
      },
    );
  }

  Widget _buildLimitChangeInfo() {
    final currentLimit = widget.budget.limit;
    final newLimitText = _limitController.text;
    final newLimit = double.tryParse(newLimitText) ?? currentLimit;
    final difference = newLimit - currentLimit;

    if (difference == 0) {
      return const SizedBox.shrink();
    }

    final isIncrease = difference > 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isIncrease 
            ? AppColors.success.withOpacity(0.1) 
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isIncrease ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: isIncrease ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isIncrease
                ? '+₺${difference.toStringAsFixed(2)} artış'
                : '₺${difference.abs().toStringAsFixed(2)} azalış',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isIncrease ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Değişiklikleri Kaydet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final newLimit = double.parse(_limitController.text);
    
    // Eğer limit değişmediyse uyarı ver
    if (newLimit == widget.budget.limit) {
      AppSnackBar.showInfo(context, 'Limit değişmedi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(budgetProvider.notifier).updateBudget(
        id: widget.budget.id,
        limit: newLimit,
      );

      if (!mounted) return;

      if (success) {
        AppSnackBar.showSuccess(context, 'Bütçe başarıyla güncellendi');
        context.pop();
      } else {
        final errorMessage = ref.read(budgetProvider).errorMessage;
        AppSnackBar.showError(context, errorMessage ?? 'Bir hata oluştu');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}