import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/post.dart';
import 'package:humoruniv/domain/entities/sort_option.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';
import 'package:humoruniv/domain/usecases/get_best_posts.dart';
import 'package:humoruniv/domain/usecases/get_board_posts.dart';
import 'package:humoruniv/domain/usecases/get_post_detail.dart';
import 'package:humoruniv/presentation/screens/home_screen.dart';
import 'package:humoruniv/routes/app_router.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(SortOption.all);
  });

  setUp(() {
    mockRepository = MockPostRepository();
    if (di.sl.isRegistered<PostRepository>()) {
      di.sl.unregister<PostRepository>();
    }
    if (di.sl.isRegistered<GetBestPosts>()) {
      di.sl.unregister<GetBestPosts>();
    }
    if (di.sl.isRegistered<GetPostDetail>()) {
      di.sl.unregister<GetPostDetail>();
    }
    if (di.sl.isRegistered<GetBoardPosts>()) {
      di.sl.unregister<GetBoardPosts>();
    }
    di.sl.registerLazySingleton<PostRepository>(() => mockRepository);
    di.sl.registerLazySingleton(() => GetBestPosts(repository: mockRepository));
    di.sl.registerLazySingleton(() => GetPostDetail(repository: mockRepository));
    di.sl.registerLazySingleton(() => GetBoardPosts(repository: mockRepository));
  });

  tearDown(() {
    di.sl.reset();
  });

  group('appRouter', () {
    testWidgets('route / should render HomeScreen', (tester) async {
      when(() => mockRepository.getBestPosts())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: appRouter)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('route /post should render PostDetailScreen with empty url', (tester) async {
      when(() => mockRepository.getBestPosts())
          .thenAnswer((_) async => Right([const Post(id: 1, title: 'Test', recommendCount: 0, url: '/test')]));
      when(() => mockRepository.getPostDetail(any()))
          .thenAnswer((_) async => const Left(ServerFailure('no url')));

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: appRouter)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });
  });
}
