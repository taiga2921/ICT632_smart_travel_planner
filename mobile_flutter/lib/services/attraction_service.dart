import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_config.dart';
import '../models/app_models.dart';

class AttractionService {
  final String _base = AppConfig.baseUrl;

  Future<List<AttractionResult>> getAttractions({
    required String token,
    required String location,
    String query = 'tourist attractions',
  }) async {
    final uri = Uri.parse(
      '$_base/attractions?location=${Uri.encodeComponent(location)}&query=${Uri.encodeComponent(query)}',
    );
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] as List;
      return data.map((e) => AttractionResult.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch attractions: ${response.statusCode}');
    }
  }
}
