import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/core/widgets/states/skeleton_post_list.dart';
import 'package:humoruniv/domain/entities/post.dart';
import 'package:humoruniv/presentation/providers/post_provider.dart';
import 'package:humoruniv/presentation/widgets/post_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(bestPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('웃긴자료 베스트'),
        actions: [
          TextButton(
            onPressed: () => context.push('/board/pds'),
            child: const Text('웃긴자료'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(bestPostsProvider);
        },
        child: postsAsync.when(
          loading: () => const SkeletonPostList(),
          error: (e, st) {
            debugPrint('HOME ERROR: $e\n$st');
            return ListView(
              children: const [
                SizedBox(
                  height: 300,
                  child: Center(child: Text('게시글을 불러올 수 없습니다.')),
                ),
              ],
            );
          },
          data: (Either<Failure, List<Post>> result) => result.fold(
            (failure) {
              debugPrint('HOME FAILURE: ${failure.message}');
              return ListView(
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(child: Text('게시글을 불러올 수 없습니다.')),
                  ),
                ],
              );
            },
            (List<Post> posts) => posts.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(
                        height: 300,
                        child: Center(child: Text('게시글이 없습니다.')),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                        post: posts[index],
                        onTap: () {
                          context.push('/post?url=${Uri.encodeComponent(posts[index].url)}');
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
