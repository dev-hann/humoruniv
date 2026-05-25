import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/core/themes/app_colors.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/utils/time_ago.dart';
import 'package:humoruniv/core/widgets/atoms/avatar.dart';
import 'package:humoruniv/core/widgets/atoms/count_badge.dart';
import 'package:humoruniv/core/widgets/states/skeleton_post_detail.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
import 'package:humoruniv/presentation/providers/post_detail_provider.dart';
import 'package:humoruniv/presentation/widgets/comment_tile.dart';
import 'package:humoruniv/presentation/widgets/content_block_view.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postUrl;

  const PostDetailScreen({super.key, required this.postUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(postDetailProvider(postUrl));

    return Scaffold(
      appBar: AppBar(title: const Text('게시글')),
      body: detailAsync.when(
        loading: () => const SkeletonPostDetail(),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('게시글을 불러올 수 없습니다.'),
              TextButton(
                onPressed: () => ref.invalidate(postDetailProvider(postUrl)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (Either<Failure, PostDetail> result) => result.fold(
          (_) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('게시글을 불러올 수 없습니다.'),
                TextButton(
                  onPressed: () => ref.invalidate(postDetailProvider(postUrl)),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
          (PostDetail detail) => _PostDetailContent(detail: detail),
        ),
      ),
    );
  }
}

class _PostDetailContent extends StatelessWidget {
  final PostDetail detail;

  const _PostDetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: AppSpacing.edgeAll16,
            color: colorScheme.surfaceContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.title,
                  style: textTheme.headlineMedium,
                ),
                AppSpacing.sbH12,
                Row(
                  children: [
                    const Avatar(radius: 16),
                    AppSpacing.sbW8,
                    Text(
                      detail.author,
                      style: textTheme.labelLarge,
                    ),
                    AppSpacing.sbW12,
                    Text(
                      TimeAgo.format(detail.date),
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                AppSpacing.sbH12,
                Row(
                  children: [
                    Icon(Icons.thumb_up, size: 16, color: AppColors.recommendColor(detail.recommendCount, colorScheme)),
                    AppSpacing.sbW4,
                    Text('${detail.recommendCount}',
                        style: textTheme.labelMedium?.copyWith(
                              color: AppColors.recommendColor(detail.recommendCount, colorScheme),
                              fontWeight: AppColors.recommendWeight(detail.recommendCount),
                            )),
                    AppSpacing.sbW16,
                    Icon(Icons.thumb_down, size: 16, color: colorScheme.error),
                    AppSpacing.sbW4,
                    Text('${detail.notRecommendCount}',
                        style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.error,
                            )),
                    AppSpacing.sbW16,
                    Icon(Icons.remove_red_eye, size: 16, color: colorScheme.onSurfaceVariant),
                    AppSpacing.sbW4,
                    Text('${detail.viewCount}',
                        style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            )),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: AppSpacing.edgeAll16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.contentBlocks.isNotEmpty)
                  ...() {
                    int imgCount = 0;
                    return detail.contentBlocks.map((block) {
                      final idx = block is ImageBlock ? imgCount++ : -1;
                      return ContentBlockView(
                        block: block,
                        allImageUrls: detail.imageUrls,
                        imageIndex: idx >= 0 ? idx : 0,
                      );
                    }).toList();
                  }(),
                const Divider(height: 32),
                Text(
                  '댓글 (${detail.commentCount})',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.sbH12,
                ...detail.comments.map((comment) => CommentTile(comment: comment)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
