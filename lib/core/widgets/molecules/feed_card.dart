import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/utils/time_ago.dart';
import 'package:humoruniv/core/widgets/atoms/avatar.dart';
import 'package:humoruniv/core/widgets/atoms/count_badge.dart';
import 'package:humoruniv/core/widgets/atoms/feed_media.dart';
import 'package:humoruniv/core/widgets/molecules/text_post_card.dart';
import 'package:humoruniv/domain/entities/board_post.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    required this.post,
    super.key,
    this.onTap,
    this.isRead = false,
    this.screenHeight,
  });
  final BoardPost post;
  final VoidCallback? onTap;
  final bool isRead;
  final double? screenHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasThumbnail = post.thumbnailUrl.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(textTheme, colorScheme),
          if (hasThumbnail)
            FeedMedia(imageUrl: post.thumbnailUrl, screenHeight: screenHeight)
          else
            TextPostCard(
              title: post.title,
              secondary: post.previewText,
              screenHeight: screenHeight,
            ),
          _actions(),
          if (hasThumbnail) _caption(textTheme, colorScheme),
          if (post.date.isNotEmpty) _timestamp(textTheme, colorScheme),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outline.withOpacity(0.12),
          ),
        ],
      ),
    );
  }

  Widget _header(TextTheme textTheme, ColorScheme colorScheme) {
    final showBest = post.recommendCount >= 500;
    return Padding(
      padding: AppSpacing.edgeH16V8,
      child: Row(
        children: [
          const Avatar(),
          AppSpacing.sbW12,
          Expanded(
            child: Text(
              post.author,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showBest) ...[AppSpacing.sbW8, const BestBadge()],
        ],
      ),
    );
  }

  Widget _actions() {
    return Padding(
      padding: AppSpacing.edgeH16V8,
      child: Row(
        children: [
          RecommendBadge(count: post.recommendCount),
          AppSpacing.sbW16,
          CommentBadge(count: post.commentCount),
          AppSpacing.sbW16,
          ViewBadge(count: post.viewCount),
        ],
      ),
    );
  }

  Widget _caption(TextTheme textTheme, ColorScheme colorScheme) {
    final titleColor = isRead
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;
    return Padding(
      padding: AppSpacing.edgeH16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (post.previewText != null) ...[
            AppSpacing.sbH4,
            Text(
              post.previewText!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _timestamp(TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.p16,
        top: AppSpacing.p4,
        bottom: AppSpacing.p8,
      ),
      child: Text(
        TimeAgo.formatDateString(post.date),
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
