import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
    di.sl.registerLazySingleton(
      () => GetPostDetail(repository: mockPostRepo),
    );
    di.sl.registerLazySingleton(
      () => GetBoardPosts(repository: mockPostRepo),
    );
    di.sl.registerLazySingleton<UpdateRepository>(() => mockUpdateRepo);
    di.sl.registerLazySingleton(
      () => CheckForUpdate(
        repository: mockUpdateRepo,
        currentVersion: '1.0.0',
      ),
    );
  });

  tearDown(di.sl.reset);

  void setupMocks() {
    when(() => mockPostRepo.getBestPosts()).thenAnswer(
      (_) async => const Right([]),
    );
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
  }

  group('MainTabsScreen', () {
    testWidgets('should display BottomNavBar with 4 tabs', (tester) async {
      setupMocks();

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MainTabsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('홈'), findsOneWidget);
      expect(find.text('최신'), findsOneWidget);
      expect(find.text('검색'), findsOneWidget);
      expect(find.text('설정'), findsOneWidget);
    });

    testWidgets('should show home tab title initially', (tester) async {
      setupMocks();

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MainTabsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('웃긴자료 베스트'), findsOneWidget);
    });

    testWidgets('should switch to recent tab on tap', (tester) async {
      setupMocks();

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MainTabsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('최신'));
      await tester.pumpAndSettle();

      expect(find.text('웃긴자료'), findsOneWidget);
    });

    testWidgets('should show search placeholder on search tab', (
      tester,
    ) async {
      setupMocks();

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MainTabsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('검색'));
      await tester.pumpAndSettle();

      expect(find.text('검색'), findsWidgets);
      expect(
        find.text('검색 기능이 곧 추가됩니다'),
        findsOneWidget,
      );
    });

    testWidgets('should switch to settings tab on tap', (tester) async {
      setupMocks();

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MainTabsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('설정'));
      await tester.pumpAndSettle();

      expect(find.text('화면 설정'), findsOneWidget);
    });

    testWidgets('should use IndexedStack for state preservation', (
      tester,
    ) async {
      setupMocks();

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MainTabsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(IndexedStack), findsOneWidget);
    });
  });
}
