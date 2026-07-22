import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../mock/mock_data.dart';
import 'attraction_detail_screen.dart';
import 'create_trip_screen.dart';

class DestinationDetailScreen extends StatelessWidget {
  final String destinationName;
  const DestinationDetailScreen({super.key, required this.destinationName});

  @override
  Widget build(BuildContext context) {
    final destination = MockData.destinations.firstWhere((item) => item.title.toLowerCase() == destinationName.toLowerCase(), orElse: () => MockData.destinations.first);
    return Scaffold(
      appBar: AppBar(title: Text(destination.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(destination.imageUrl, height: 220, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 220, color: AppColors.primary.withValues(alpha: 0.12)))),
            const SizedBox(height: 16),
            Text(destination.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(destination.country, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text(destination.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: 'Best time: Apr - Oct'),
                _InfoChip(label: 'Budget: ${destination.estimatedBudget.toStringAsFixed(0)} USD'),
                _InfoChip(label: 'Weather: Sunny'),
              ],
            ),
            const SizedBox(height: 20),
            Text('Popular attractions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...MockData.attractions.take(3).map((attraction) => Card(child: ListTile(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AttractionDetailScreen(attraction: attraction))), title: Text(attraction.name), subtitle: Text(attraction.category), trailing: const Icon(Icons.chevron_right)))),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateTripScreen())), icon: const Icon(Icons.add), label: const Text('Create trip')),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
