import 'package:flutter/material.dart';
import 'package:humoruniv/core/widgets/molecules/hero_card.dart';
import 'package:humoruniv/core/widgets/molecules/post_card.dart';
import 'package:humoruniv/core/widgets/states/empty_state_view.dart';
import 'package:humoruniv/core/widgets/states/error_state_view.dart';
import 'package:humoruniv/core/widgets/states/skeleton_post_list.dart';

class HomeFeed extends StatelessWidget {
  const HomeFeed({
    required this.items,
    required this.onPostTap,
    super.key,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.onRefresh,
  });
  final List<HomeFeedItem> items;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onRefresh;
  final ValueChanged<int> onPostTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SkeletonPostList();
    }

    if (hasError) {
      return ErrorStateView(
        message: errorMessage ?? '게시글을 불러올 수 없습니다.',
        onRetry: onRetry,
      );
    }

    if (items.isEmpty) {
      return const EmptyStateView(message: '게시글이 없습니다.');
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (index == 0) {
            return HeroCard(
              title: item.title,
              author: item.author,
              recommendCount: item.recommendCount,
              thumbnailUrl: item.thumbnailUrl,
              onTap: () => onPostTap(index),
            );
          }
          return PostCard(
            title: item.title,
            author: item.author,
            recommendCount: item.recommendCount,
            commentCount: item.commentCount,
            thumbnailUrl: item.thumbnailUrl,
            timeAgo: item.timeAgo,
            isRead: item.isRead,
            onTap: () => onPostTap(index),
          );
        },
      ),
    );
  }
}

class HomeFeedItem {
  const HomeFeedItem({
    required this.title,
    required this.author,
    required this.recommendCount,
    this.commentCount = 0,
    this.thumbnailUrl,
    this.timeAgo,
    this.isRead = false,
  });
  final String title;
  final String author;
  final int recommendCount;
  final int commentCount;
  final String? thumbnailUrl;
  final String? timeAgo;
  final bool isRead;
}
