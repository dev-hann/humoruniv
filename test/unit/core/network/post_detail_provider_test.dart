import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/comment.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';
import 'package:humoruniv/domain/usecases/get_post_detail.dart';
import 'package:humoruniv/presentation/providers/post_detail_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockRepository;

  setUp(() {
    mockRepository = MockPostRepository();
    if (di.sl.isRegistered<PostRepository>()) {
      di.sl.unregister<PostRepository>();
    }
    if (di.sl.isRegistered<GetPostDetail>()) {
      di.sl.unregister<GetPostDetail>();
    }
    di.sl.registerLazySingleton<PostRepository>(() => mockRepository);
    di.sl.registerLazySingleton(
      () => GetPostDetail(repository: mockRepository),
    );
  });

  tearDown(di.sl.reset);

  final testDetail = PostDetail(
    id: 100,
    title: '테스트',
    author: '작성자',
    date: DateTime(2026, 5, 16),
    contentHtml: '<p>내용</p>',
    contentBlocks: const [TextBlock('내용')],
    imageUrls: const [],
    recommendCount: 42,
    notRecommendCount: 1,
    viewCount: 500,
    commentCount: 3,
    comments: [
      Comment(
        id: 1,
        author: '댓글러',
        content: 'ㅋㅋ',
        date: DateTime(2026, 5, 16),
        recommendCount: 5,
        isBest: true,
        replies: const [],
      ),
    ],
  );

  test('should emit Right with PostDetail when fetch succeeds', () async {
    const url = '/board/read.html?table=pds&number=100';
    when(
      () => mockRepository.getPostDetail(url),
    ).thenAnswer((_) async => Right(testDetail));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(postDetailProvider(url).future);

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('Should not return left'), (detail) {
      expect(detail.title, '테스트');
      expect(detail.author, '작성자');
      expect(detail.contentBlocks, hasLength(1));
      expect(detail.comments, hasLength(1));
    });
    verify(() => mockRepository.getPostDetail(url)).called(1);
  });

  test('should emit Left with ServerFailure when fetch fails', () async {
    const url = '/board/read.html?table=pds&number=999';
    when(
      () => mockRepository.getPostDetail(url),
    ).thenAnswer((_) async => const Left(ServerFailure('HTTP 500')));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(postDetailProvider(url).future);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Should not return right'),
    );
  });

  test('should emit Left with NetworkFailure when network fails', () async {
    const url = '/board/read.html?table=pds&number=888';
    when(
      () => mockRepository.getPostDetail(url),
    ).thenAnswer((_) async => const Left(NetworkFailure('No connection')));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(postDetailProvider(url).future);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('Should not return right'),
    );
  });

  test('should pass url parameter to repository', () async {
    const url = '/board/read.html?table=pds&number=777';
    when(
      () => mockRepository.getPostDetail(any()),
    ).thenAnswer((_) async => Right(testDetail));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(postDetailProvider(url).future);

    verify(() => mockRepository.getPostDetail(url)).called(1);
  });
}
