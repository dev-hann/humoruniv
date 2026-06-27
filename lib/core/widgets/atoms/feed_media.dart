import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_sizes.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/widgets/atoms/skeleton_box.dart';

class FeedMedia extends StatelessWidget {
  const FeedMedia({
    required this.imageUrl,
    super.key,
    this.onTap,
    this.isNsfw = false,
    this.additionalImageCount = 0,
    this.screenHeight,
  });
  final String imageUrl;
  final VoidCallback? onTap;
  final bool isNsfw;
  final int additionalImageCount;
  final double? screenHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final height = AppSizes.feedMediaHeight(
      screenHeight ?? MediaQuery.sizeOf(context).height,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _content(context, colorScheme),
            if (isNsfw) _nsfwOverlay(context),
            if (additionalImageCount > 0) _multiBadge(context),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, ColorScheme colorScheme) {
    if (imageUrl.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
        child: Icon(
          Icons.image_outlined,
          size: AppSizes.iconLarge * 2,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SkeletonBox(
          width: double.infinity,
          height: double.infinity,
        );
      },
      errorBuilder: (_, __, ___) => DecoratedBox(
        decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
        child: Icon(
          Icons.broken_image_outlined,
          size: AppSizes.iconLarge * 2,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _nsfwOverlay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.black54),
      child: Icon(
        Icons.visibility_off,
        color: colorScheme.onPrimary,
        size: AppSizes.iconLarge * 2,
      ),
    );
  }

  Widget _multiBadge(BuildContext context) {
    return Positioned(
      top: AppSpacing.p8,
      right: AppSpacing.p8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p8,
          vertical: AppSpacing.p4,
        ),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '+$additionalImageCount',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
