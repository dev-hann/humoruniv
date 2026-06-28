import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humoruniv/core/widgets/organisms/feed_list.dart';
import 'package:humoruniv/presentation/providers/board_posts_provider.dart';
import 'package:humoruniv/presentation/providers/post_detail_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(boardPostsProvider);
    ref.watch(feedPrefetchProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(boardPostsProvider),
      child: postsAsync.when(
        loading: () => const FeedList(posts: [], isLoading: true),
        error: (_, __) => FeedList(
          posts: const [],
          hasError: true,
          onRetry: () => ref.invalidate(boardPostsProvider),
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
        ),
      ),
    );
  }
}
