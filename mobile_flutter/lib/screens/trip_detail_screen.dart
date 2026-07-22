import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/trip_provider.dart';
import 'budget_screen.dart';
import 'itinerary_screen.dart';

class TripDetailScreen extends StatelessWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<TripProvider>().selectedTrip;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Navigate to edit trip if needed
            },
          ),
        ],
      ),
      body: SafeArea(
        child: trip == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ---- Trip title & destination ----
                  Text(
                    trip.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${trip.destination}, ${trip.country}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // ---- Trip details card ----
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overview',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),

                          // Date range (assuming startDate and endDate exist)
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatDate(trip.startDate)} – ${_formatDate(trip.endDate)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Budget & currency
                          Row(
                            children: [
                              const Icon(Icons.attach_money, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${trip.currency} ${trip.budget.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Status
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 18),
                              const SizedBox(width: 6),
                              Text('Status: ${trip.status}'),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Notes (if any)
                          if (trip.note.isNotEmpty) ...[
                            const Divider(height: 16),
                            const Text(
                              'Notes',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(trip.note),
                          ],

                          // Created & Updated – omitted because they are not in the mock yet.
                          // Add them later when the model includes these fields.
                          // For now, we can show placeholders or skip.
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Created',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '—', // Placeholder
                                      style: const TextStyle(fontSize: 14),
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
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '—', // Placeholder
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---- Action buttons: View Itinerary & View Budget ----
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ItineraryScreen(trip: trip),
                            ),
                          ),
                          icon: const Icon(Icons.route_outlined),
                          label: const Text('View Itinerary'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BudgetScreen(trip: trip), // pass trip
                            ),
                          ),
                          icon: const Icon(Icons.pie_chart_outline),
                          label: const Text('View Budget'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---- Itinerary section (list of days) ----
                  const Text(
                    'Itinerary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),

                  if (trip.days.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No itinerary items yet.'),
                    )
                  else
                    ...trip.days.map((day) => _ItineraryDayCard(day)),
                ],
              ),
      ),
    );
  }

  // Helper to format dates (assumes DateTime)
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ---- Custom widget for a single itinerary day ----
class _ItineraryDayCard extends StatelessWidget {
  // Using dynamic type to avoid 'Day' error – we know it has 'title' and 'items'
  final dynamic day;

  const _ItineraryDayCard(this.day);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              day.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),

            // Show items count or list (since note, created/updated are not in mock)
            if (day.items.isNotEmpty) ...[
              Text(
                '${day.items.length} activities planned',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ] else ...[
              Text(
                'Relax and explore',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],

            // ---- Placeholder for note, created, updated (add later) ----
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Created',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '—', // placeholder
                        style: const TextStyle(fontSize: 12),
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
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '—', // placeholder
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}