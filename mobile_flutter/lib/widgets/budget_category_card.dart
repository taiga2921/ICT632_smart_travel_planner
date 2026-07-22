import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/budget_service.dart';

class BudgetCategoryCard extends StatelessWidget {
  final BudgetCategoryData data;

  const BudgetCategoryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('${data.spentAmount.toStringAsFixed(0)} / ${data.allocatedBudget.toStringAsFixed(0)}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: data.progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: AppColors.border,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text('Remaining ${data.remainingAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              ),
              Text('${(data.progress * 100).toStringAsFixed(0)}%', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
