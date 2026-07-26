import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../app_config.dart';

class GeocodeResult {
  final double latitude;
  final double longitude;
  final String name;
  final String? country;

  const GeocodeResult({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.country,
  });

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    return GeocodeResult(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String? ?? '',
      country: json['country'] as String?,
    );
  }
}

/// Turns a stored destination name into coordinates so screens never have to
/// ask the user to type latitude and longitude by hand.
class GeocodeService {
  Future<GeocodeResult?> getCoordinates(String locationName) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
      final uri = Uri.parse(
        '${AppConfig.baseUrl}/geocode?location=${Uri.encodeComponent(locationName)}',
      );
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return GeocodeResult.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
