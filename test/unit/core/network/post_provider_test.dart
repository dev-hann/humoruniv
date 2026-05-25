import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/post.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';
import 'package:humoruniv/domain/usecases/get_best_posts.dart';
import 'package:humoruniv/presentation/providers/post_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockRepository;

  setUp(() {
    mockRepository = MockPostRepository();
    if (di.sl.isRegistered<PostRepository>()) {
      di.sl.unregister<PostRepository>();
    }
    if (di.sl.isRegistered<GetBestPosts>()) {
      di.sl.unregister<GetBestPosts>();
    }
    di.sl.registerLazySingleton<PostRepository>(() => mockRepository);
    di.sl.registerLazySingleton(() => GetBestPosts(repository: mockRepository));
  });

  tearDown(() {
    di.sl.reset();
  });

  test('should emit data when fetch succeeds', () async {
    final posts = [
      const Post(id: 1, title: 'Post 1', recommendCount: 100, url: '/test'),
    ];
    when(() => mockRepository.getBestPosts())
        .thenAnswer((_) async => Right(posts));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(bestPostsProvider.future);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Should not return left'),
      (data) => expect(data.length, equals(1)),
    );
  });

  test('should emit failure when fetch fails', () async {
    const failure = ServerFailure('Error');
    when(() => mockRepository.getBestPosts())
        .thenAnswer((_) async => const Left(failure));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(bestPostsProvider.future);

    expect(result.isLeft(), isTrue);
  });
}
