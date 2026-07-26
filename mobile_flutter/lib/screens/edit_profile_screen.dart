import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../app_config.dart';
import '../models/app_models.dart';
import '../providers/profile_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _photoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    final authUser = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(
      text: profile?.name.isNotEmpty == true
          ? profile!.name
          : authUser?.displayName ?? '',
    );
    _emailController = TextEditingController(
      text: profile?.email.isNotEmpty == true
          ? profile!.email
          : authUser?.email ?? '',
    );
    _photoUrl = profile?.photoUrl.isNotEmpty == true
        ? profile!.photoUrl
        : authUser?.photoURL;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Mirrors the display name into the MySQL `users` row via Express, so trips
  /// and admin listings show the same name as Firebase Auth.
  Future<void> _updateNameOnBackend(String name) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      throw Exception('You must be signed in to update your profile');
    }

    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update name on server');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('You must be signed in to update your profile');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final newPassword = _passwordController.text;
      var emailVerificationSent = false;

      await user.updateDisplayName(newName);
      await _updateNameOnBackend(newName);

      if (!mounted) return;
      // The Firestore email is left alone: Firebase only swaps it once the new
      // address is verified, so mirroring it here would show an address the
      // account cannot yet sign in with.
      final currentProfile = context.read<ProfileProvider>().profile;
      await _firestoreService.updateUserProfile(
        currentProfile?.copyWith(name: newName) ??
            UserProfile(uid: user.uid, name: newName, email: user.email ?? ''),
      );

      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
        emailVerificationSent = true;
      }

      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      if (!mounted) return;
      await context.read<ProfileProvider>().fetchProfile();
      if (!mounted) return;

      _passwordController.clear();
      _confirmPasswordController.clear();

      _showMessage(
        emailVerificationSent
            ? 'Profile updated successfully. Check your inbox to confirm the new email.'
            : 'Profile updated successfully',
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Could not update your profile');
    } catch (e) {
      _showMessage('Could not update your profile: ${_readable(e)}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _readable(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile'), elevation: 0),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: ProfileAvatar(
                  photoUrl: _photoUrl,
                  initials: profile?.initials ?? '?',
                  size: 120,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Display name',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Name cannot be empty'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Email is required';
                  if (!email.contains('@') || !email.contains('.')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  prefixIcon: Icon(Icons.lock_outline),
                  helperText: 'Leave blank to keep your current password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
                validator: (value) {
                  if (_passwordController.text.isEmpty) return null;
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
