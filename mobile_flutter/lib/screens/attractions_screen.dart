import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_config.dart';
import '../constants/app_colors.dart';
import '../providers/attraction_provider.dart';
import '../widgets/result_card.dart';

class AttractionsScreen extends StatefulWidget {
  final String? initialLocation;

  const AttractionsScreen({super.key, this.initialLocation});

  @override
  State<AttractionsScreen> createState() => _AttractionsScreenState();
}

class _AttractionsScreenState extends State<AttractionsScreen> {
  late final TextEditingController _locationController;
  final _queryController = TextEditingController(text: 'tourist attractions');
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: widget.initialLocation ?? AppConfig.defaultLocationName,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _search();
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _search() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AttractionProvider>().fetchAttractions(
          location: _locationController.text.trim(),
          query: _queryController.text.trim().isEmpty
              ? 'tourist attractions'
              : _queryController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttractionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Attractions')),
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
                      controller: _locationController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g. Kuala Lumpur',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Enter a location'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _queryController,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _search(),
                      decoration: const InputDecoration(
                        labelText: 'What are you looking for?',
                        hintText: 'e.g. tourist attractions',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: provider.isLoading ? null : _search,
                        icon: const Icon(Icons.travel_explore),
                        label: const Text('Search attractions'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _buildResults(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(AttractionProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return _MessageState(icon: Icons.error_outline, message: provider.error!);
    }

    if (provider.attractions.isEmpty) {
      return const _MessageState(
        icon: Icons.explore_outlined,
        message: 'No attractions found. Try a different location.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: provider.attractions.length,
      itemBuilder: (context, index) {
        final attraction = provider.attractions[index];
        return ResultCard(
          thumbnail: attraction.thumbnail,
          fallbackIcon: Icons.place_outlined,
          title: attraction.title,
          subtitle: attraction.type,
          rating: attraction.rating,
          reviews: attraction.reviews,
          detail: attraction.address,
          onTap: () => Navigator.of(context).pushNamed(
            '/attraction-detail',
            arguments: attraction,
          ),
        );
      },
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
