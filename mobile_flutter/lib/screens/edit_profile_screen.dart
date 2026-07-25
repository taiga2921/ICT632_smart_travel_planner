import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _countryController;
  late final TextEditingController _currencyController;
  late final TextEditingController _languageController;
  late final TextEditingController _styleController;
  late final TextEditingController _emergencyController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _countryController = TextEditingController(text: profile?.country ?? '');
    _currencyController = TextEditingController(text: profile?.preferredCurrency ?? 'USD');
    _languageController = TextEditingController(text: profile?.preferredLanguage ?? 'English');
    _styleController = TextEditingController(text: profile?.travelStyle ?? 'Balanced comfort');
    _emergencyController = TextEditingController(text: profile?.emergencyContact ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _currencyController.dispose();
    _languageController.dispose();
    _styleController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final profileProvider = context.read<ProfileProvider>();
    final current = profileProvider.profile;
    if (current == null) return;

    final updated = UserProfile(
      uid: current.uid,
      name: _nameController.text.trim(),
      email: current.email,
      phone: _phoneController.text.trim(),
      country: _countryController.text.trim(),
      preferredCurrency: _currencyController.text.trim(),
      preferredLanguage: _languageController.text.trim(),
      travelStyle: _styleController.text.trim(),
      emergencyContact: _emergencyController.text.trim(),
    );

    final error = await profileProvider.updateProfile(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ---- Profile photo ----
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // Future: implement photo picker
                    },
                    child: const Text('Change photo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- Editable fields ----
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // ---- Email (read‑only) ----
            TextField(
              controller: _emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
                filled: true,
                fillColor: AppColors.surface,
              ),
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _currencyController,
              decoration: const InputDecoration(
                labelText: 'Preferred currency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _languageController,
              decoration: const InputDecoration(
                labelText: 'Preferred language',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _styleController,
              decoration: const InputDecoration(
                labelText: 'Travel style',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flight_takeoff_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emergencyController,
              decoration: const InputDecoration(
                labelText: 'Emergency contact',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.contact_emergency_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // ---- Action buttons ----
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
          ],
        ),
      ),
    );
  }
}