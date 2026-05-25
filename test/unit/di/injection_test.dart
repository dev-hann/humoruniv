import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/network/html_client_impl.dart';
import 'package:humoruniv/data/datasources/humoruniv_remote_ds.dart';
import 'package:humoruniv/data/repositories/post_repository_impl.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/repositories/post_repository.dart';
import 'package:humoruniv/domain/usecases/get_best_posts.dart';
import 'package:humoruniv/domain/usecases/get_board_posts.dart';
import 'package:humoruniv/domain/usecases/get_post_detail.dart';

void main() {
  tearDown(di.sl.reset);

  group('configureDependencies', () {
    test('should register HtmlClientImpl', () {
      di.configureDependencies();

      expect(di.sl.isRegistered<HtmlClientImpl>(), isTrue);
    });

    test('should register HumorunivRemoteDs', () {
      di.configureDependencies();

      expect(di.sl.isRegistered<HumorunivRemoteDs>(), isTrue);
    });

    test('should register PostRepository', () {
      di.configureDependencies();

      expect(di.sl.isRegistered<PostRepository>(), isTrue);
    });

    test('should register GetBestPosts use case', () {
      di.configureDependencies();

      expect(di.sl.isRegistered<GetBestPosts>(), isTrue);
    });

    test('should register GetPostDetail use case', () {
      di.configureDependencies();

      expect(di.sl.isRegistered<GetPostDetail>(), isTrue);
    });

    test('should register GetBoardPosts use case', () {
      di.configureDependencies();

      expect(di.sl.isRegistered<GetBoardPosts>(), isTrue);
    });

    test('should resolve all dependencies without throwing', () {
      di.configureDependencies();

      expect(di.sl, returnsNormally);
      expect(di.sl, returnsNormally);
      expect(di.sl, returnsNormally);
      expect(di.sl, returnsNormally);
      expect(di.sl, returnsNormally);
      expect(di.sl, returnsNormally);
    });

    test('PostRepository should be PostRepositoryImpl', () {
      di.configureDependencies();

      final repo = di.sl<PostRepository>();
      expect(repo, isA<PostRepositoryImpl>());
    });
  });
}
