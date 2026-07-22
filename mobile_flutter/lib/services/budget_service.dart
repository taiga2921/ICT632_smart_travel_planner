import 'package:flutter/material.dart';
import '../models/app_models.dart';

class BudgetSummaryData {
  final double totalBudget;
  final double totalExpenses;
  final double remainingBudget;
  final double savings;
  final double percentageUsed;
  final String currency;

  BudgetSummaryData({
    required this.totalBudget,
    required this.totalExpenses,
    required this.remainingBudget,
    required this.savings,
    required this.percentageUsed,
    required this.currency,
  });
}

class BudgetCategoryData {
  final String label;
  final IconData icon;
  final double allocatedBudget;
  final double spentAmount;
  final double remainingAmount;
  final double progress;

  BudgetCategoryData({
    required this.label,
    required this.icon,
    required this.allocatedBudget,
    required this.spentAmount,
    required this.remainingAmount,
    required this.progress,
  });
}

class BudgetTransactionData {
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final String status;
  final String currency;

  BudgetTransactionData({
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
    required this.currency,
  });
}

class BudgetInsightData {
  final String title;
  final String body;
  final bool isPositive;

  BudgetInsightData({
    required this.title,
    required this.body,
    required this.isPositive,
  });
}

class BudgetService {
  static BudgetSummaryData buildSummary(Trip trip) {
    final totalExpenses = trip.expenses.fold<double>(0, (sum, item) => sum + item.amount);
    final remainingBudget = trip.budget - totalExpenses;
    final percentageUsed = trip.budget > 0 ? (totalExpenses / trip.budget).clamp(0.0, 1.0) : 0.0;
    return BudgetSummaryData(
      totalBudget: trip.budget,
      totalExpenses: totalExpenses,
      remainingBudget: remainingBudget,
      savings: remainingBudget > 0 ? remainingBudget : 0,
      percentageUsed: percentageUsed,
      currency: trip.currency,
    );
  }

  static List<BudgetCategoryData> buildCategories(Trip trip) {
    final categoryBudgets = {
      'Accommodation': 1200.0,
      'Transportation': 520.0,
      'Food': 640.0,
      'Shopping': 380.0,
      'Activities': 320.0,
      'Emergency': 220.0,
    };

    final categorySpend = <String, double>{
      'Accommodation': 0,
      'Transportation': 0,
      'Food': 0,
      'Shopping': 0,
      'Activities': 0,
      'Emergency': 0,
    };

    for (final expense in trip.expenses) {
      final label = _labelForCategory(expense.category);
      categorySpend[label] = (categorySpend[label] ?? 0) + expense.amount;
    }

    final icons = {
      'Accommodation': Icons.apartment_outlined,
      'Transportation': Icons.emoji_transportation_outlined,
      'Food': Icons.restaurant_outlined,
      'Shopping': Icons.shopping_bag_outlined,
      'Activities': Icons.local_activity_outlined,
      'Emergency': Icons.emergency_outlined,
    };

    return categoryBudgets.entries.map((entry) {
      final label = entry.key;
      final allocatedBudget = entry.value;
      final spentAmount = categorySpend[label] ?? 0;
      final remainingAmount = allocatedBudget - spentAmount;
      final progress = allocatedBudget > 0 ? (spentAmount / allocatedBudget).clamp(0.0, 1.0) : 0.0;

      return BudgetCategoryData(
        label: label,
        icon: icons[label] ?? Icons.category_outlined,
        allocatedBudget: allocatedBudget,
        spentAmount: spentAmount,
        remainingAmount: remainingAmount,
        progress: progress,
      );
    }).toList();
  }

  static List<BudgetTransactionData> buildTransactions(Trip trip) {
    final baseTransactions = trip.expenses
        .map((expense) => BudgetTransactionData(
              category: _labelForCategory(expense.category),
              description: expense.title,
              amount: expense.amount,
              date: expense.date,
              status: expense.amount > 70 ? 'Paid' : 'Planned',
              currency: expense.currency,
            ))
        .toList();

    if (baseTransactions.isEmpty) {
      baseTransactions.addAll([
        BudgetTransactionData(
          category: 'Food',
          description: 'Breakfast at local cafe',
          amount: 24,
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: 'Paid',
          currency: trip.currency,
        ),
        BudgetTransactionData(
          category: 'Transportation',
          description: 'Airport shuttle',
          amount: 18,
          date: DateTime.now().subtract(const Duration(days: 3)),
          status: 'Booked',
          currency: trip.currency,
        ),
      ]);
    }

    return baseTransactions.take(5).toList();
  }

  static List<BudgetInsightData> buildInsights(Trip trip) {
    final summary = buildSummary(trip);
    final categoryBreakdown = buildCategories(trip);
    final foodCategory = categoryBreakdown.firstWhere((item) => item.label == 'Food', orElse: () => categoryBreakdown.first);
    final transportCategory = categoryBreakdown.firstWhere((item) => item.label == 'Transportation', orElse: () => categoryBreakdown.first);

    return [
      BudgetInsightData(
        title: 'Budget status',
        body: summary.remainingBudget >= 0 ? 'You are within your budget.' : 'Your current spending is above plan.',
        isPositive: summary.remainingBudget >= 0,
      ),
      BudgetInsightData(
        title: 'Transportation focus',
        body: 'You have spent ${transportCategory.spentAmount.toStringAsFixed(0)} of your ${transportCategory.allocatedBudget.toStringAsFixed(0)} transport budget.',
        isPositive: transportCategory.progress < 0.7,
      ),
      BudgetInsightData(
        title: 'Food pacing',
        body: foodCategory.spentAmount > foodCategory.allocatedBudget * 0.5 ? 'Food expenses are higher than average for this trip.' : 'Food is staying comfortably within your plan.',
        isPositive: foodCategory.spentAmount <= foodCategory.allocatedBudget * 0.5,
      ),
    ];
  }

  static String _labelForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
      case 'transportation':
        return 'Transportation';
      case 'activity':
      case 'activities':
        return 'Activities';
      case 'food':
        return 'Food';
      case 'shopping':
        return 'Shopping';
      case 'accommodation':
        return 'Accommodation';
      case 'emergency':
        return 'Emergency';
      default:
        return 'Activities';
    }
  }
}
