import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../models/app_models.dart';

class BudgetProvider extends ChangeNotifier {
  final Trip _trip = MockData.trips.first;

  Trip get trip => _trip;

  double get totalSpent => _trip.expenses.fold<double>(0, (sum, item) => sum + item.amount);
  double get remainingBudget => _trip.budget - totalSpent;
  List<Expense> get expenses => _trip.expenses;
}
