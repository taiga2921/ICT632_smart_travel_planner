import 'package:flutter/material.dart';
import '../mock/mock_data.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = true;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> signIn() async {
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    notifyListeners();
  }

  String get userName => MockData.user.name;
}
