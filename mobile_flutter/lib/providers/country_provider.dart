import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/country_service.dart';

class CountryProvider extends ChangeNotifier {
  final CountryService _service = CountryService();

  CountryInfo? _country;
  bool _isLoading = false;
  String? _error;

  CountryInfo? get country => _country;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCountryInfo(String countryName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
      _country = await _service.getCountryInfo(
        token: token,
        countryName: countryName,
      );
    } catch (e) {
      _error = e.toString();
      _country = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
