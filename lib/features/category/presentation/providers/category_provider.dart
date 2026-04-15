// lib/features/category/presentation/providers/category_provider.dart

import 'package:finbud_app/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

// ============ TEST MODE - API hazır olunca false yap ============
const bool kUseMockCategoryData = false;

// ============ MOCK DATA ============
final List<CategoryModel> _mockCategories = [
  // Gelir kategorileri
  const CategoryModel(id: 'c1', name: 'Maaş', icon: '💰', type: 'income'),
  const CategoryModel(id: 'c2', name: 'Ek Gelir', icon: '💼', type: 'income'),
  const CategoryModel(id: 'c3', name: 'Yatırım Getirisi', icon: '📈', type: 'income'),
  const CategoryModel(id: 'c4', name: 'Freelance', icon: '💻', type: 'income'),
  const CategoryModel(id: 'c5', name: 'Hediye', icon: '🎁', type: 'income'),
  
  // Gider kategorileri
  const CategoryModel(id: 'c10', name: 'Market', icon: '🛒', type: 'expense'),
  const CategoryModel(id: 'c11', name: 'Kira', icon: '🏠', type: 'expense'),
  const CategoryModel(id: 'c12', name: 'Faturalar', icon: '💡', type: 'expense'),
  const CategoryModel(id: 'c13', name: 'Ulaşım', icon: '🚗', type: 'expense'),
  const CategoryModel(id: 'c14', name: 'Yeme-İçme', icon: '🍽️', type: 'expense'),
  const CategoryModel(id: 'c15', name: 'Sağlık', icon: '🏥', type: 'expense'),
  const CategoryModel(id: 'c16', name: 'Eğlence', icon: '🎬', type: 'expense'),
  const CategoryModel(id: 'c17', name: 'Giyim', icon: '👕', type: 'expense'),
  const CategoryModel(id: 'c18', name: 'Eğitim', icon: '📚', type: 'expense'),
  const CategoryModel(id: 'c19', name: 'Abonelikler', icon: '📺', type: 'expense'),
  const CategoryModel(id: 'c20', name: 'Diğer', icon: '📦', type: 'expense'),
];

// ============ STATE ============

enum CategoryStatus { initial, loading, loaded, error }

class CategoryState {
  final List<CategoryModel> categories;
  final CategoryStatus status;
  final String? errorMessage;

  const CategoryState({
    this.categories = const [],
    this.status = CategoryStatus.initial,
    this.errorMessage,
  });

  CategoryState copyWith({
    List<CategoryModel>? categories,
    CategoryStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isLoading => status == CategoryStatus.loading;
  bool get hasError => status == CategoryStatus.error;
  bool get isLoaded => status == CategoryStatus.loaded;

  /// Gelir kategorileri
  List<CategoryModel> get incomeCategories =>
      categories.where((c) => c.type == 'income').toList();

  /// Gider kategorileri
  List<CategoryModel> get expenseCategories =>
      categories.where((c) => c.type == 'expense').toList();

  /// Tipe göre kategorileri getir
  List<CategoryModel> getCategoriesByType(String type) {
    return categories.where((c) => c.type == type).toList();
  }
}

// ============ PROVIDERS ============

/// Repository Provider - DioClient.instance kullanıyor
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(DioClient.instance);
});

/// Category Provider - Ana provider
final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  if (kUseMockCategoryData) {
    return CategoryNotifier.mock();
  }
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryNotifier(repository);
});

/// Sadece gelir kategorileri
final incomeCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(categoryProvider).incomeCategories;
});

/// Sadece gider kategorileri
final expenseCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(categoryProvider).expenseCategories;
});


// ============ NOTIFIER ============

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository? _repository;
  final bool _useMock;

  CategoryNotifier(CategoryRepository repository)
      : _repository = repository,
        _useMock = false,
        super(const CategoryState());

  CategoryNotifier.mock()
      : _repository = null,
        _useMock = true,
        super(const CategoryState());

  /// Kategorileri yükle
  Future<void> loadCategories() async {
    if (state.isLoaded) return; // Zaten yüklenmişse tekrar yükleme

    state = state.copyWith(status: CategoryStatus.loading, clearError: true);

    if (_useMock) {
      await _loadMock();
    } else {
      await _loadFromApi();
    }
  }

  Future<void> _loadFromApi() async {
    try {
      final categories = await _repository!.getCategories();
      state = state.copyWith(
        categories: categories,
        status: CategoryStatus.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        status: CategoryStatus.error,
      );
    }
  }

  Future<void> _loadMock() async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(
      categories: _mockCategories,
      status: CategoryStatus.loaded,
    );
  }

  /// Yeni kategori oluştur
  /// Başarılı olursa yeni kategori state'e eklenir ve döndürülür
  Future<CategoryModel?> createCategory({
    required String name,
    required String icon,
    required String type,
  }) async {
    if (_useMock) {
      // Mock modda sahte kategori ekle
      final newCategory = CategoryModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        icon: icon,
        type: type,
        userId: 'mock_user',
      );
      state = state.copyWith(
        categories: [...state.categories, newCategory],
      );
      return newCategory;
    }

    try {
      final newCategory = await _repository!.createCategory(
        name: name,
        icon: icon,
        type: type,
      );
      state = state.copyWith(
        categories: [...state.categories, newCategory],
      );
      return newCategory;
    } catch (e) {
      return null;
    }
  }

  /// Kategori güncelle
  Future<bool> updateCategory({
    required String id,
    required String name,
    required String icon,
    required String type,
  }) async {
    if (_useMock) {
      final updated = state.categories.map((c) {
        if (c.id == id) {
          return CategoryModel(
            id: c.id,
            name: name,
            icon: icon,
            type: type,
            userId: c.userId,
          );
        }
        return c;
      }).toList();
      state = state.copyWith(categories: updated);
      return true;
    }

    try {
      final updatedCategory = await _repository!.updateCategory(
        id: id,
        name: name,
        icon: icon,
        type: type,
      );
      final updated = state.categories.map((c) {
        return c.id == id ? updatedCategory : c;
      }).toList();
      state = state.copyWith(categories: updated);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Kategori sil
  Future<bool> deleteCategory(String id) async {
    if (_useMock) {
      final updated = state.categories.where((c) => c.id != id).toList();
      state = state.copyWith(categories: updated);
      return true;
    }

    try {
      await _repository!.deleteCategory(id);
      final updated = state.categories.where((c) => c.id != id).toList();
      state = state.copyWith(categories: updated);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Kategorileri yenile
  Future<void> refresh() async {
    state = state.copyWith(status: CategoryStatus.loading, clearError: true);

    if (_useMock) {
      await _loadMock();
    } else {
      await _loadFromApi();
    }
  }

  /// Tipe göre kategorileri getir
  List<CategoryModel> getCategoriesByType(String type) {
    return state.getCategoriesByType(type);
  }
}