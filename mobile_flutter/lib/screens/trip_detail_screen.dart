import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import '../widgets/trip_form.dart';
import 'budget_screen.dart';
import 'itinerary_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final TripModel? trip;

  const TripDetailScreen({super.key, this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  TripModel? _trip;
  bool _didInit = false;
  bool _isDeleting = false;

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
        context.read<TripProvider>().loadItineraries(tripId);
      });
    }
  }

  Future<void> _openEditSheet(TripModel trip) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.9,
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
              const Text(
                'Edit trip',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              TripForm(
                initial: trip,
                submitLabel: 'Save changes',
                onSubmit: (data) => _saveTrip(sheetContext, trip.id, data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTrip(
    BuildContext sheetContext,
    int tripId,
    Map<String, dynamic> data,
  ) async {
    final tripProvider = context.read<TripProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await tripProvider.updateTrip(tripId, {...data, 'status': _trip?.status});

    if (tripProvider.error != null) {
      messenger.showSnackBar(SnackBar(content: Text(tripProvider.error!)));
      return;
    }

    if (!mounted) return;
    setState(() => _trip = tripProvider.selectedTrip ?? _trip);
    messenger.showSnackBar(
      const SnackBar(content: Text('Trip updated successfully')),
    );
    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
  }

  Future<void> _confirmDeleteTrip(TripModel trip) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete trip?'),
        content: Text(
          '"${trip.title}" and all its itineraries and expenses will be '
          'permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    final tripProvider = context.read<TripProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isDeleting = true);
    await tripProvider.deleteTrip(trip.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (tripProvider.error != null) {
      messenger.showSnackBar(SnackBar(content: Text(tripProvider.error!)));
      return;
    }

    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Trip deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final trip = tripProvider.selectedTrip?.id == _trip?.id
        ? (tripProvider.selectedTrip ?? _trip)
        : _trip;

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip details')),
        body: const Center(child: Text('Trip not found.')),
      );
    }

    final itineraries = tripProvider.itineraries
        .where((itinerary) => itinerary.tripId == trip.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit trip',
            onPressed: () => _openEditSheet(trip),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete trip',
            onPressed: _isDeleting ? null : () => _confirmDeleteTrip(trip),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            _TripInfoCard(trip: trip),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BudgetScreen(trip: trip)),
                    ),
                    icon: const Icon(Icons.pie_chart_outline),
                    label: const Text('Budget'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Itinerary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${itineraries.length} day${itineraries.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (tripProvider.isLoading && itineraries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (itineraries.isEmpty)
              const Text(
                'No itinerary days for this trip yet.',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              ...itineraries.map(
                (itinerary) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ItineraryRow(
                    itinerary: itinerary,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ItineraryScreen(itinerary: itinerary),
                        ),
                      );
                      if (!context.mounted) return;
                      await context
                          .read<TripProvider>()
                          .loadItineraries(trip.id);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TripInfoCard extends StatelessWidget {
  final TripModel trip;

  const _TripInfoCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final statusColor = TripStatus.color(trip.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  trip.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  TripStatus.label(trip.status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.place_outlined,
            label: trip.destinationName?.isNotEmpty == true
                ? trip.destinationName!
                : 'No destination set',
          ),
          const SizedBox(height: 10),
          _DetailRow(icon: Icons.calendar_today_outlined, label: _dateRange()),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.account_balance_wallet_outlined,
            label:
                '${trip.currency} ${NumberFormat('#,##0.00').format(trip.budget)}',
          ),
          if (trip.notes?.trim().isNotEmpty == true) ...[
            const Divider(height: 28),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              trip.notes!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  String _dateRange() {
    final start = trip.start;
    final end = trip.end;
    if (start == null || end == null) {
      return '${trip.startDate} – ${trip.endDate}';
    }
    return '${DateFormat('d MMM yyyy').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _ItineraryRow extends StatelessWidget {
  final ItineraryModel itinerary;
  final VoidCallback onTap;

  const _ItineraryRow({required this.itinerary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = itinerary.dateTime;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
              child: const Icon(Icons.event_note_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date != null
                        ? DateFormat('EEE, d MMM').format(date)
                        : itinerary.date,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    itinerary.title?.isNotEmpty == true
                        ? itinerary.title!
                        : 'Untitled day',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
