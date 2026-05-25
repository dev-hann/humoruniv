import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_radius.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/widgets/atoms/count_badge.dart';
import 'package:humoruniv/core/widgets/atoms/thumbnail.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String author;
  final int recommendCount;
  final int commentCount;
  final String? thumbnailUrl;
  final String? timeAgo;
  final bool isRead;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.title,
    required this.author,
    required this.recommendCount,
    this.commentCount = 0,
    this.thumbnailUrl,
    this.timeAgo,
    this.isRead = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final titleColor =
        isRead ? colorScheme.onSurfaceVariant : colorScheme.onSurface;

    final hasThumbnail = thumbnailUrl != null && thumbnailUrl!.isNotEmpty;

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
              child: hasThumbnail
                  ? _buildWithThumbnail(context, textTheme, colorScheme, titleColor)
                  : _buildTextOnly(context, textTheme, colorScheme, titleColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextOnly(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    Color titleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        AppSpacing.sbH8,
        _buildMetaRow(textTheme, colorScheme),
      ],
    );
  }

  Widget _buildWithThumbnail(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    Color titleColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.sbH8,
              _buildMetaRow(textTheme, colorScheme),
            ],
          ),
        ),
        AppSpacing.sbW12,
        Opacity(
          opacity: isRead ? 0.6 : 1.0,
          child: Thumbnail(
            imageUrl: thumbnailUrl,
            size: ThumbnailSize.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          author,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (timeAgo != null && timeAgo!.isNotEmpty) ...[
          Text(
            ' · ',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            timeAgo!,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const Spacer(),
        RecommendBadge(count: recommendCount),
        AppSpacing.sbW12,
        CommentBadge(count: commentCount),
      ],
    );
  }
}
