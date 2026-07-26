import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_config.dart';
import '../models/app_models.dart';

class RestaurantService {
  final String _base = AppConfig.baseUrl;

  Future<List<RestaurantResult>> searchRestaurants({
    required String token,
    required String location,
    String query = 'restaurants',
  }) async {
    final uri = Uri.parse(
      '$_base/restaurants?location=${Uri.encodeComponent(location)}&query=${Uri.encodeComponent(query)}',
    );
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] as List;
      return data.map((e) => RestaurantResult.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch restaurants: ${response.statusCode}');
    }
  }
}
