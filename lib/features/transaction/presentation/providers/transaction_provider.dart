// lib/features/transaction/presentation/providers/transaction_provider.dart    
import 'package:finbud_app/features/transaction/data/models/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../data/repositories/transaction_repository.dart';
import 'transaction_state.dart';

// ============ TEST MODE - API hazır olunca false yap ============
const bool kUseMockData = true;

// ============ MOCK DATA ============
final List<TransactionModel> _mockTransactions = [
  TransactionModel(
    id: '1',
    amount: 15000.00,
    type: TransactionType.income,
    date: '2026-04-10',
    description: 'Maaş',
    category: const CategoryResponse(id: 'c1', name: 'Maaş', icon: '💰', type: 'income'),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TransactionModel(
    id: '2',
    amount: 450.50,
    type: TransactionType.expense,
    date: '2026-04-09',
    description: 'Market alışverişi',
    category: const CategoryResponse(id: 'c2', name: 'Market', icon: '🛒', type: 'expense'),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TransactionModel(
    id: '3',
    amount: 2500.00,
    type: TransactionType.expense,
    date: '2026-04-08',
    description: 'Kira ödemesi',
    category: const CategoryResponse(id: 'c3', name: 'Kira', icon: '🏠', type: 'expense'),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TransactionModel(
    id: '4',
    amount: 180.00,
    type: TransactionType.expense,
    date: '2026-04-07',
    description: 'Elektrik faturası',
    category: const CategoryResponse(id: 'c4', name: 'Faturalar', icon: '💡', type: 'expense'),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TransactionModel(
    id: '5',
    amount: 500.00,
    type: TransactionType.income,
    date: '2026-04-06',
    description: 'Freelance proje',
    category: const CategoryResponse(id: 'c5', name: 'Ek Gelir', icon: '💼', type: 'income'),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TransactionModel(
    id: '6',
    amount: 75.00,
    type: TransactionType.expense,
    date: '2026-04-05',
    description: 'Netflix + Spotify',
    category: const CategoryResponse(id: 'c6', name: 'Abonelikler', icon: '📺', type: 'expense'),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TransactionModel(
    id: '7',
    amount: 320.00,
    type: TransactionType.expense,
    date: '2026-04-04',
    description: 'Akaryakıt',
    category: const CategoryResponse(id: 'c7', name: 'Ulaşım', icon: '⛽', type: 'expense'),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TransactionModel(
    id: '8',
    amount: 1200.00,
    type: TransactionType.income,
    date: '2026-04-03',
    description: 'Yatırım getirisi',
    category: const CategoryResponse(id: 'c8', name: 'Yatırım', icon: '📈', type: 'income'),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TransactionModel(
    id: '9',
    amount: 850.00,
    type: TransactionType.expense,
    date: '2026-04-02',
    description: 'Yeni ayakkabı',
    category: const CategoryResponse(id: 'c9', name: 'Giyim', icon: '👟', type: 'expense'),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TransactionModel(
    id: '10',
    amount: 125.00,
    type: TransactionType.expense,
    date: '2026-04-01',
    description: 'Restoran',
    category: const CategoryResponse(id: 'c10', name: 'Yeme-İçme', icon: '🍽️', type: 'expense'),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

// ============ PROVIDERS ============

/// Dio Provider - Kendi dio provider'ınızla değiştirin
final dioProvider = Provider<Dio>((ref) {
  // TODO: Kendi Dio instance'ınızı buraya ekleyin
  throw UnimplementedError('dioProvider must be overridden');
});

/// Repository Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TransactionRepository(dio);
});

/// Transaction List Provider - Ana provider
final transactionProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  if (kUseMockData) {
    return TransactionNotifier.mock();
  }
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository);
});

// ============ NOTIFIER ============

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionRepository? _repository;
  final bool _useMock;

  // Normal constructor (API ile)
  TransactionNotifier(TransactionRepository repository) 
      : _repository = repository,
        _useMock = false,
        super(const TransactionState());

  // Mock constructor (Test için)
  TransactionNotifier.mock() 
      : _repository = null,
        _useMock = true,
        super(const TransactionState());

  // ============ FİLTRE İŞLEMLERİ ============

  /// Tip filtresi ayarla
  void setTypeFilter(String? type) {
    if (state.filter.type == type) return;
    
    state = state.copyWith(
      filter: state.filter.copyWith(
        type: type,
        page: 1,
        clearType: type == null,
      ),
    );
    refresh();
  }

  /// Ay filtresi ayarla (YYYY-MM formatında)
  void setMonthFilter(String? month) {
    if (state.filter.month == month) return;
    
    state = state.copyWith(
      filter: state.filter.copyWith(
        month: month,
        page: 1,
        clearMonth: month == null,
      ),
    );
    refresh();
  }

  /// Kategori filtresi ayarla
  void setCategoryFilter(String? categoryId) {
    if (state.filter.categoryId == categoryId) return;
    
    state = state.copyWith(
      filter: state.filter.copyWith(
        categoryId: categoryId,
        page: 1,
        clearCategoryId: categoryId == null,
      ),
    );
    refresh();
  }

  /// Tüm filtreleri temizle
  void clearFilters() {
    if (!state.filter.hasActiveFilters) return;
    
    state = state.copyWith(filter: const TransactionFilter());
    refresh();
  }

  // ============ VERİ İŞLEMLERİ ============

  /// İlk yükleme veya yenileme
  Future<void> refresh() async {
    state = state.copyWith(
      status: TransactionStatus.loading,
      clearError: true,
      filter: state.filter.copyWith(page: 1),
    );

    if (_useMock) {
      await _refreshMock();
    } else {
      await _refreshApi();
    }
  }

  Future<void> _refreshApi() async {
    try {
      final response = await _repository!.getTransactions(filter: state.filter);
      
      state = state.copyWith(
        transactions: response.data,
        meta: response.meta,
        status: TransactionStatus.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        status: TransactionStatus.error,
        transactions: [],
      );
    }
  }

  Future<void> _refreshMock() async {
    // Simüle edilmiş yükleme gecikmesi
    await Future.delayed(const Duration(milliseconds: 800));

    var filteredData = List<TransactionModel>.from(_mockTransactions);

    // Tip filtresi uygula
    if (state.filter.type != null) {
      filteredData = filteredData.where((t) {
        return state.filter.type == 'income' ? t.isIncome : t.isExpense;
      }).toList();
    }

    // Ay filtresi uygula
    if (state.filter.month != null) {
      filteredData = filteredData.where((t) {
        return t.date.startsWith(state.filter.month!);
      }).toList();
    }

    // Pagination
    final limit = state.filter.limit;
    final page = state.filter.page;
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    final paginatedData = filteredData.length > startIndex
        ? filteredData.sublist(
            startIndex, 
            endIndex > filteredData.length ? filteredData.length : endIndex,
          )
        : <TransactionModel>[];

    final totalPages = (filteredData.length / limit).ceil();

    state = state.copyWith(
      transactions: paginatedData,
      meta: PaginationMeta(
        total: filteredData.length,
        page: page,
        limit: limit,
        totalPages: totalPages > 0 ? totalPages : 1,
      ),
      status: TransactionStatus.loaded,
    );
  }

  /// Sonraki sayfayı yükle (infinite scroll)
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(status: TransactionStatus.loadingMore);

    if (_useMock) {
      await _loadMoreMock();
    } else {
      await _loadMoreApi();
    }
  }

  Future<void> _loadMoreApi() async {
    try {
      final newFilter = state.filter.copyWith(page: state.filter.page + 1);
      final response = await _repository!.getTransactions(filter: newFilter);
      
      state = state.copyWith(
        transactions: [...state.transactions, ...response.data],
        meta: response.meta,
        filter: newFilter,
        status: TransactionStatus.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        status: TransactionStatus.loaded,
      );
    }
  }

  Future<void> _loadMoreMock() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newPage = state.filter.page + 1;
    var filteredData = List<TransactionModel>.from(_mockTransactions);

    if (state.filter.type != null) {
      filteredData = filteredData.where((t) {
        return state.filter.type == 'income' ? t.isIncome : t.isExpense;
      }).toList();
    }

    final limit = state.filter.limit;
    final startIndex = (newPage - 1) * limit;
    final endIndex = startIndex + limit;

    final newData = filteredData.length > startIndex
        ? filteredData.sublist(
            startIndex,
            endIndex > filteredData.length ? filteredData.length : endIndex,
          )
        : <TransactionModel>[];

    final totalPages = (filteredData.length / limit).ceil();

    state = state.copyWith(
      transactions: [...state.transactions, ...newData],
      meta: PaginationMeta(
        total: filteredData.length,
        page: newPage,
        limit: limit,
        totalPages: totalPages > 0 ? totalPages : 1,
      ),
      filter: state.filter.copyWith(page: newPage),
      status: TransactionStatus.loaded,
    );
  }

  /// Transaction sil
  Future<bool> deleteTransaction(String id) async {
    if (_useMock) {
      return _deleteTransactionMock(id);
    }
    return _deleteTransactionApi(id);
  }

  Future<bool> _deleteTransactionApi(String id) async {
    try {
      await _repository!.deleteTransaction(id);
      _removeFromList(id);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> _deleteTransactionMock(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _removeFromList(id);
    return true;
  }

  void _removeFromList(String id) {
    final updatedList = state.transactions.where((t) => t.id != id).toList();
    final updatedMeta = state.meta != null
        ? PaginationMeta(
            total: state.meta!.total - 1,
            page: state.meta!.page,
            limit: state.meta!.limit,
            totalPages: state.meta!.totalPages,
          )
        : null;

    state = state.copyWith(
      transactions: updatedList,
      meta: updatedMeta,
    );
  }

  /// Yeni transaction eklendiğinde
  void onTransactionCreated(TransactionModel transaction) {
    state = state.copyWith(
      transactions: [transaction, ...state.transactions],
      meta: state.meta != null
          ? PaginationMeta(
              total: state.meta!.total + 1,
              page: state.meta!.page,
              limit: state.meta!.limit,
              totalPages: state.meta!.totalPages,
            )
          : null,
    );
  }

  /// Transaction güncellendiğinde
  void onTransactionUpdated(TransactionModel transaction) {
    final index = state.transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      final updatedList = [...state.transactions];
      updatedList[index] = transaction;
      state = state.copyWith(transactions: updatedList);
    }
  }
}