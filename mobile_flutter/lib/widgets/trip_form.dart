import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import 'location_picker_sheet.dart';

const List<String> kCurrencies = ['MYR', 'USD', 'EUR', 'GBP', 'JPY', 'SGD', 'AUD'];

/// Single-page trip form shared by the create screen and the edit sheet.
class TripForm extends StatefulWidget {
  final TripModel? initial;
  final String submitLabel;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  const TripForm({
    super.key,
    this.initial,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<TripForm> createState() => _TripFormState();
}

class _TripFormState extends State<TripForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _budgetController;
  late final TextEditingController _notesController;

  String? _destinationName;
  DateTime? _startDate;
  DateTime? _endDate;
  late String _currency;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final trip = widget.initial;
    _titleController = TextEditingController(text: trip?.title ?? '');
    _budgetController = TextEditingController(
      text: trip != null ? trip.budget.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: trip?.notes ?? '');
    _destinationName = trip?.destinationName;
    _startDate = trip?.start;
    _endDate = trip?.end;
    _currency = trip?.currency ?? 'MYR';
    if (!kCurrencies.contains(_currency)) {
      _currency = 'MYR';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickLocation() async {
    final result = await LocationPickerSheet.show(context);
    if (result == null) return;
    setState(() => _destinationName = result);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      _showMessage('Please choose both a start and end date');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showMessage('End date must be on or after the start date');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit({
        'title': _titleController.text.trim(),
        'destination_name': _destinationName,
        'start_date': _formatDate(_startDate!),
        'end_date': _formatDate(_endDate!),
        'budget': double.tryParse(_budgetController.text.trim()) ?? 0,
        'currency': _currency,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Title',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),
          _FieldTile(
            icon: Icons.place_outlined,
            label: 'Location',
            value: _destinationName ?? 'Select country, state and city',
            isPlaceholder: _destinationName == null,
            onTap: _pickLocation,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _FieldTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Start date',
                  value: _startDate == null
                      ? 'Choose date'
                      : DateFormat('d MMM yyyy').format(_startDate!),
                  isPlaceholder: _startDate == null,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FieldTile(
                  icon: Icons.event_outlined,
                  label: 'End date',
                  value: _endDate == null
                      ? 'Choose date'
                      : DateFormat('d MMM yyyy').format(_endDate!),
                  isPlaceholder: _endDate == null,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Budget amount',
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Budget is required';
              }
              final parsed = double.tryParse(value.trim());
              if (parsed == null || parsed < 0) return 'Enter a valid amount';
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: const InputDecoration(
              labelText: 'Currency',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            items: kCurrencies
                .map((code) => DropdownMenuItem(value: code, child: Text(code)))
                .toList(),
            onChanged: (value) => setState(() => _currency = value ?? 'MYR'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPlaceholder;
  final VoidCallback onTap;

  const _FieldTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPlaceholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isPlaceholder ? AppColors.textSecondary : AppColors.textPrimary,
            fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
