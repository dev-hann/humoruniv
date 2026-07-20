import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/app_release.dart';
import 'package:humoruniv/domain/entities/board_list_result.dart';
import 'package:humoruniv/domain/entities/sort_option.dart';
import 'package:humoruniv/domain/repositories/apk_install_repository.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';
import 'package:humoruniv/domain/repositories/update_repository.dart';
import 'package:humoruniv/data/datasources/image_cache_service.dart';
import 'package:humoruniv/domain/usecases/check_for_update.dart';
import 'package:humoruniv/domain/usecases/get_best_posts.dart';
import 'package:humoruniv/domain/usecases/get_board_posts.dart';
import 'package:humoruniv/domain/usecases/get_post_detail.dart';
import 'package:humoruniv/presentation/providers/shared_preferences_provider.dart';
import 'package:humoruniv/presentation/screens/home_screen.dart';
import 'package:humoruniv/presentation/screens/settings_screen.dart';
import 'package:humoruniv/routes/app_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPostRepository extends Mock implements PostRepository {}

class MockUpdateRepository extends Mock implements UpdateRepository {}

class MockApkInstallRepository extends Mock implements ApkInstallRepository {}

class FakeImageCacheService extends Mock implements ImageCacheService {}

void main() {
  late MockPostRepository mockPostRepo;
  late MockUpdateRepository mockUpdateRepo;
  late MockApkInstallRepository mockApkRepo;
  late FakeImageCacheService fakeCacheService;
  late SharedPreferences prefs;

  setUpAll(() {
    registerFallbackValue(SortOption.all);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockPostRepo = MockPostRepository();
    mockUpdateRepo = MockUpdateRepository();
    mockApkRepo = MockApkInstallRepository();
    fakeCacheService = FakeImageCacheService();
    when(() => fakeCacheService.getSizeBytes()).thenAnswer((_) async => 0);
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
    if (di.sl.isRegistered<ApkInstallRepository>()) {
      di.sl.unregister<ApkInstallRepository>();
    }
    if (di.sl.isRegistered<ImageCacheService>()) {
      di.sl.unregister<ImageCacheService>();
    }
    di.sl.registerLazySingleton<PostRepository>(() => mockPostRepo);
    di.sl.registerLazySingleton(() => GetBestPosts(repository: mockPostRepo));
    di.sl.registerLazySingleton(() => GetPostDetail(repository: mockPostRepo));
    di.sl.registerLazySingleton(() => GetBoardPosts(repository: mockPostRepo));
    di.sl.registerLazySingleton<UpdateRepository>(() => mockUpdateRepo);
    di.sl.registerLazySingleton(
      () => CheckForUpdate(repository: mockUpdateRepo, currentVersion: '1.0.0'),
    );
    di.sl.registerLazySingleton<ApkInstallRepository>(() => mockApkRepo);
    di.sl.registerLazySingleton<ImageCacheService>(() => fakeCacheService);
  });

  tearDown(di.sl.reset);

  group('appRouter', () {
    testWidgets('route / should render HomeScreen', (tester) async {
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
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp.router(routerConfig: appRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('route /settings should render SettingsScreen', (tester) async {
      when(() => mockUpdateRepo.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp.router(routerConfig: appRouter),
        ),
      );
      appRouter.push('/settings');
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
