import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../mock/mock_data.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = MockData.weather;
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(forecast.summary, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('${forecast.temperature.toStringAsFixed(0)}°C • Feels like ${forecast.feelsLike.toStringAsFixed(0)}°C', style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _WeatherMetric(label: 'Precipitation', value: '${forecast.precipitation.toStringAsFixed(0)}%'),
                      const SizedBox(width: 12),
                      _WeatherMetric(label: 'Wind', value: '${forecast.windSpeed.toStringAsFixed(0)} km/h'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('7-day outlook', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...forecast.weekly.map((day) => Card(
              child: ListTile(
                leading: Text(day.icon, style: const TextStyle(fontSize: 24)),
                title: Text(day.day),
                trailing: Text('${day.high.toStringAsFixed(0)}° / ${day.low.toStringAsFixed(0)}°'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  final String label;
  final String value;

  const _WeatherMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF3F8F3), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
