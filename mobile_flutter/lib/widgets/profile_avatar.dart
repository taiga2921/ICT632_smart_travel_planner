import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Circular user avatar that falls back to initials when no photo is stored.
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    required this.initials,
    this.size = 52,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    final avatar = ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: hasPhoto
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _Fallback(initials: initials, size: size),
                errorWidget: (_, __, ___) =>
                    _Fallback(initials: initials, size: size),
              )
            : _Fallback(initials: initials, size: size),
      ),
    );

    if (onTap == null) return avatar;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: avatar,
    );
  }
}

class _Fallback extends StatelessWidget {
  final String initials;
  final double size;

  const _Fallback({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
