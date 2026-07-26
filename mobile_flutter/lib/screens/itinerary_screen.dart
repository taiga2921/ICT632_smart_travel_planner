import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/itinerary_provider.dart';
import '../repositories/trip_repository.dart';

const List<String> kItineraryItemTypes = [
  'activity',
  'transport',
  'food',
  'accommodation',
  'other',
];

class ItineraryScreen extends StatefulWidget {
  final ItineraryModel? itinerary;

  const ItineraryScreen({super.key, this.itinerary});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final TripRepository _repository = TripRepository();

  ItineraryModel? _itinerary;
  bool _isEditingHeader = false;
  bool _isSavingHeader = false;
  bool _didInit = false;

  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _notesController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    _itinerary = widget.itinerary ??
        ModalRoute.of(context)?.settings.arguments as ItineraryModel?;
    _titleController.text = _itinerary?.title ?? '';
    _notesController.text = _itinerary?.notes ?? '';

    final itineraryId = _itinerary?.id;
    if (itineraryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ItineraryProvider>().loadItems(itineraryId);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveHeader() async {
    final itinerary = _itinerary;
    if (itinerary == null) return;

    setState(() => _isSavingHeader = true);

    try {
      final updated = await _repository.updateItinerary(itinerary.id, {
        'title': _titleController.text.trim(),
        'notes': _notesController.text.trim(),
      });
      if (!mounted) return;
      setState(() {
        _itinerary = updated;
        _isEditingHeader = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Itinerary updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSavingHeader = false);
    }
  }

  Future<void> _openItemSheet({ItineraryItemModel? item}) async {
    final itinerary = _itinerary;
    if (itinerary == null) return;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemFormSheet(item: item),
    );

    if (result == null || !mounted) return;

    final provider = context.read<ItineraryProvider>();
    if (item == null) {
      await provider.createItem(itinerary.id, result);
    } else {
      await provider.updateItem(item.id, result);
    }

    if (!mounted) return;
    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
    }
  }

  Future<void> _confirmDelete(ItineraryItemModel item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('"${item.title}" will be removed from this day.'),
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
    await context.read<ItineraryProvider>().deleteItem(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final itinerary = _itinerary;
    final provider = context.watch<ItineraryProvider>();

    if (itinerary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Itinerary')),
        body: const Center(child: Text('Itinerary not found.')),
      );
    }

    final date = itinerary.dateTime;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          date != null ? DateFormat('EEE, d MMM').format(date) : itinerary.date,
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditingHeader ? Icons.close : Icons.edit_outlined),
            tooltip: _isEditingHeader ? 'Cancel' : 'Edit day',
            onPressed: () => setState(() {
              if (_isEditingHeader) {
                _titleController.text = itinerary.title ?? '';
                _notesController.text = itinerary.notes ?? '';
              }
              _isEditingHeader = !_isEditingHeader;
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
          children: [
            _HeaderCard(
              itinerary: itinerary,
              isEditing: _isEditingHeader,
              isSaving: _isSavingHeader,
              titleController: _titleController,
              notesController: _notesController,
              onSave: _saveHeader,
            ),
            const SizedBox(height: 24),
            const Text(
              'Plan for the day',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (provider.isLoading && provider.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.event_available_outlined,
                        size: 36, color: AppColors.primary),
                    SizedBox(height: 10),
                    Text(
                      'Nothing planned yet',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add activities, meals or transport for this day.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...provider.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ItemCard(
                    item: item,
                    onEdit: () => _openItemSheet(item: item),
                    onDelete: () => _confirmDelete(item),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openItemSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ItineraryModel itinerary;
  final bool isEditing;
  final bool isSaving;
  final TextEditingController titleController;
  final TextEditingController notesController;
  final Future<void> Function() onSave;

  const _HeaderCard({
    required this.itinerary,
    required this.isEditing,
    required this.isSaving,
    required this.titleController,
    required this.notesController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final date = itinerary.dateTime;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                date != null
                    ? DateFormat('EEEE, d MMMM yyyy').format(date)
                    : itinerary.date,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isEditing) ...[
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSaving ? null : onSave,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save day'),
              ),
            ),
          ] else ...[
            Text(
              itinerary.title?.isNotEmpty == true
                  ? itinerary.title!
                  : 'Untitled day',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (itinerary.notes?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                itinerary.notes!,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItineraryItemModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.access_time,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                _timeRange(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          if (item.description?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              item.description!,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
          if (item.location?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.location!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit item',
                color: AppColors.primary,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete item',
                color: AppColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeRange() {
    final start = item.startTime;
    final end = item.endTime;
    if (start == null && end == null) return 'All day';
    if (start != null && end != null) return '$start – $end';
    return start ?? end!;
  }
}

class _ItemFormSheet extends StatefulWidget {
  final ItineraryItemModel? item;

  const _ItemFormSheet({this.item});

  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late String _type;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _titleController = TextEditingController(text: item?.title ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _locationController = TextEditingController(text: item?.location ?? '');
    _startTime = _parseTime(item?.startTime);
    _endTime = _parseTime(item?.endTime);
    _type = item?.type ?? 'activity';
    if (!kItineraryItemTypes.contains(_type)) _type = 'activity';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? _startTime : _endTime) ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'location': _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      'start_time': _startTime == null ? null : _formatTime(_startTime!),
      'end_time': _endTime == null ? null : _formatTime(_endTime!),
      'type': _type,
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
                widget.item == null ? 'Add item' : 'Edit item',
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
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'Start time',
                      value: _startTime == null
                          ? 'Not set'
                          : _formatTime(_startTime!),
                      onTap: () => _pickTime(isStart: true),
                      onClear: _startTime == null
                          ? null
                          : () => setState(() => _startTime = null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeTile(
                      label: 'End time',
                      value:
                          _endTime == null ? 'Not set' : _formatTime(_endTime!),
                      onTap: () => _pickTime(isStart: false),
                      onClear: _endTime == null
                          ? null
                          : () => setState(() => _endTime = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: kItineraryItemTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type[0].toUpperCase() + type.substring(1)),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _type = value ?? 'activity'),
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
                child: Text(widget.item == null ? 'Add item' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _TimeTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.schedule),
          suffixIcon: onClear == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                ),
        ),
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
