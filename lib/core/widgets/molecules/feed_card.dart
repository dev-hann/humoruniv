import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_sizes.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/utils/time_ago.dart';
import 'package:humoruniv/core/widgets/atoms/avatar.dart';
import 'package:humoruniv/core/widgets/atoms/count_badge.dart';
import 'package:humoruniv/core/widgets/atoms/feed_media.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    required this.post,
    super.key,
    this.onTap,
    this.isRead = false,
    this.screenHeight,
    this.detail,
  });
  final BoardPost post;
  final VoidCallback? onTap;
  final bool isRead;
  final double? screenHeight;
  final PostDetail? detail;

  String? get _fullImage => (detail != null && detail!.imageUrls.isNotEmpty)
      ? detail!.imageUrls.first
      : null;

  String? get _bodyText {
    final d = detail;
    if (d == null) return post.previewText;
    for (final block in d.contentBlocks) {
      if (block is TextBlock && block.text.trim().isNotEmpty) return block.text;
    }
    return post.previewText;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasThumbnail = post.thumbnailUrl.isNotEmpty;
    final fullImage = _fullImage;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(textTheme, colorScheme),
          if (fullImage != null)
            ColoredBox(
              color: colorScheme.surfaceContainerHighest,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: AppSizes.feedMediaMaxHeight,
                ),
                child: Image.network(
                  fullImage,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => hasThumbnail
                      ? FeedMedia(
                          imageUrl: post.thumbnailUrl,
                          screenHeight: screenHeight,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            )
          else if (hasThumbnail)
            FeedMedia(imageUrl: post.thumbnailUrl, screenHeight: screenHeight),
          _actions(),
          _caption(textTheme, colorScheme),
          if (detail != null && detail!.comments.isNotEmpty)
            _commentPreview(textTheme, colorScheme),
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
    final body = _bodyText;
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
          if (body != null && body.isNotEmpty) ...[
            AppSpacing.sbH4,
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _commentPreview(TextTheme textTheme, ColorScheme colorScheme) {
    final comments = detail!.comments;
    final first = comments.first;
    return Padding(
      padding: AppSpacing.edgeH16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '댓글 ${detail!.commentCount}개',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.sbH4,
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${first.author} ',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: first.content, style: textTheme.labelSmall),
              ],
            ),
          ),
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
