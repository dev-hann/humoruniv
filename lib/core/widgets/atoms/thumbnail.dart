import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_radius.dart';
import 'package:humoruniv/core/themes/app_sizes.dart';

enum ThumbnailSize { small, medium, large }

class Thumbnail extends StatelessWidget {
  final String? imageUrl;
  final ThumbnailSize size;

  const Thumbnail({
    super.key,
    required this.imageUrl,
    this.size = ThumbnailSize.small,
  });

  double get _dimension => switch (size) {
        ThumbnailSize.small => AppSizes.thumbnailSmall,
        ThumbnailSize.medium => AppSizes.thumbnailMedium,
        ThumbnailSize.large => AppSizes.thumbnailLarge,
      };

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return SizedBox(
        width: _dimension,
        height: _dimension,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(
            Icons.image_outlined,
            size: _dimension * 0.4,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: AppRadius.borderRadiusSm,
      child: Image.network(
        imageUrl!,
        width: _dimension,
        height: _dimension,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => SizedBox(
          width: _dimension,
          height: _dimension,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(
              Icons.broken_image_outlined,
              size: _dimension * 0.4,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
