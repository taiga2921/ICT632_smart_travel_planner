import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../models/app_models.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _error;
  User? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get firebaseUser => _user;
  String get userName => _user?.displayName ?? _user?.email?.split('@').first ?? 'User';
  String get userEmail => _user?.email ?? '';
  ApiService get apiService => _apiService;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    _user = user;
    _isAuthenticated = user != null;
    _isLoading = false;

    if (user != null) {
      final token = await user.getIdToken();
      _apiService.setToken(token);
      await _authService.saveIdToken();
    } else {
      _apiService.setToken(null);
      await _authService.clearSavedToken();
    }

    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signIn(email, password);
      _error = null;
      return null;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e);
      return _error;
    } catch (e) {
      _error = 'An unexpected error occurred';
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.signUp(email, password);
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();

      final uid = credential.user?.uid;
      if (uid != null) {
        final firestoreService = FirestoreService();
        await firestoreService.createUserProfile(UserProfile(
          uid: uid,
          name: name,
          email: email,
        ));
      }

      _error = null;
      return null;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e);
      return _error;
    } catch (e) {
      _error = 'An unexpected error occurred';
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _isAuthenticated = false;
    _user = null;
    _apiService.setToken(null);
    notifyListeners();
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    _error = null;
    try {
      await _authService.sendPasswordResetEmail(email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<void> refreshToken() async {
    if (_user != null) {
      final token = await _user!.getIdToken(true);
      _apiService.setToken(token);
      await _authService.saveIdToken();
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters)';
      case 'invalid-email':
        return 'Invalid email address';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
