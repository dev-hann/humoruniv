import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_radius.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/widgets/atoms/count_badge.dart';
import 'package:humoruniv/core/widgets/atoms/thumbnail.dart';

class HeroCard extends StatelessWidget {
  final String title;
  final String author;
  final int recommendCount;
  final String? thumbnailUrl;
  final VoidCallback onTap;

  const HeroCard({
    super.key,
    required this.title,
    required this.author,
    required this.recommendCount,
    this.thumbnailUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.edgeH16,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
              Thumbnail(
                imageUrl: thumbnailUrl,
                size: ThumbnailSize.large,
              ),
            Padding(
              padding: AppSpacing.edgeAll12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppSpacing.edgeH8V4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: AppRadius.borderRadiusSm,
                        ),
                        child: Text(
                          '오늘의 1위',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.sbH8,
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.sbH4,
                  Row(
                    children: [
                      Text(
                        author,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const Spacer(),
                      RecommendBadge(count: recommendCount),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
