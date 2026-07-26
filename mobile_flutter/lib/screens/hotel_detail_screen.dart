import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../widgets/rating_stars.dart';
import '../widgets/result_card.dart';

class HotelDetailScreen extends StatelessWidget {
  final HotelResult hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hotel.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ThumbnailImage(
              url: hotel.thumbnail,
              fallbackIcon: Icons.hotel_outlined,
              width: double.infinity,
              height: 240,
              borderRadius: 24,
            ),
            const SizedBox(height: 16),
            Text(
              hotel.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (hotel.rating != null) ...[
              const SizedBox(height: 12),
              RatingStars(rating: hotel.rating!, size: 22),
              const SizedBox(height: 4),
              Text(
                hotel.reviews != null
                    ? '${hotel.reviews} reviews'
                    : 'No review count available',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: AppColors.primaryDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price per night',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          hotel.price ?? 'Not available',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('About', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              hotel.description ?? 'No description available for this hotel.',
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: hotel.link == null ? null : () => _openWebsite(context),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Visit Website'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWebsite(BuildContext context) async {
    final uri = Uri.tryParse(hotel.link!);
    final launched = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the hotel website')),
      );
    }
  }
}
