import 'package:flutter/material.dart';
import '../mock/mock_data.dart';
import '../models/app_models.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile _profile = MockData.user;
  UserProfile get profile => _profile;

  void refreshProfile() {
    _profile = MockData.user;
    notifyListeners();
  }
}
