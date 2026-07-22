import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reset your password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('We will send a verification code to your email.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              const TextField(decoration: InputDecoration(labelText: 'Email address')),
              const SizedBox(height: 20),
              FilledButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent'))); Navigator.of(context).pop(); }, icon: const Icon(Icons.send_outlined), label: const Text('Send link')),
            ],
          ),
        ),
      ),
    );
  }
}
