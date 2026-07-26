import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_config.dart';
import '../models/app_models.dart';

class CountryService {
  final String _base = AppConfig.baseUrl;

  Future<CountryInfo> getCountryInfo({
    required String token,
    required String countryName,
  }) async {
    final uri = Uri.parse(
      '$_base/country-info?name=${Uri.encodeComponent(countryName)}',
    );
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return CountryInfo.fromJson(body['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch country info: ${response.statusCode}');
    }
  }
}
