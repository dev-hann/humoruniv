import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/di/injection.dart';
import 'package:humoruniv/domain/entities/post.dart';
import 'package:humoruniv/domain/usecases/get_best_posts.dart';

final bestPostsProvider =
    FutureProvider.autoDispose<Either<Failure, List<Post>>>((ref) {
      return sl<GetBestPosts>()();
    });
