import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../widgets/rating_stars.dart';
import '../widgets/result_card.dart';

class AttractionDetailScreen extends StatelessWidget {
  final AttractionResult attraction;

  const AttractionDetailScreen({super.key, required this.attraction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(attraction.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ThumbnailImage(
              url: attraction.thumbnail,
              fallbackIcon: Icons.place_outlined,
              width: double.infinity,
              height: 220,
              borderRadius: 24,
            ),
            const SizedBox(height: 16),
            Text(
              attraction.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (attraction.type != null && attraction.type!.isNotEmpty) ...[
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
                    attraction.type!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
            if (attraction.rating != null) ...[
              const SizedBox(height: 14),
              RatingStars(rating: attraction.rating!, size: 22),
              const SizedBox(height: 4),
              Text(
                attraction.reviews != null
                    ? '${attraction.reviews} reviews'
                    : 'No review count available',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Address', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    attraction.address ?? 'Address not available',
                    style: const TextStyle(height: 1.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('About', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              attraction.description ?? 'No description available for this place.',
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
