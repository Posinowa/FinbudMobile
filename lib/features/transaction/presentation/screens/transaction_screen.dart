import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_color.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/transaction_state.dart';
import '../widgets/transaction_empty_state.dart';
import '../widgets/transaction_filter_sheet.dart';
import '../widgets/transaction_item.dart';
import '../widgets/transaction_shimmer.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      ref.read(transactionProvider.notifier).loadMore();
    }
  }

  Future<void> _openFilterSheet() async {
    final selectedType = ref.read(selectedTransactionTypeProvider);
    final selectedMonth = ref.read(selectedTransactionMonthProvider);

    final result = await TransactionFilterSheet.show(
      context,
      selectedType: selectedType,
      selectedMonth: selectedMonth,
    );

    if (result == null) return;

    await ref.read(transactionProvider.notifier).updateFilters(
          type: result.type,
          month: result.month,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);
    final selectedType = ref.watch(selectedTransactionTypeProvider);
    final selectedMonth = ref.watch(selectedTransactionMonthProvider);
    final hasFilters = selectedType != null || selectedMonth != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Islemler'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openFilterSheet,
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrele',
          ),
        ],
        bottom: state.isInitialLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: Column(
        children: [
          if (hasFilters)
            _ActiveFilterBar(
              selectedType: selectedType,
              selectedMonth: selectedMonth,
              onClearAll: () =>
                  ref.read(transactionProvider.notifier).clearFilters(),
            ),
          Expanded(
            child: _buildBody(state, hasFilters),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TransactionState state, bool hasFilters) {
    if (state.isInitialLoading && state.transactions.isEmpty) {
      return const TransactionShimmer();
    }

    if (state.hasError && state.transactions.isEmpty) {
      return _InitialErrorView(
        message: state.errorMessage ?? 'Islemler yuklenemedi.',
        onRetry: () => ref.read(transactionProvider.notifier).retryInitial(),
      );
    }

    if (state.isEmpty) {
      return TransactionEmptyState(
        hasFilters: hasFilters,
        onClearFilters: hasFilters
            ? () => ref.read(transactionProvider.notifier).clearFilters()
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(transactionProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: state.transactions.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == state.transactions.length) {
            if (state.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
              );
            }
            if (state.hasLoadMoreError) {
              return _LoadMoreErrorRow(
                message: state.loadMoreError ?? 'Daha fazla veri yuklenemedi.',
                onRetry: () => ref.read(transactionProvider.notifier).retryLoadMore(),
              );
            }
            return const SizedBox.shrink();
          }
          return TransactionListItem(transaction: state.transactions[index]);
        },
      ),
    );
  }
}

class _ActiveFilterBar extends StatelessWidget {
  final TransactionType? selectedType;
  final String? selectedMonth;
  final VoidCallback onClearAll;

  const _ActiveFilterBar({
    required this.selectedType,
    required this.selectedMonth,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (selectedType != null)
            Chip(
              label: Text(selectedType == TransactionType.income ? 'Gelir' : 'Gider'),
              backgroundColor: (selectedType == TransactionType.income
                      ? AppColors.income
                      : AppColors.expense)
                  .withValues(alpha: 0.14),
              side: BorderSide.none,
              labelStyle: TextStyle(
                color: selectedType == TransactionType.income
                    ? AppColors.income
                    : AppColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (selectedMonth != null)
            Chip(
              label: Text(selectedMonth!),
              backgroundColor: AppColors.primary.withValues(alpha: 0.14),
              side: BorderSide.none,
              labelStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ActionChip(
            label: const Text('Temizle'),
            onPressed: onClearAll,
            avatar: const Icon(Icons.clear, size: 16),
            backgroundColor: AppColors.background,
          ),
        ],
      ),
    );
  }
}

class _InitialErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InitialErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 42),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreErrorRow extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadMoreErrorRow({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Yeniden dene'),
          ),
        ],
      ),
    );
  }
}