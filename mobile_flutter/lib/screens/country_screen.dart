import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../mock/mock_data.dart';

class CountryScreen extends StatelessWidget {
  const CountryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final country = MockData.country;
    return Scaffold(
      appBar: AppBar(title: const Text('Country Info')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(country.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(country.region, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(country.flagUrl, height: 120, fit: BoxFit.cover)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InfoTile(label: 'Capital', value: country.capital),
            _InfoTile(label: 'Currency', value: country.currency),
            _InfoTile(label: 'Language', value: country.language),
            _InfoTile(label: 'Timezone', value: country.timezone),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
