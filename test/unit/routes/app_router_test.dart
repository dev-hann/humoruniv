import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/app_release.dart';
import 'package:humoruniv/domain/entities/board_list_result.dart';
import 'package:humoruniv/domain/entities/sort_option.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';
import 'package:humoruniv/domain/repositories/update_repository.dart';
import 'package:humoruniv/domain/usecases/check_for_update.dart';
import 'package:humoruniv/domain/usecases/get_best_posts.dart';
import 'package:humoruniv/domain/usecases/get_board_posts.dart';
import 'package:humoruniv/domain/usecases/get_post_detail.dart';
import 'package:humoruniv/presentation/screens/main_tabs_screen.dart';
import 'package:humoruniv/presentation/screens/post_detail_screen.dart';
import 'package:humoruniv/routes/app_router.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

class MockUpdateRepository extends Mock implements UpdateRepository {}

void main() {
  late MockPostRepository mockPostRepo;
  late MockUpdateRepository mockUpdateRepo;

  setUpAll(() {
    registerFallbackValue(SortOption.all);
  });

  setUp(() {
    mockPostRepo = MockPostRepository();
    mockUpdateRepo = MockUpdateRepository();
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
    if (di.sl.isRegistered<UpdateRepository>()) {
      di.sl.unregister<UpdateRepository>();
    }
    if (di.sl.isRegistered<CheckForUpdate>()) {
      di.sl.unregister<CheckForUpdate>();
    }
    di.sl.registerLazySingleton<PostRepository>(() => mockPostRepo);
    di.sl.registerLazySingleton(() => GetBestPosts(repository: mockPostRepo));
    di.sl.registerLazySingleton(() => GetPostDetail(repository: mockPostRepo));
    di.sl.registerLazySingleton(() => GetBoardPosts(repository: mockPostRepo));
    di.sl.registerLazySingleton<UpdateRepository>(() => mockUpdateRepo);
    di.sl.registerLazySingleton(
      () => CheckForUpdate(repository: mockUpdateRepo, currentVersion: '1.0.0'),
    );
  });

  tearDown(di.sl.reset);

  group('appRouter', () {
    testWidgets('route / should render MainTabsScreen', (tester) async {
      when(
        () => mockPostRepo.getBestPosts(),
      ).thenAnswer((_) async => const Right([]));
      when(() => mockPostRepo.getBoardPosts(any(), any(), any())).thenAnswer(
        (_) async => const Right(
          BoardListResult(posts: [], currentPage: 0, totalPage: 0),
        ),
      );
      when(() => mockUpdateRepo.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: appRouter)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MainTabsScreen), findsOneWidget);
    });

    testWidgets('route /post renders PostDetailScreen', (tester) async {
      when(
        () => mockPostRepo.getPostDetail(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('')));

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: appRouter)),
      );
      appRouter.push('/post?url=http%3A%2F%2Fexample.com');
      await tester.pumpAndSettle();

      expect(find.byType(PostDetailScreen), findsOneWidget);
    });

    testWidgets('route /post without url param passes empty string', (
      tester,
    ) async {
      when(
        () => mockPostRepo.getPostDetail(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('')));

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: appRouter)),
      );
      appRouter.push('/post');
      await tester.pumpAndSettle();

      expect(find.byType(PostDetailScreen), findsOneWidget);
    });
  });
}
