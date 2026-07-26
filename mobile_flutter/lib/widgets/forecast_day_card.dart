import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../utils/weather_utils.dart';

/// Horizontal day-by-day forecast tile shared by the home and trip screens.
class ForecastDayCard extends StatelessWidget {
  final String date;
  final double tempMax;
  final double tempMin;
  final int weathercode;

  const ForecastDayCard({
    super.key,
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weathercode,
  });

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(date);
    final dayLabel = parsed != null ? DateFormat('EEE').format(parsed) : date;
    final dateLabel = parsed != null ? DateFormat('d MMM').format(parsed) : '';

    return Container(
      width: 116,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dayLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
            dateLabel,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Icon(WeatherCode.icon(weathercode), color: AppColors.primary, size: 26),
          const SizedBox(height: 8),
          Text(
            WeatherCode.label(weathercode),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            '${tempMax.toStringAsFixed(0)}° / ${tempMin.toStringAsFixed(0)}°',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
