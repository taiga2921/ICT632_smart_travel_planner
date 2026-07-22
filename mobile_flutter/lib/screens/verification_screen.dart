import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 56, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Check your inbox', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('A mock verification email has been sent. Continue to sign in once you are ready.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              FilledButton.icon(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_forward), label: const Text('Continue')),
            ],
          ),
        ),
      ),
    );
  }
}
