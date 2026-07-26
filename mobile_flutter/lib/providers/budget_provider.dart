import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../repositories/trip_repository.dart';

class BudgetProvider extends ChangeNotifier {
  final TripRepository _repository;

  BudgetProvider({TripRepository? repository})
      : _repository = repository ?? TripRepository();

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSpent =>
      _expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

  double remaining(double budget) => budget - totalSpent;

  Map<String, double> get byCategory {
    final totals = <String, double>{};
    for (final expense in _expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  Future<void> loadExpenses(int tripId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _repository.getExpenses(tripId);
    } catch (e) {
      _error = _message(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(int tripId, Map<String, dynamic> data) async {
    _error = null;

    try {
      await _repository.createExpense(tripId, data);
      _expenses = await _repository.getExpenses(tripId);
    } catch (e) {
      _error = _message(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateExpense(int id, Map<String, dynamic> data) async {
    _error = null;

    try {
      await _repository.updateExpense(id, data);
      final tripId = _tripIdFor(id);
      if (tripId != null) {
        _expenses = await _repository.getExpenses(tripId);
      }
    } catch (e) {
      _error = _message(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int id) async {
    _error = null;

    try {
      await _repository.deleteExpense(id);
      _expenses = _expenses.where((expense) => expense.id != id).toList();
    } catch (e) {
      _error = _message(e);
    } finally {
      notifyListeners();
    }
  }

  /// Totals across every trip, used by the home dashboard stat card.
  Future<void> loadAllExpenses(List<int> tripIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final combined = <ExpenseModel>[];
      for (final tripId in tripIds) {
        combined.addAll(await _repository.getExpenses(tripId));
      }
      _expenses = combined;
    } catch (e) {
      _error = _message(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int? _tripIdFor(int expenseId) {
    for (final expense in _expenses) {
      if (expense.id == expenseId) return expense.tripId;
    }
    return _expenses.isNotEmpty ? _expenses.first.tripId : null;
  }

  String _message(Object e) => e.toString().replaceFirst('Exception: ', '');
}
