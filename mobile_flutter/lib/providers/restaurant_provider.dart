import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider extends ChangeNotifier {
  final RestaurantService _service = RestaurantService();

  List<RestaurantResult> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  List<RestaurantResult> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRestaurants({
    required String location,
    String query = 'restaurants',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
      _restaurants = await _service.searchRestaurants(
        token: token,
        location: location,
        query: query,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
