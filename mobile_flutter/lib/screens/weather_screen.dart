import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../app_config.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';

class WeatherScreen extends StatefulWidget {
  final String location;
  final double lat;
  final double lon;

  const WeatherScreen({
    super.key,
    this.location = AppConfig.defaultLocationName,
    this.lat = AppConfig.defaultLatitude,
    this.lon = AppConfig.defaultLongitude,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WeatherProvider>().fetchWeather(widget.lat, widget.lon);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Weather in ${widget.location}')),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(WeatherProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return _ErrorState(
        message: provider.error!,
        onRetry: () => provider.fetchWeather(widget.lat, widget.lon),
      );
    }

    final current = provider.currentWeather;
    final daily = provider.dailyForecast;

    if (current == null) {
      return const Center(child: Text('No weather data available.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _CurrentWeatherCard(location: widget.location, current: current),
        const SizedBox(height: 20),
        const Text('7-day outlook', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (daily == null)
          const Text('Forecast is not available right now.')
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: daily.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _DayCard(
                date: daily.time[index],
                tempMax: daily.tempMax[index],
                tempMin: daily.tempMin[index],
                weathercode: daily.weathercode[index],
              ),
            ),
          ),
      ],
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final String location;
  final CurrentWeather current;

  const _CurrentWeatherCard({required this.location, required this.current});

  @override
  Widget build(BuildContext context) {
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
              Text(
                WeatherCode.emoji(current.weathercode),
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WeatherCode.label(current.weathercode),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(location, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${current.temperature.toStringAsFixed(0)}°C',
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _WeatherMetric(
                label: 'Wind',
                value: '${current.windspeed.toStringAsFixed(0)} km/h',
              ),
              const SizedBox(width: 12),
              _WeatherMetric(label: 'Updated', value: _formatTime(current.time)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String isoTime) {
    final parsed = DateTime.tryParse(isoTime);
    if (parsed == null) return isoTime;
    return DateFormat('EEE, HH:mm').format(parsed);
  }
}

class _DayCard extends StatelessWidget {
  final String date;
  final double tempMax;
  final double tempMin;
  final int weathercode;

  const _DayCard({
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
          Text(dateLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Text(WeatherCode.emoji(weathercode), style: const TextStyle(fontSize: 26)),
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

class _WeatherMetric extends StatelessWidget {
  final String label;
  final String value;

  const _WeatherMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F8F3),
          borderRadius: BorderRadius.circular(16),
        ),
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
