import 'package:dartz/dartz.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/domain/entities/post.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';

class GetBestPosts {
  const GetBestPosts({required this.repository});
  final PostRepository repository;

  Future<Either<Failure, List<Post>>> call() async {
    return repository.getBestPosts();
  }
}
