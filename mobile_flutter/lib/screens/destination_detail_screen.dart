import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/attraction_provider.dart';
import '../widgets/result_card.dart';
import 'attractions_screen.dart';
import 'country_screen.dart';
import 'create_trip_screen.dart';
import 'hotel_screen.dart';
import 'restaurant_screen.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationName;

  const DestinationDetailScreen({super.key, required this.destinationName});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AttractionProvider>().fetchAttractions(
            location: widget.destinationName,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttractionProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.destinationName)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.destinationName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ExploreChip(
                  icon: Icons.explore_outlined,
                  label: 'Attractions',
                  onTap: () => _push(AttractionsScreen(initialLocation: widget.destinationName)),
                ),
                _ExploreChip(
                  icon: Icons.hotel_outlined,
                  label: 'Hotels',
                  onTap: () => _push(HotelScreen(initialLocation: widget.destinationName)),
                ),
                _ExploreChip(
                  icon: Icons.restaurant_outlined,
                  label: 'Restaurants',
                  onTap: () => _push(RestaurantScreen(initialLocation: widget.destinationName)),
                ),
                _ExploreChip(
                  icon: Icons.public,
                  label: 'Country info',
                  onTap: () => _push(const CountryScreen()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Popular attractions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ..._buildAttractions(provider),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _push(const CreateTripScreen()),
              icon: const Icon(Icons.add),
              label: const Text('Create trip'),
            ),
          ],
        ),
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  List<Widget> _buildAttractions(AttractionProvider provider) {
    if (provider.isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (provider.error != null) {
      return [
        Text(
          'Could not load attractions for ${widget.destinationName}.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ];
    }

    if (provider.attractions.isEmpty) {
      return const [
        Text(
          'No attractions found for this destination.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ];
    }

    return provider.attractions
        .take(5)
        .map(
          (attraction) => ResultCard(
            thumbnail: attraction.thumbnail,
            fallbackIcon: Icons.place_outlined,
            title: attraction.title,
            subtitle: attraction.type,
            rating: attraction.rating,
            reviews: attraction.reviews,
            detail: attraction.address,
            onTap: () => Navigator.of(context)
                .pushNamed('/attraction-detail', arguments: attraction),
          ),
        )
        .toList();
  }
}

class _ExploreChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ExploreChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
