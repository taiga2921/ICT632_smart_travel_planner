import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'rating_stars.dart';

/// Shared list tile for SerpAPI search results (attractions, hotels, restaurants).
class ResultCard extends StatelessWidget {
  final String? thumbnail;
  final IconData fallbackIcon;
  final String title;
  final String? subtitle;
  final double? rating;
  final int? reviews;
  final String? detail;
  final String? trailingLabel;
  final VoidCallback onTap;

  const ResultCard({
    super.key,
    required this.thumbnail,
    required this.fallbackIcon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.rating,
    this.reviews,
    this.detail,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThumbnailImage(
                url: thumbnail,
                fallbackIcon: fallbackIcon,
                width: 76,
                height: 76,
                borderRadius: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                    if (rating != null) ...[
                      const SizedBox(height: 6),
                      RatingStars(rating: rating!, reviews: reviews),
                    ],
                    if (detail != null && detail!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        detail!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                    if (trailingLabel != null && trailingLabel!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        trailingLabel!,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class ThumbnailImage extends StatelessWidget {
  final String? url;
  final IconData fallbackIcon;
  final double width;
  final double height;
  final double borderRadius;

  const ThumbnailImage({
    super.key,
    required this.url,
    required this.fallbackIcon,
    required this.width,
    required this.height,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: AppColors.primary.withValues(alpha: 0.12),
      child: Icon(fallbackIcon, color: AppColors.primary, size: height / 2.6),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: (url == null || url!.isEmpty)
          ? placeholder
          : Image.network(
              url!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}
