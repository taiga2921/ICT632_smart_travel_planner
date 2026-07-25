import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'auth_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Join Smart Travel Planner', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Create an account to start planning your next trip.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              const TextField(decoration: InputDecoration(labelText: 'Full name')),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'Email address')),
              const SizedBox(height: 12),
              const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password')),
              const SizedBox(height: 20),
              FilledButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent'))); Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen())); }, icon: const Icon(Icons.person_add_alt_1), label: const Text('Create account')),
            ],
          ),
        ),
      ),
    );
  }
}
