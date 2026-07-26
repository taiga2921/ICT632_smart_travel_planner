import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../widgets/rating_stars.dart';
import '../widgets/result_card.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final RestaurantResult restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(restaurant.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ThumbnailImage(
              url: restaurant.thumbnail,
              fallbackIcon: Icons.restaurant_outlined,
              width: double.infinity,
              height: 220,
              borderRadius: 24,
            ),
            const SizedBox(height: 16),
            Text(
              restaurant.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (restaurant.type != null && restaurant.type!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    restaurant.type!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
            if (restaurant.rating != null) ...[
              const SizedBox(height: 14),
              RatingStars(rating: restaurant.rating!, size: 22),
              const SizedBox(height: 4),
              Text(
                restaurant.reviews != null
                    ? '${restaurant.reviews} reviews'
                    : 'No review count available',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 20),
            _DetailTile(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: restaurant.address ?? 'Address not available',
            ),
            const SizedBox(height: 12),
            _DetailTile(
              icon: Icons.schedule_outlined,
              label: 'Opening hours',
              value: restaurant.hours ?? 'Opening hours not available',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(height: 1.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
