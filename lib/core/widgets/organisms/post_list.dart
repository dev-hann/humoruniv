import 'package:flutter/material.dart';
import 'package:humoruniv/core/widgets/molecules/post_card.dart';
import 'package:humoruniv/core/widgets/states/empty_state_view.dart';
import 'package:humoruniv/core/widgets/states/error_state_view.dart';
import 'package:humoruniv/core/widgets/states/skeleton_post_list.dart';

class PostList extends StatelessWidget {
  const PostList({
    required this.items,
    required this.onPostTap,
    super.key,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.onRefresh,
    this.filterBar,
    this.pagination,
  });
  final List<PostListItem> items;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onRefresh;
  final ValueChanged<int> onPostTap;
  final Widget? filterBar;
  final Widget? pagination;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (filterBar != null) filterBar!,
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
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
        itemCount: items.length + (pagination != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return pagination!;
          }
          final item = items[index];
          return PostCard(
            title: item.title,
            author: item.author,
            recommendCount: item.recommendCount,
            commentCount: item.commentCount,
            thumbnailUrl: item.thumbnailUrl,
            isRead: item.isRead,
            onTap: () => onPostTap(index),
          );
        },
      ),
    );
  }
}

class PostListItem {
  const PostListItem({
    required this.title,
    required this.author,
    required this.recommendCount,
    this.commentCount = 0,
    this.thumbnailUrl,
    this.isRead = false,
  });
  final String title;
  final String author;
  final int recommendCount;
  final int commentCount;
  final String? thumbnailUrl;
  final bool isRead;
}
