import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_config.dart';
import '../models/app_models.dart';

class HotelService {
  final String _base = AppConfig.baseUrl;

  Future<List<HotelResult>> searchHotels({
    required String token,
    required String query,
    required String checkIn,
    required String checkOut,
  }) async {
    final uri = Uri.parse(
      '$_base/hotels?query=${Uri.encodeComponent(query)}&check_in=$checkIn&check_out=$checkOut',
    );
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] as List;
      return data.map((e) => HotelResult.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch hotels: ${response.statusCode}');
    }
  }
}
