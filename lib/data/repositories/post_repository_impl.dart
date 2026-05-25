import 'package:dartz/dartz.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/data/datasources/humoruniv_remote_ds.dart';
import 'package:humoruniv/domain/entities/board_list_result.dart';
import 'package:humoruniv/domain/entities/post.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
import 'package:humoruniv/domain/entities/sort_option.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  const PostRepositoryImpl({required this.remoteDs});
  final HumorunivRemoteDs remoteDs;

  @override
  Future<Either<Failure, List<Post>>> getBestPosts() async {
    try {
      final dtos = await remoteDs.fetchMainPage();
      final posts = dtos.map((dto) => dto.toEntity()).toList();
      return Right(posts);
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, PostDetail>> getPostDetail(String url) async {
    try {
      final detail = await remoteDs.fetchPostDetail(url);
      return Right(detail);
    } on Failure catch (f) {
      return Left(f);
    }
  }

  @override
  Future<Either<Failure, BoardListResult>> getBoardPosts(
    String table,
    int page,
    SortOption sort,
  ) async {
    try {
      final result = await remoteDs.fetchBoardList(table, page, sort.value);
      final posts = result.posts.map((dto) => dto.toEntity()).toList();
      return Right(
        BoardListResult(
          posts: posts,
          currentPage: result.currentPage,
          totalPage: result.totalPage,
        ),
      );
    } on Failure catch (f) {
      return Left(f);
    }
  }
}
