import 'package:dartz/dartz.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/domain/entities/board_list_result.dart';
import 'package:humoruniv/domain/entities/post.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
import 'package:humoruniv/domain/entities/sort_option.dart';

abstract class PostRepository {
  Future<Either<Failure, List<Post>>> getBestPosts();
  Future<Either<Failure, PostDetail>> getPostDetail(String url);
  Future<Either<Failure, BoardListResult>> getBoardPosts(
    String table,
    int page,
    SortOption sort,
  );
}
