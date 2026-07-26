import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';
import '../services/firestore_service.dart';

class ProfileProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _firestoreService.getUserProfile(user.uid);
      if (_profile == null) {
        _profile = UserProfile(
          uid: user.uid,
          name: user.displayName ?? user.email?.split('@').first ?? 'User',
          email: user.email ?? '',
        );
        await _firestoreService.createUserProfile(_profile!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateProfile(UserProfile updated) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Not authenticated';

    try {
      await _firestoreService.updateUserProfile(updated);
      _profile = updated;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
