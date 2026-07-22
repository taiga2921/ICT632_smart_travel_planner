import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';

class ItineraryScreen extends StatelessWidget {
  final Trip trip;
  const ItineraryScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    // If the trip has no days, provide a default day with a placeholder item
    final days = trip.days.isEmpty
        ? [
            TripDay(
              id: 'day1',
              title: 'Day 1',
              date: trip.startDate,
              items: [
                ItineraryItem(
                  id: 'default',
                  title: 'No itinerary items',
                  description: 'Add activities for this day.',
                  location: trip.destination,
                  startTime: '09:00',
                  endTime: '17:00',
                  type: 'General',
                  // createdAt and updatedAt may be missing – we'll handle later
                ),
              ],
            ),
          ]
        : trip.days;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary'),
        actions: [
          // Optional: add an edit or add button
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ---- Trip summary header ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.destination,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${days.length} day${days.length > 1 ? 's' : ''} • ${_countActivities(days)} activities',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- List of days and their items ----
            ...days.map((day) => _DayCard(day: day)),
          ],
        ),
      ),
    );
  }

  // Helper: count total activities across all days
  int _countActivities(List<TripDay> days) {
    return days.fold(0, (sum, day) => sum + day.items.length);
  }
}

// ---- Widget for a single day ----
class _DayCard extends StatelessWidget {
  final TripDay day;

  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  day.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              // Date is non‑nullable, so display directly
              Text(
                '${day.date.day}/${day.date.month}',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // List of items for this day
          if (day.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No activities planned for this day.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...day.items.map((item) => _ItineraryItemCard(item: item)),
        ],
      ),
    );
  }
}

// ---- Widget for a single itinerary item (activity) ----
class _ItineraryItemCard extends StatelessWidget {
  final ItineraryItem item;

  const _ItineraryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + type badge
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 4),

          // Description
          if (item.description.isNotEmpty) ...[
            Text(
              item.description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Location
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.location.isNotEmpty ? item.location : 'No location',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Time range: start time – end time
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${item.startTime.isNotEmpty ? item.startTime : '--:--'} – ${item.endTime.isNotEmpty ? item.endTime : '--:--'}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Created at & Updated at (if available)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Created',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _formatDateTime(item.createdAt),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Updated',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _formatDateTime(item.updatedAt),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper: format DateTime (if null, show '—')
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '—';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}