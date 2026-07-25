import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';

class AttractionDetailScreen extends StatelessWidget {
  final Attraction attraction;
  const AttractionDetailScreen({super.key, required this.attraction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(attraction.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(attraction.imageUrl, height: 220, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 220, color: AppColors.primary.withValues(alpha: 0.12)))),
            const SizedBox(height: 16),
            Text(attraction.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(attraction.category, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text(attraction.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick info', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Opening hours', value: '08:00 - 18:00'),
                  _InfoRow(label: 'Ticket price', value: 'USD 15'),
                  _InfoRow(label: 'Rating', value: '4.8/5'),
                  _InfoRow(label: 'Location', value: 'Central district'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attraction saved'))); }, icon: const Icon(Icons.bookmark_add_outlined), label: const Text('Save attraction')),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: AppColors.textSecondary))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
