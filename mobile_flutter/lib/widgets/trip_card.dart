import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';

/// Status labels mirror the `trips.status` enum in MySQL.
class TripStatus {
  TripStatus._();

  static String label(String status) {
    switch (status) {
      case 'ongoing':
        return 'Current';
      case 'completed':
        return 'Completed';
      default:
        return 'Planned';
    }
  }

  static Color color(String status) {
    switch (status) {
      case 'ongoing':
        return AppColors.primary;
      case 'completed':
        return AppColors.textSecondary;
      default:
        return const Color(0xFF2563EB);
    }
  }
}

class TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const TripCard({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = TripStatus.label(trip.status);
    final color = TripStatus.color(trip.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
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
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    trip.destinationName?.isNotEmpty == true
                        ? trip.destinationName!
                        : 'No destination set',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  _dateRange(),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Budget ${trip.currency} ${NumberFormat('#,##0.00').format(trip.budget)}',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateRange() {
    final start = trip.start;
    final end = trip.end;
    if (start == null || end == null) {
      return '${trip.startDate} – ${trip.endDate}';
    }
    return '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
  }
}
