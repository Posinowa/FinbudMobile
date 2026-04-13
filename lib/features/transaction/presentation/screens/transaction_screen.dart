// lib/features/transaction/presentation/screens/transaction_list_screen.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../providers/transaction_state.dart';
import '../widgets/transaction_item.dart';
import '../widgets/transaction_empty_state.dart';
import '../widgets/transaction_filter_sheet.dart';
import '../widgets/transaction_shimmer.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // İlk yükleme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      ref.read(transactionProvider.notifier).loadMore();
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TransactionFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(state),
      body: _buildBody(state),
    );
  }

  PreferredSizeWidget _buildAppBar(TransactionState state) {
    return AppBar(
      title: const Text(
        'İşlemler',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list_rounded),
              onPressed: _showFilterSheet,
              tooltip: 'Filtrele',
            ),
            if (state.hasActiveFilters)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
      bottom: state.hasActiveFilters ? _buildFilterChips(state) : null,
    );
  }

  PreferredSize _buildFilterChips(TransactionState state) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // Tip filtresi chip
            if (state.filter.type != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  label: state.filter.type == 'income' ? 'Gelir' : 'Gider',
                  color: state.filter.type == 'income' 
                      ? AppColors.income 
                      : AppColors.expense,
                  onRemove: () => ref.read(transactionProvider.notifier).setTypeFilter(null),
                ),
              ),
            
            // Ay filtresi chip
            if (state.filter.month != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  label: _formatMonth(state.filter.month!),
                  color: AppColors.primary,
                  onRemove: () => ref.read(transactionProvider.notifier).setMonthFilter(null),
                ),
              ),

            // Tümünü temizle
            Center(
              child: TextButton(
                onPressed: () => ref.read(transactionProvider.notifier).clearFilters(),
                child: const Text(
                  'Temizle',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required Color color,
    required VoidCallback onRemove,
  }) {
    return Center(
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color.withOpacity(0.1),
        deleteIcon: Icon(Icons.close, size: 18, color: color),
        onDeleted: onRemove,
        side: BorderSide(color: color.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildBody(TransactionState state) {
    // İlk yükleme
    if (state.isLoading && state.transactions.isEmpty) {
      return const TransactionShimmer();
    }

    // Hata durumu
    if (state.hasError && state.transactions.isEmpty) {
      return _buildErrorState(state);
    }

    // Boş durum
    if (state.isEmpty) {
      return TransactionEmptyState(
        hasFilters: state.hasActiveFilters,
        onClearFilters: () => ref.read(transactionProvider.notifier).clearFilters(),
      );
    }

    // Liste
    return RefreshIndicator(
      onRefresh: () => ref.read(transactionProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.transactions.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.transactions.length) {
            return _buildLoadingIndicator(state);
          }

          final transaction = state.transactions[index];
          return TransactionItem(
            transaction: transaction,
            onTap: () => _onTransactionTap(transaction),
            onDelete: () => _onDeleteTransaction(transaction),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(TransactionState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Bilinmeyen hata',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(transactionProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(TransactionState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _onTransactionTap(transaction) {
    // TODO: Transaction detay sayfasına git
  }

  Future<void> _onDeleteTransaction(transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşlemi Sil'),
        content: const Text('Bu işlemi silmek istediğinize emin misiniz?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(transactionProvider.notifier).deleteTransaction(transaction.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('İşlem silindi'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

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