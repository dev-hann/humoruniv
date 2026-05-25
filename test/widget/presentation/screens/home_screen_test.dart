import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/core/widgets/states/skeleton_post_list.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/post.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';
import 'package:humoruniv/domain/usecases/get_best_posts.dart';
import 'package:humoruniv/presentation/screens/home_screen.dart';
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

  testWidgets('should display post titles when data loads',
      (tester) async {
    final posts = [
      const Post(
        id: 1,
        title: 'First Post',
        recommendCount: 100,
        url: '/test1',
      ),
      const Post(
        id: 2,
        title: 'Second Post',
        recommendCount: 200,
        url: '/test2',
      ),
    ];
    when(() => mockRepository.getBestPosts())
        .thenAnswer((_) async => Right(posts));

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('First Post'), findsOneWidget);
    expect(find.text('Second Post'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
  });

  testWidgets('should show loading indicator while fetching',
      (tester) async {
    when(() => mockRepository.getBestPosts()).thenAnswer(
      (_) async => const Right([]),
    );

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    expect(find.byType(SkeletonPostList), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('should show error message when fetch fails',
      (tester) async {
    when(() => mockRepository.getBestPosts()).thenAnswer(
      (_) async => const Left(ServerFailure('Network error')),
    );

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('게시글을 불러올 수 없습니다.'), findsOneWidget);
  });

  testWidgets('should show empty message when no posts',
      (tester) async {
    when(() => mockRepository.getBestPosts())
        .thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('게시글이 없습니다.'), findsOneWidget);
  });
}
