import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_colors.dart';
import 'package:humoruniv/core/themes/app_radius.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/utils/time_ago.dart';
import 'package:humoruniv/core/widgets/atoms/count_badge.dart';
import 'package:humoruniv/core/widgets/atoms/thumbnail.dart';
import 'package:humoruniv/domain/entities/board_post.dart';

class BoardPostCard extends StatelessWidget {
  final BoardPost post;
  final VoidCallback onTap;

  const BoardPostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasThumbnail = post.thumbnailUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p4),
      child: Material(
        color: colorScheme.surface,
        borderRadius: AppRadius.borderRadiusMd,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.12),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.borderRadiusMd,
            child: Padding(
              padding: AppSpacing.edgeAll12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.sbH8,
                        Row(
                          children: [
                            Text(
                              post.author,
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (post.date.isNotEmpty) ...[
                              Text(
                                ' · ',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                TimeAgo.formatDateString(post.date),
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const Spacer(),
                            RecommendBadge(count: post.recommendCount),
                            AppSpacing.sbW12,
                            CommentBadge(count: post.commentCount),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (hasThumbnail) ...[
                    AppSpacing.sbW12,
                    Thumbnail(
                      imageUrl: post.thumbnailUrl,
                      size: ThumbnailSize.medium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
