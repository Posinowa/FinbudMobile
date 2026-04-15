// lib/features/category/presentation/widgets/add_category_sheet.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:finbud_app/core/utils/app_snackbar.dart';
import 'package:finbud_app/features/category/presentation/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Yeni kategori oluşturma bottom sheet'i
/// [initialType] - Açılırken hangi tipin seçili olacağı ('income' veya 'expense')
/// [onCategoryCreated] - Kategori oluşturulunca dönen callback
class AddCategorySheet extends ConsumerStatefulWidget {
  final String initialType;
  final void Function(String categoryId)? onCategoryCreated;

  const AddCategorySheet({
    super.key,
    this.initialType = 'expense',
    this.onCategoryCreated,
  });

  @override
  ConsumerState<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<AddCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedIcon = '📦';
  bool _isLoading = false;

  /// Seçilebilecek emojiler
  static const List<String> _emojiOptions = [
    // Gider emojileri
    '🛒', '🏠', '💡', '🚗', '🍽️', '🏥', '🎬', '👕', '📚', '📺',
    '✈️', '🎮', '💄', '🐾', '🔧', '⚽', '🎵', '📦', '🛍️', '☕',
    '🍕', '💊', '🏋️', '🎓', '🚌', '🛺', '🏪', '🧾', '📱', '💻',
    // Gelir emojileri
    '💰', '💼', '📈', '🎁', '🏦', '💵', '🤝', '🏆', '⭐', '🌟',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
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
                        'Kategori Ekle',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Kategori Tipi
                  _buildTypeSelector(),
                  const SizedBox(height: 20),

                  // Kategori Adı
                  _buildNameField(),
                  const SizedBox(height: 20),

                  // İkon Seçici
                  _buildIconPicker(),
                  const SizedBox(height: 32),

                  // Kaydet Butonu
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Tipi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  label: 'Gider',
                  value: 'expense',
                  color: AppColors.expense,
                ),
              ),
              Expanded(
                child: _buildTypeButton(
                  label: 'Gelir',
                  value: 'income',
                  color: AppColors.income,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required String label,
    required String value,
    required Color color,
  }) {
    final isSelected = _selectedType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? color : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Adı',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          maxLength: 30,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Örn: Spor, Kafe, Hobi...',
            hintStyle: const TextStyle(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterStyle: const TextStyle(color: AppColors.textHint),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Kategori adı gerekli';
            }
            if (value.trim().length < 2) {
              return 'En az 2 karakter girin';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildIconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'İkon Seç',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            // Seçili ikon önizlemesi
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                _selectedIcon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _emojiOptions.length,
            itemBuilder: (context, index) {
              final emoji = _emojiOptions[index];
              final isSelected = _selectedIcon == emoji;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = emoji;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final color =
        _selectedType == 'income' ? AppColors.income : AppColors.expense;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Kategori Oluştur',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newCategory = await ref
          .read(categoryProvider.notifier)
          .createCategory(
            name: _nameController.text.trim(),
            icon: _selectedIcon,
            type: _selectedType,
          );

      if (mounted) {
        if (newCategory != null) {
          Navigator.pop(context);
          AppSnackBar.showSuccess(
            context,
            '${_nameController.text.trim()} kategorisi oluşturuldu',
          );
          widget.onCategoryCreated?.call(newCategory.id);
        } else {
          AppSnackBar.showError(context, 'Kategori oluşturulurken bir hata oluştu');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Hata: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
