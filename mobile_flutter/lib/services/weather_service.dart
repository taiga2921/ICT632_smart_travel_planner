import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_config.dart';

class WeatherService {
  final String _base = AppConfig.baseUrl;

  Future<Map<String, dynamic>> getWeatherForecast({
    required String token,
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse('$_base/weather?lat=$lat&lon=$lon');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch weather: ${response.statusCode}');
    }
  }
}
