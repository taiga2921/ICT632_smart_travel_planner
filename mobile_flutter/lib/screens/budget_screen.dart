import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../services/budget_service.dart';
import '../widgets/budget_category_card.dart';
import 'edit_expense_screen.dart';

class BudgetScreen extends StatelessWidget {
  final Trip trip;

  const BudgetScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final summary = BudgetService.buildSummary(trip);
    final categories = BudgetService.buildCategories(trip);
    final transactions = BudgetService.buildTransactions(trip);
    final insights = BudgetService.buildInsights(trip);

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ---- Budget summary hero ----
            Hero(
              tag: 'budget-summary',
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Budget summary',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999)),
                          child: Text(
                            '${(summary.percentageUsed * 100).toStringAsFixed(0)}% used',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${summary.currency} ${summary.totalExpenses.toStringAsFixed(0)} / ${summary.totalBudget.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Remaining ${summary.currency} ${summary.remainingBudget.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 92,
                          height: 92,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 92,
                                height: 92,
                                child: CircularProgressIndicator(
                                  value: summary.percentageUsed,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.2),
                                  color: Colors.white,
                                  strokeWidth: 10,
                                ),
                              ),
                              Text(
                                '${(summary.percentageUsed * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _SummaryPill(
                            label: 'Total budget',
                            value:
                                '${summary.currency} ${summary.totalBudget.toStringAsFixed(0)}'),
                        const SizedBox(width: 10),
                        _SummaryPill(
                            label: 'Savings',
                            value:
                                '${summary.currency} ${summary.savings.toStringAsFixed(0)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---- Expense categories ----
            Text(
              'Expense categories',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...categories.map((category) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BudgetCategoryCard(data: category),
                )),
            const SizedBox(height: 20),

            // ---- Recent transactions ----
            Text(
              'Recent transactions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...transactions.map((transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditExpenseScreen(
                          expense: Expense(
                            id: 'txn_${transaction.description}',
                            title: transaction.description,
                            category: transaction.category,
                            amount: transaction.amount,
                            currency: transaction.currency,
                            date: transaction.date,
                          ),
                        ),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.receipt_long,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction.description,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(transaction.category,
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  '${transaction.currency} ${transaction.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                  '${transaction.date.day}/${transaction.date.month}',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                              Text(
                                transaction.status,
                                style: TextStyle(
                                  color: transaction.status == 'Paid'
                                      ? AppColors.primary
                                      : AppColors.warning,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 20),

            // ---- Budget insights ----
            Text(
              'Budget insights',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        insight.isPositive
                            ? Icons.check_circle_outline
                            : Icons.lightbulb_outline,
                        color: insight.isPositive
                            ? AppColors.primary
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(insight.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(insight.body,
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),

            // ---- Currency info ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currency info',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Current currency', value: summary.currency),
                  _InfoRow(
                      label: 'Exchange rate', value: '1 USD = 1.00 USD'),
                  _InfoRow(
                      label: 'Estimated daily spend',
                      value:
                          '${summary.currency} ${((summary.totalBudget / 7) / 2).toStringAsFixed(0)}'),
                ],
              ),
            ),
          ],
        ),
      ),
      // ----- FLOATING ACTION BUTTON REMOVED -----
    );
  }
}

// ---- Helper widgets (unchanged) ----
class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(color: AppColors.textSecondary))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}