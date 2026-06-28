import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/di/injection.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
import 'package:humoruniv/domain/usecases/get_post_detail.dart';
import 'package:humoruniv/presentation/providers/board_posts_provider.dart';

final postDetailProvider = FutureProvider.autoDispose
    .family<Either<Failure, PostDetail>, String>((ref, url) {
      return sl<GetPostDetail>()(url);
    });

final feedPrefetchProvider = FutureProvider<void>((ref) async {
  final state = ref.watch(boardPostsProvider).value;
  if (state == null) return;
  await Future.wait(state.posts.map((post) => sl<GetPostDetail>()(post.url)));
});
