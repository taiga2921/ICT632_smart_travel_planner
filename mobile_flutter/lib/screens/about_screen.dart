import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart Travel Planner', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              SizedBox(height: 12),
              Text('A modern travel companion built for planning trips, tracking budgets, and exploring destinations.'),
            ],
          ),
        ),
      ),
    );
  }
}
