// lib/features/budget/presentation/widgets/budget_shimmer.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class BudgetShimmer extends StatefulWidget {
  const BudgetShimmer({super.key});

  @override
  State<BudgetShimmer> createState() => _BudgetShimmerState();
}

class _BudgetShimmerState extends State<BudgetShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Ay seçici shimmer
              _buildMonthSelectorShimmer(),
              const SizedBox(height: 20),
              
              // Budget kartları shimmer
              ...List.generate(4, (index) => _buildCardShimmer()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthSelectorShimmer() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildShimmerBox(width: 40, height: 40, borderRadius: 8),
          _buildShimmerBox(width: 120, height: 24, borderRadius: 6),
          _buildShimmerBox(width: 40, height: 40, borderRadius: 8),
        ],
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildShimmerBox(width: 44, height: 44, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(width: 100, height: 16, borderRadius: 4),
                    const SizedBox(height: 6),
                    _buildShimmerBox(width: 80, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              _buildShimmerBox(width: 60, height: 28, borderRadius: 14),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          _buildShimmerBox(width: double.infinity, height: 8, borderRadius: 4),
          const SizedBox(height: 12),
          
          // Amounts
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildShimmerBox(width: 60, height: 12, borderRadius: 4),
                    const SizedBox(height: 4),
                    _buildShimmerBox(width: 80, height: 16, borderRadius: 4),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.divider),
              Expanded(
                child: Column(
                  children: [
                    _buildShimmerBox(width: 50, height: 12, borderRadius: 4),
                    const SizedBox(height: 4),
                    _buildShimmerBox(width: 70, height: 16, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(_animation.value, 0),
          end: Alignment(_animation.value + 1, 0),
          colors: [
            AppColors.border,
            AppColors.border.withOpacity(0.5),
            AppColors.border,
          ],
        ),
      ),
    );
  }
}