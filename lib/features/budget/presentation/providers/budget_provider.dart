// lib/features/budget/presentation/providers/budget_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finbud_app/core/network/dio_client.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';
import 'budget_state.dart';

// ============ TEST MODE - API hazır olunca false yap ============
const bool kBudgetUseMockData = false;

// ============ MOCK DATA ============
final List<BudgetModel> _mockBudgets = [
  const BudgetModel(
    id: '1',
    category: BudgetCategoryResponse(
      id: 'c1',
      name: 'Market',
      icon: '🛒',
      type: 'expense',
    ),
    limit: 2000.0,
    spent: 1850.0,
    remaining: 150.0,
    percentUsed: 92.5,
  ),
  const BudgetModel(
    id: '2',
    category: BudgetCategoryResponse(
      id: 'c2',
      name: 'Ulaşım',
      icon: '🚗',
      type: 'expense',
    ),
    limit: 1000.0,
    spent: 1150.0,
    remaining: -150.0,
    percentUsed: 115.0,
  ),
  const BudgetModel(
    id: '3',
    category: BudgetCategoryResponse(
      id: 'c3',
      name: 'Eğlence',
      icon: '🎬',
      type: 'expense',
    ),
    limit: 500.0,
    spent: 320.0,
    remaining: 180.0,
    percentUsed: 64.0,
  ),
  const BudgetModel(
    id: '4',
    category: BudgetCategoryResponse(
      id: 'c4',
      name: 'Faturalar',
      icon: '💡',
      type: 'expense',
    ),
    limit: 800.0,
    spent: 650.0,
    remaining: 150.0,
    percentUsed: 81.25,
  ),
  const BudgetModel(
    id: '5',
    category: BudgetCategoryResponse(
      id: 'c5',
      name: 'Sağlık',
      icon: '💊',
      type: 'expense',
    ),
    limit: 300.0,
    spent: 120.0,
    remaining: 180.0,
    percentUsed: 40.0,
  ),
];

// ============ PROVIDERS ============

/// Repository Provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(DioClient.instance);
});

/// Budget Provider - Ana provider
final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  if (kBudgetUseMockData) {
    return BudgetNotifier.mock();
  }
  final repository = ref.watch(budgetRepositoryProvider);
  return BudgetNotifier(repository);
});

// ============ NOTIFIER ============

class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetRepository? _repository;
  final bool _useMock;

  // Normal constructor (API ile)
  BudgetNotifier(BudgetRepository repository)
      : _repository = repository,
        _useMock = false,
        super(BudgetState.initial());

  // Mock constructor (Test için)
  BudgetNotifier.mock()
      : _repository = null,
        _useMock = true,
        super(BudgetState.initial());

  // ============ AY SEÇİMİ ============

  /// Ay değiştir ve verileri yükle
  void setMonth(String month) {
    if (state.selectedMonth == month) return;

    state = state.copyWith(
      selectedMonth: month,
      status: BudgetStatus.initial,
    );
    loadBudgets();
  }

  /// Önceki aya git
  void previousMonth() {
    final parts = state.selectedMonth.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]);

    month--;
    if (month < 1) {
      month = 12;
      year--;
    }

    final newMonth = '$year-${month.toString().padLeft(2, '0')}';
    setMonth(newMonth);
  }

  /// Sonraki aya git
  void nextMonth() {
    final parts = state.selectedMonth.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]);

    month++;
    if (month > 12) {
      month = 1;
      year++;
    }

    final newMonth = '$year-${month.toString().padLeft(2, '0')}';
    setMonth(newMonth);
  }

  // ============ VERİ İŞLEMLERİ ============

  /// Bütçeleri yükle
  Future<void> loadBudgets() async {
    state = state.copyWith(
      status: BudgetStatus.loading,
      clearError: true,
    );

    if (_useMock) {
      await _loadBudgetsMock();
    } else {
      await _loadBudgetsApi();
    }
  }

  Future<void> _loadBudgetsApi() async {
    try {
      final response = await _repository!.getBudgets(month: state.selectedMonth);

      state = state.copyWith(
        budgets: response.data,
        status: BudgetStatus.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        status: BudgetStatus.error,
        budgets: [],
      );
    }
  }

  Future<void> _loadBudgetsMock() async {
    // Simüle edilmiş yükleme gecikmesi
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data'yı kopyala
    state = state.copyWith(
      budgets: List.from(_mockBudgets),
      status: BudgetStatus.loaded,
    );
  }

  /// Yenile (pull-to-refresh)
  Future<void> refresh() async {
    await loadBudgets();
  }

  /// Budget sil
  Future<bool> deleteBudget(String id) async {
    if (_useMock) {
      return _deleteBudgetMock(id);
    }
    return _deleteBudgetApi(id);
  }

  Future<bool> _deleteBudgetApi(String id) async {
    try {
      await _repository!.deleteBudget(id);
      _removeFromList(id);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> _deleteBudgetMock(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _removeFromList(id);
    return true;
  }

  void _removeFromList(String id) {
    final updatedList = state.budgets.where((b) => b.id != id).toList();
    state = state.copyWith(budgets: updatedList);
  }

  /// Yeni budget oluşturulduğunda listeye ekle
  void onBudgetCreated(BudgetModel budget) {
    state = state.copyWith(
      budgets: [budget, ...state.budgets],
    );
  }

  /// Budget güncellendiğinde listede güncelle
  void onBudgetUpdated(BudgetModel budget) {
    final index = state.budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      final updatedList = [...state.budgets];
      updatedList[index] = budget;
      state = state.copyWith(budgets: updatedList);
    }
  }
}