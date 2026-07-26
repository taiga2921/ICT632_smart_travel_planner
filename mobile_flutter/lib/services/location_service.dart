import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';

/// Reads the country / state / city lists proxied by the Express backend.
class LocationService {
  final String _base = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> getCountries(String token) async {
    final res = await http.get(
      Uri.parse('$_base/locations/countries'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['data']);
    }
    throw Exception('Failed to load countries');
  }

  Future<List<Map<String, dynamic>>> getStates(String token, String ciso) async {
    final res = await http.get(
      Uri.parse('$_base/locations/countries/$ciso/states'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['data']);
    }
    throw Exception('Failed to load states');
  }

  Future<List<Map<String, dynamic>>> getCities(
      String token, String ciso, String siso) async {
    final res = await http.get(
      Uri.parse('$_base/locations/countries/$ciso/states/$siso/cities'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['data']);
    }
    throw Exception('Failed to load cities');
  }
}
