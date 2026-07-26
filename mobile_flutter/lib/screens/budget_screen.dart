import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/budget_provider.dart';
import '../providers/trip_provider.dart';

const List<String> kExpenseCategories = [
  'food',
  'transport',
  'accommodation',
  'activity',
  'shopping',
  'other',
];

IconData expenseCategoryIcon(String category) {
  switch (category) {
    case 'food':
      return Icons.restaurant_outlined;
    case 'transport':
      return Icons.directions_bus_outlined;
    case 'accommodation':
      return Icons.apartment_outlined;
    case 'activity':
      return Icons.local_activity_outlined;
    case 'shopping':
      return Icons.shopping_bag_outlined;
    default:
      return Icons.receipt_long_outlined;
  }
}

class BudgetScreen extends StatefulWidget {
  final TripModel? trip;

  const BudgetScreen({super.key, this.trip});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  TripModel? _trip;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    _trip = widget.trip ??
        ModalRoute.of(context)?.settings.arguments as TripModel? ??
        context.read<TripProvider>().selectedTrip;

    final tripId = _trip?.id;
    if (tripId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<BudgetProvider>().loadExpenses(tripId);
      });
    }
  }

  Future<void> _openExpenseSheet({ExpenseModel? expense}) async {
    final trip = _trip;
    if (trip == null) return;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExpenseFormSheet(
        expense: expense,
        defaultCurrency: trip.currency,
      ),
    );

    if (result == null || !mounted) return;

    final provider = context.read<BudgetProvider>();
    if (expense == null) {
      await provider.addExpense(trip.id, result);
    } else {
      await provider.updateExpense(expense.id, result);
    }

    if (!mounted) return;
    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
    }
  }

  Future<void> _confirmDelete(ExpenseModel expense) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('"${expense.title}" will be removed from this trip.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;
    await context.read<BudgetProvider>().deleteExpense(expense.id);
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    final provider = context.watch<BudgetProvider>();

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Budget')),
        body: const Center(child: Text('Select a trip to track its budget.')),
      );
    }

    final spent = provider.totalSpent;
    final remaining = provider.remaining(trip.budget);
    final progress = trip.budget > 0 ? (spent / trip.budget).clamp(0.0, 1.0) : 0.0;
    final byCategory = provider.byCategory;

    return Scaffold(
      appBar: AppBar(title: Text('Budget · ${trip.title}')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadExpenses(trip.id),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: [
              _SummaryCard(
                currency: trip.currency,
                budget: trip.budget,
                spent: spent,
                remaining: remaining,
                progress: progress,
              ),
              if (byCategory.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Category breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: byCategory.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final entry = byCategory.entries.elementAt(index);
                      return _CategoryTile(
                        category: entry.key,
                        amount: entry.value,
                        currency: trip.currency,
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (provider.isLoading && provider.expenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.expenses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.savings_outlined,
                          size: 36, color: AppColors.primary),
                      SizedBox(height: 10),
                      Text(
                        'No expenses recorded',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Track what you spend to stay on budget.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                ...provider.expenses.map(
                  (expense) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ExpenseCard(
                      expense: expense,
                      onEdit: () => _openExpenseSheet(expense: expense),
                      onDelete: () => _confirmDelete(expense),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openExpenseSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String currency;
  final double budget;
  final double spent;
  final double remaining;
  final double progress;

  const _SummaryCard({
    required this.currency,
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,##0.00');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total budget',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '$currency ${format.format(budget)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.24),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% of budget used',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Pill(
                  label: 'Total spent',
                  value: '$currency ${format.format(spent)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Pill(
                  label: remaining >= 0 ? 'Remaining' : 'Over budget',
                  value: '$currency ${format.format(remaining.abs())}',
                  valueColor: remaining >= 0
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFECACA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Pill({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String category;
  final double amount;
  final String currency;

  const _CategoryTile({
    required this.category,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(expenseCategoryIcon(category), color: AppColors.primary, size: 22),
          const Spacer(),
          Text(
            category[0].toUpperCase() + category.substring(1),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            '$currency ${NumberFormat('#,##0').format(amount)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = expense.date;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
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
            child: Icon(
              expenseCategoryIcon(expense.category),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  date != null
                      ? DateFormat('d MMM yyyy').format(date)
                      : expense.expenseDate,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${expense.currency} ${NumberFormat('#,##0.00').format(expense.amount)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    visualDensity: VisualDensity.compact,
                    color: AppColors.primary,
                    tooltip: 'Edit expense',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    visualDensity: VisualDensity.compact,
                    color: AppColors.danger,
                    tooltip: 'Delete expense',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseFormSheet extends StatefulWidget {
  final ExpenseModel? expense;
  final String defaultCurrency;

  const _ExpenseFormSheet({this.expense, required this.defaultCurrency});

  @override
  State<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<_ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  late String _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense != null ? expense.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: expense?.notes ?? '');
    _category = expense?.category ?? 'other';
    if (!kExpenseCategories.contains(_category)) _category = 'other';
    _date = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'title': _titleController.text.trim(),
      'amount': double.tryParse(_amountController.text.trim()) ?? 0,
      'currency': widget.expense?.currency ?? widget.defaultCurrency,
      'category': _category,
      'expense_date': DateFormat('yyyy-MM-dd').format(_date),
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.expense == null ? 'Add expense' : 'Edit expense',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: kExpenseCategories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category[0].toUpperCase() + category.substring(1),
                          ),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _category = value ?? 'other'),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    DateFormat('d MMM yyyy').format(_date),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  widget.expense == null ? 'Add expense' : 'Save changes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
