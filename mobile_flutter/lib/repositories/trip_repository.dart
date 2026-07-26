import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/app_models.dart';

/// Talks to the Express backend for everything under a trip: the trip record
/// itself, its daily itineraries, the items inside a day, and its expenses.
class TripRepository {
  final String _base = AppConfig.baseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      throw Exception('You must be signed in to manage trips');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  dynamic _decode(http.Response response, String action) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body)['data'];
    }

    String message = 'Failed to $action (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] is String) {
        message = body['message'] as String;
      }
    } catch (_) {
      // Non-JSON error body — keep the generic message.
    }
    throw Exception(message);
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is! List) return const [];
    return data.cast<Map<String, dynamic>>();
  }

  // ---- Trips ----

  Future<List<TripModel>> getAllTrips({String? status}) async {
    final uri = Uri.parse(
      status == null || status.isEmpty
          ? '$_base/trips'
          : '$_base/trips?status=$status',
    );
    final response = await http.get(uri, headers: await _headers());
    final data = _decode(response, 'load trips');
    return _asList(data).map(TripModel.fromJson).toList();
  }

  Future<TripModel> getTripById(int id) async {
    final response = await http.get(
      Uri.parse('$_base/trips/$id'),
      headers: await _headers(),
    );
    return TripModel.fromJson(_decode(response, 'load trip'));
  }

  Future<TripModel> createTrip(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_base/trips'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return TripModel.fromJson(_decode(response, 'create trip'));
  }

  Future<TripModel> updateTrip(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_base/trips/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return TripModel.fromJson(_decode(response, 'update trip'));
  }

  Future<void> deleteTrip(int id) async {
    final response = await http.delete(
      Uri.parse('$_base/trips/$id'),
      headers: await _headers(),
    );
    _decode(response, 'delete trip');
  }

  // ---- Itineraries ----

  Future<List<ItineraryModel>> getItineraries(int tripId) async {
    final response = await http.get(
      Uri.parse('$_base/trips/$tripId/itineraries'),
      headers: await _headers(),
    );
    final data = _decode(response, 'load itineraries');
    return _asList(data).map(ItineraryModel.fromJson).toList();
  }

  Future<ItineraryModel> updateItinerary(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$_base/itineraries/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return ItineraryModel.fromJson(_decode(response, 'update itinerary'));
  }

  // ---- Itinerary items ----

  Future<List<ItineraryItemModel>> getItineraryItems(int itineraryId) async {
    final response = await http.get(
      Uri.parse('$_base/itineraries/$itineraryId/items'),
      headers: await _headers(),
    );
    final data = _decode(response, 'load itinerary items');
    return _asList(data).map(ItineraryItemModel.fromJson).toList();
  }

  Future<ItineraryItemModel> createItineraryItem(
    int itineraryId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$_base/itineraries/$itineraryId/items'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return ItineraryItemModel.fromJson(_decode(response, 'create item'));
  }

  Future<void> updateItineraryItem(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_base/itinerary-items/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    _decode(response, 'update item');
  }

  Future<void> deleteItineraryItem(int id) async {
    final response = await http.delete(
      Uri.parse('$_base/itinerary-items/$id'),
      headers: await _headers(),
    );
    _decode(response, 'delete item');
  }

  // ---- Expenses ----

  Future<List<ExpenseModel>> getExpenses(int tripId) async {
    final response = await http.get(
      Uri.parse('$_base/trips/$tripId/expenses'),
      headers: await _headers(),
    );
    final data = _decode(response, 'load expenses');
    return _asList(data).map(ExpenseModel.fromJson).toList();
  }

  Future<ExpenseModel> createExpense(
    int tripId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$_base/trips/$tripId/expenses'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return ExpenseModel.fromJson(_decode(response, 'create expense'));
  }

  Future<void> updateExpense(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_base/expenses/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    _decode(response, 'update expense');
  }

  Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse('$_base/expenses/$id'),
      headers: await _headers(),
    );
    _decode(response, 'delete expense');
  }
}
