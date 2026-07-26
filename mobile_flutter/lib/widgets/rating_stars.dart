import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int? reviews;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviews,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final filled = rating >= index + 1;
          final half = !filled && rating > index;
          return Icon(
            filled
                ? Icons.star_rounded
                : half
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: size,
            color: AppColors.warning,
          );
        }),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: size - 3),
        ),
        if (reviews != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviews)',
            style: TextStyle(color: AppColors.textSecondary, fontSize: size - 4),
          ),
        ],
      ],
    );
  }
}
