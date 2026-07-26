import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/country_provider.dart';

class CountryScreen extends StatefulWidget {
  final String? initialCountry;

  const CountryScreen({super.key, this.initialCountry});

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  late final TextEditingController _countryController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _countryController = TextEditingController(text: widget.initialCountry ?? 'Malaysia');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _search();
    });
  }

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }

  void _search() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<CountryProvider>().fetchCountryInfo(_countryController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Country Info')),
      body: SafeArea(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _countryController,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _search(),
                      decoration: const InputDecoration(
                        labelText: 'Country name',
                        hintText: 'e.g. Malaysia',
                        prefixIcon: Icon(Icons.public),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Enter a country name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: provider.isLoading ? null : _search,
                        icon: const Icon(Icons.search),
                        label: const Text('Search country'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CountryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.danger),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _search,
                child: const Text('Try a different country name'),
              ),
            ],
          ),
        ),
      );
    }

    final country = provider.country;
    if (country == null) {
      return const _MessageState(
        icon: Icons.public_outlined,
        message: 'Enter a country name and tap Search.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
              if (country.flag != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    country.flag!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: AppColors.primary.withValues(alpha: 0.12),
                      child: const Icon(Icons.flag_outlined, color: AppColors.primary),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              Text(
                country.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (country.officialName != null) ...[
                const SizedBox(height: 4),
                Text(
                  country.officialName!,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoTile(label: 'Capital', value: country.capital ?? 'Not available'),
        _InfoTile(label: 'Region', value: country.region ?? 'Not available'),
        _InfoTile(label: 'Currency', value: country.currencyLabel),
        _InfoTile(label: 'Language', value: country.languageLabel),
        _InfoTile(label: 'Timezone', value: country.timezoneLabel),
        _InfoTile(label: 'Population', value: _formatPopulation(country)),
      ],
    );
  }

  String _formatPopulation(CountryInfo country) {
    if (country.population == null) return 'Not available';
    return NumberFormat.decimalPattern().format(country.population);
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
