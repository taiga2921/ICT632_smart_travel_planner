import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/hotel_service.dart';

class HotelProvider extends ChangeNotifier {
  final HotelService _service = HotelService();

  List<HotelResult> _hotels = [];
  bool _isLoading = false;
  String? _error;

  List<HotelResult> get hotels => _hotels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHotels({
    required String query,
    required String checkIn,
    required String checkOut,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
      _hotels = await _service.searchHotels(
        token: token,
        query: query,
        checkIn: checkIn,
        checkOut: checkOut,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
