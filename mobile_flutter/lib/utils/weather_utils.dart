import 'package:flutter/material.dart';

/// Maps Open-Meteo WMO weather interpretation codes to display values.
class WeatherCode {
  WeatherCode._();

  static String label(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Showers';
      case 95:
        return 'Thunderstorm';
      default:
        return 'Cloudy';
    }
  }

  static String emoji(int code) {
    switch (code) {
      case 0:
        return '☀️';
      case 1:
      case 2:
      case 3:
        return '⛅';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
        return '🌦️';
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return '🌧️';
      case 71:
      case 73:
      case 75:
        return '❄️';
      case 95:
        return '⛈️';
      default:
        return '☁️';
    }
  }

  static IconData icon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny_outlined;
      case 1:
      case 2:
      case 3:
        return Icons.wb_cloudy_outlined;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
        return Icons.grain;
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return Icons.water_drop_outlined;
      case 71:
      case 73:
      case 75:
        return Icons.ac_unit;
      case 95:
        return Icons.thunderstorm_outlined;
      default:
        return Icons.cloud_outlined;
    }
  }
}
