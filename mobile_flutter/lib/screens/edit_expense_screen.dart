import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late final TextEditingController _categoryController;
  late final TextEditingController _paymentController;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _notesController = TextEditingController(text: 'Planned travel spend');
    _categoryController = TextEditingController(text: widget.expense.category);
    _paymentController = TextEditingController(text: 'Card');
    _date = widget.expense.date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit expense')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category')),
            const SizedBox(height: 12),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount')),
            const SizedBox(height: 12),
            TextField(controller: _paymentController, decoration: const InputDecoration(labelText: 'Payment method')),
            const SizedBox(height: 12),
            TextField(controller: _notesController, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2024), lastDate: DateTime(2030));
                if (picked != null) setState(() => _date = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Row(children: [const Icon(Icons.calendar_month_outlined, color: AppColors.primary), const SizedBox(width: 12), Expanded(child: Text('${_date.day}/${_date.month}/${_date.year}'))]),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))), const SizedBox(width: 12), Expanded(child: FilledButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense updated'))); Navigator.of(context).pop(); }, child: const Text('Save')))]),
          ],
        ),
      ),
    );
  }
}
