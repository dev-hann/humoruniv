import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:humoruniv/core/widgets/atoms/loading_indicator.dart';
import 'package:humoruniv/core/widgets/molecules/feed_card.dart';
import 'package:humoruniv/core/widgets/states/empty_state_view.dart';
import 'package:humoruniv/core/widgets/states/error_state_view.dart';
import 'package:humoruniv/core/widgets/states/skeleton_feed_card.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
import 'package:humoruniv/presentation/providers/post_detail_provider.dart';

class FeedCardItem extends ConsumerWidget {
  const FeedCardItem({
    required this.post,
    required this.onTap,
    this.isRead = false,
    super.key,
  });
  final BoardPost post;
  final VoidCallback onTap;
  final bool isRead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(postDetailProvider(post.url));
    final PostDetail? detail = asyncDetail.whenOrNull(
      data: (either) => either.fold((_) => null, (d) => d),
    );
    return FeedCard(post: post, detail: detail, onTap: onTap, isRead: isRead);
  }
}

class FeedList extends StatefulWidget {
  const FeedList({
    required this.posts,
    required this.onPostTap,
    super.key,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.onLoadMore,
    this.onRetryLoadMore,
    this.readIds = const <int>{},
  });
  final List<BoardPost> posts;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRetryLoadMore;
  final ValueChanged<BoardPost> onPostTap;
  final Set<int> readIds;

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return ListView.builder(
        itemCount: 4,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (_, __) => const SkeletonFeedCard(),
      );
    }
    if (widget.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          ErrorStateView(
            message: widget.errorMessage ?? '게시글을 불러올 수 없습니다.',
            onRetry: widget.onRetry,
          ),
        ],
      );
    }
    if (widget.posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const EmptyStateView(message: '게시글이 없습니다.'),
        ],
      );
    }

    final extra =
        (widget.hasMore || widget.isLoadingMore || widget.loadMoreError != null)
        ? 1
        : 0;

    return ListView.builder(
      controller: _controller,
      itemCount: widget.posts.length + extra,
      itemBuilder: (context, index) {
        if (index == widget.posts.length) {
          if (widget.loadMoreError != null) {
            return LoadMoreError(
              message: '불러오기 실패',
              onRetry: widget.onRetryLoadMore ?? () {},
            );
          }
          if (widget.isLoadingMore) {
            return const LoadingIndicator();
          }
          return const SizedBox.shrink();
        }
        final post = widget.posts[index];
        return FeedCard(
          post: post,
          isRead: widget.readIds.contains(post.id),
          onTap: () => widget.onPostTap(post),
        );
      },
    );
  }
}
