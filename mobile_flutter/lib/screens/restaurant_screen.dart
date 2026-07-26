import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_config.dart';
import '../constants/app_colors.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/result_card.dart';

class RestaurantScreen extends StatefulWidget {
  final String? initialLocation;

  const RestaurantScreen({super.key, this.initialLocation});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  late final TextEditingController _locationController;
  final _queryController = TextEditingController(text: 'restaurants');
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
    context.read<RestaurantProvider>().fetchRestaurants(
          location: _locationController.text.trim(),
          query: _queryController.text.trim().isEmpty
              ? 'restaurants'
              : _queryController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
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
                        labelText: 'Cuisine or dish',
                        hintText: 'e.g. nasi lemak, sushi, restaurants',
                        prefixIcon: Icon(Icons.restaurant_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: provider.isLoading ? null : _search,
                        icon: const Icon(Icons.search),
                        label: const Text('Search restaurants'),
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

  Widget _buildResults(RestaurantProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return _MessageState(icon: Icons.error_outline, message: provider.error!);
    }

    if (provider.restaurants.isEmpty) {
      return const _MessageState(
        icon: Icons.restaurant_outlined,
        message: 'No restaurants found. Try a different location or cuisine.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: provider.restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = provider.restaurants[index];
        return ResultCard(
          thumbnail: restaurant.thumbnail,
          fallbackIcon: Icons.restaurant_outlined,
          title: restaurant.title,
          subtitle: restaurant.type,
          rating: restaurant.rating,
          reviews: restaurant.reviews,
          detail: restaurant.address,
          trailingLabel: restaurant.hours,
          onTap: () => Navigator.of(context).pushNamed(
            '/restaurant-detail',
            arguments: restaurant,
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
