import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humoruniv/core/widgets/organisms/feed_list.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/presentation/providers/board_posts_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(boardPostsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(boardPostsProvider),
      child: postsAsync.when(
        loading: () =>
            const FeedList(posts: [], isLoading: true, onPostTap: _noop),
        error: (_, __) => FeedList(
          posts: const [],
          hasError: true,
          onRetry: () => ref.invalidate(boardPostsProvider),
          onPostTap: _noop,
        ),
        data: (state) => FeedList(
          posts: state.posts,
          hasMore: state.hasMore,
          isLoadingMore: state.isLoadingMore,
          loadMoreError: state.loadMoreError,
          onLoadMore: () =>
              ref.read(boardPostsProvider.notifier).fetchNextPage(),
          onRetryLoadMore: () =>
              ref.read(boardPostsProvider.notifier).fetchNextPage(),
          onPostTap: (BoardPost post) =>
              context.push('/post?url=${Uri.encodeComponent(post.url)}'),
        ),
      ),
    );
  }
}

void _noop(BoardPost _) {}
