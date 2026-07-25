import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../models/app_models.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherForecast _forecast = MockData.weather;
  WeatherForecast get forecast => _forecast;

  void refreshWeather() {
    _forecast = MockData.weather;
    notifyListeners();
  }
}
