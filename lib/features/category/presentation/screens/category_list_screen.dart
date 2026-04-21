// lib/features/category/presentation/screens/category_list_screen.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:finbud_app/core/utils/app_snackbar.dart';
import 'package:finbud_app/features/category/data/models/category_model.dart';
import 'package:finbud_app/features/category/presentation/providers/category_provider.dart';
import 'package:finbud_app/features/category/presentation/widgets/category_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profil ekranından açılan kategori listesi ve yönetim ekranı.
/// Sistem kategorileri (salt-okunur) ve kullanıcı kategorileri (düzenlenebilir)
/// ayrı bölümlerde gösterilir.
class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(categoryProvider);
      if (!state.isLoaded) {
        ref.read(categoryProvider.notifier).loadCategories();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Kategoriler',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Varsayılan'),
            Tab(text: 'Benim Kategorilerim'),
          ],
        ),
      ),
      body: categoryState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : categoryState.hasError
              ? _buildError(categoryState.errorMessage)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _SystemCategoriesTab(
                      categories: categoryState.categories
                          .where((c) => c.isSystemCategory)
                          .toList(),
                    ),
                    _UserCategoriesTab(
                      categories: categoryState.categories
                          .where((c) => !c.isSystemCategory)
                          .toList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildError(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              message ?? 'Kategoriler yüklenemedi',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.read(categoryProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sistem (Varsayılan) Kategoriler sekmesi - salt okunur
// ─────────────────────────────────────────────────────────────────────────────
class _SystemCategoriesTab extends StatelessWidget {
  final List<CategoryModel> categories;

  const _SystemCategoriesTab({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'Varsayılan kategori bulunamadı',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final incomeCategories = categories.where((c) => c.type == 'income').toList();
    final expenseCategories = categories.where((c) => c.type == 'expense').toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _InfoBanner(
          icon: Icons.lock_outline,
          message: 'Varsayılan kategoriler düzenlenemez ve silinemez.',
        ),
        const SizedBox(height: 16),
        if (incomeCategories.isNotEmpty) ...[
          _SectionHeader(
            label: 'Gelir',
            color: AppColors.income,
            icon: Icons.arrow_downward_rounded,
          ),
          const SizedBox(height: 8),
          ...incomeCategories.map((c) => _ReadOnlyCategoryTile(category: c)),
          const SizedBox(height: 20),
        ],
        if (expenseCategories.isNotEmpty) ...[
          _SectionHeader(
            label: 'Gider',
            color: AppColors.expense,
            icon: Icons.arrow_upward_rounded,
          ),
          const SizedBox(height: 8),
          ...expenseCategories.map((c) => _ReadOnlyCategoryTile(category: c)),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kullanıcı Kategorileri sekmesi - düzenlenebilir
// ─────────────────────────────────────────────────────────────────────────────
class _UserCategoriesTab extends ConsumerWidget {
  final List<CategoryModel> categories;

  const _UserCategoriesTab({required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.category_outlined,
                size: 56,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              const Text(
                'Henüz kendi kategoriniz yok',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gelir/Gider ekleme ekranındaki\n"Kategori Ekle" butonuyla\nkendi kategorilerinizi oluşturabilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final incomeCategories = categories.where((c) => c.type == 'income').toList();
    final expenseCategories = categories.where((c) => c.type == 'expense').toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (incomeCategories.isNotEmpty) ...[
          _SectionHeader(
            label: 'Gelir',
            color: AppColors.income,
            icon: Icons.arrow_downward_rounded,
          ),
          const SizedBox(height: 8),
          ...incomeCategories.map(
            (c) => _EditableCategoryTile(
              category: c,
              onEdit: () => _showEditSheet(context, ref, c),
              onDelete: () => _confirmDelete(context, ref, c),
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (expenseCategories.isNotEmpty) ...[
          _SectionHeader(
            label: 'Gider',
            color: AppColors.expense,
            icon: Icons.arrow_upward_rounded,
          ),
          const SizedBox(height: 8),
          ...expenseCategories.map(
            (c) => _EditableCategoryTile(
              category: c,
              onEdit: () => _showEditSheet(context, ref, c),
              onDelete: () => _confirmDelete(context, ref, c),
            ),
          ),
        ],
      ],
    );
  }

  void _showEditSheet(
      BuildContext context, WidgetRef ref, CategoryModel category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditCategorySheet(category: category),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Kategoriyi Sil'),
        content: Text(
          '"${category.name}" kategorisini silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(categoryProvider.notifier)
                  .deleteCategory(category.id);
              if (context.mounted) {
                if (success) {
                  AppSnackBar.showSuccess(context, '"${category.name}" silindi');
                } else {
                  AppSnackBar.showError(context, 'Kategori silinirken hata oluştu');
                }
              }
            },
            child: const Text(
              'Sil',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Salt-okunur kategori satırı (sistem kategorileri için)
// ─────────────────────────────────────────────────────────────────────────────
class _ReadOnlyCategoryTile extends StatelessWidget {
  final CategoryModel category;

  const _ReadOnlyCategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: CategoryIconWidget(icon: category.icon ?? 'assets/icons/koli.png', size: 24),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.lock_outline,
          size: 18,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Düzenlenebilir kategori satırı
// ─────────────────────────────────────────────────────────────────────────────
class _EditableCategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EditableCategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: CategoryIconWidget(icon: category.icon ?? 'assets/icons/koli.png', size: 24),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 20, color: AppColors.primary),
              onPressed: onEdit,
              tooltip: 'Düzenle',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.danger),
              onPressed: onDelete,
              tooltip: 'Sil',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Salt-okunur kategori grid (sistem kategorileri için)
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final bool isReadOnly;

  const _CategoryGrid({required this.categories, this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final c = categories[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CategoryIconWidget(icon: c.icon ?? kDefaultCategoryIcon, size: 24),
              const SizedBox(height: 6),
              Text(
                c.name,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bölüm başlığı
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bilgi banner'ı (sistem kategorileri için uyarı)
// ─────────────────────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String message;

  const _InfoBanner({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kategori Düzenleme Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _EditCategorySheet extends ConsumerStatefulWidget {
  final CategoryModel category;

  const _EditCategorySheet({required this.category});

  @override
  ConsumerState<_EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends ConsumerState<_EditCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedIcon;
  late String _selectedType;
  bool _isLoading = false;

  static const List<String> _emojiOptions = kCategoryIconOptions;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.icon ?? 'assets/icons/koli.png';
    _selectedType = widget.category.type;
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
                        'Kategoriyi Düzenle',
                        style: TextStyle(
                          fontSize: 20,
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
                  const SizedBox(height: 20),

                  // Tip seçimi
                  _buildTypeSelector(),
                  const SizedBox(height: 20),

                  // İsim alanı
                  _buildNameField(),
                  const SizedBox(height: 20),

                  // İkon seçici
                  _buildIconPicker(),
                  const SizedBox(height: 32),

                  // Kaydet butonu
                  _buildSaveButton(),
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
              Expanded(child: _typeButton('Gider', 'expense', AppColors.expense)),
              Expanded(child: _typeButton('Gelir', 'income', AppColors.income)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _typeButton(String label, String value, Color color) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
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
            hintText: 'Kategori adı',
            hintStyle: const TextStyle(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
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
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'Kategori adı gerekli';
            if (val.trim().length < 2) return 'En az 2 karakter girin';
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(categoryProvider.notifier).updateCategory(
        id: widget.category.id,
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        type: _selectedType,
      );
      if (!mounted) return;
      if (success) {
        Navigator.pop(context);
        AppSnackBar.showSuccess(context, 'Kategori güncellendi');
      } else {
        AppSnackBar.showError(context, 'Kategori güncellenemedi');
      }
    } catch (_) {
      if (mounted) AppSnackBar.showError(context, 'Bir hata oluştu');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: CategoryIconWidget(icon: _selectedIcon, size: 22),
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
                onTap: () => setState(() => _selectedIcon = emoji),
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
                  child: CategoryIconWidget(icon: emoji, size: 26),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text('Kaydet'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────