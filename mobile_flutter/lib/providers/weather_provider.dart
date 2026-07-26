import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  CurrentWeather? _currentWeather;
  DailyForecast? _dailyForecast;
  bool _isLoading = false;
  String? _error;

  CurrentWeather? get currentWeather => _currentWeather;
  DailyForecast? get dailyForecast => _dailyForecast;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather(double lat, double lon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
      final data = await _service.getWeatherForecast(
        token: token,
        lat: lat,
        lon: lon,
      );

      final current = data['current_weather'] as Map<String, dynamic>?;
      final daily = data['daily'] as Map<String, dynamic>?;

      _currentWeather = current != null ? CurrentWeather.fromJson(current) : null;
      _dailyForecast = daily != null ? DailyForecast.fromJson(daily) : null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
