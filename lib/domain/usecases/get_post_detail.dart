import 'package:dartz/dartz.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';

class GetPostDetail {
  const GetPostDetail({required this.repository});
  final PostRepository repository;

  Future<Either<Failure, PostDetail>> call(String url) {
    return repository.getPostDetail(url);
  }
}
