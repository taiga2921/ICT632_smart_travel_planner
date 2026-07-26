import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/attraction_service.dart';

class AttractionProvider extends ChangeNotifier {
  final AttractionService _service = AttractionService();

  List<AttractionResult> _attractions = [];
  bool _isLoading = false;
  String? _error;

  List<AttractionResult> get attractions => _attractions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAttractions({
    required String location,
    String query = 'tourist attractions',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
      _attractions = await _service.getAttractions(
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
