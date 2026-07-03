import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/core/widgets/molecules/dark_mode_selector.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/app_release.dart';
import 'package:humoruniv/domain/repositories/update_repository.dart';
import 'package:humoruniv/domain/usecases/check_for_update.dart';
import 'package:humoruniv/presentation/providers/shared_preferences_provider.dart';
import 'package:humoruniv/presentation/providers/update_provider.dart';
import 'package:humoruniv/presentation/screens/settings_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class MockUpdateRepository extends Mock implements UpdateRepository {}

class FakeUrlLauncherPlatform extends UrlLauncherPlatform {
  bool canLaunchResult = true;
  bool launchResult = true;

  @override
  Future<bool> canLaunch(String url) async => canLaunchResult;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async => launchResult;

  @override
  LinkDelegate? get linkDelegate => null;
}

void main() {
  late MockUpdateRepository mockRepository;
  late SharedPreferences prefs;
  late FakeUrlLauncherPlatform fakeLauncher;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    PackageInfo.setMockInitialValues(
      appName: '웃긴대학',
      packageName: 'com.example.humoruniv',
      version: '1.5.0',
      buildNumber: '7',
      buildSignature: '',
      installerStore: null,
    );
    fakeLauncher = FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = fakeLauncher;
    mockRepository = MockUpdateRepository();
    if (di.sl.isRegistered<UpdateRepository>()) {
      di.sl.unregister<UpdateRepository>();
    }
    if (di.sl.isRegistered<CheckForUpdate>()) {
      di.sl.unregister<CheckForUpdate>();
    }
    di.sl.registerLazySingleton<UpdateRepository>(() => mockRepository);
    di.sl.registerLazySingleton(
      () => CheckForUpdate(repository: mockRepository, currentVersion: '1.0.0'),
    );
  });

  tearDown(di.sl.reset);

  Widget buildApp() => ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const MaterialApp(home: SettingsScreen()),
  );

  group('SettingsScreen', () {
    testWidgets('should display all section titles', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(buildApp());

      expect(find.text('화면 설정'), findsOneWidget);
      expect(find.text('앱 정보'), findsOneWidget);
    });

    testWidgets('should display AppBar with 설정 title', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = (appBar.title! as Text).data;
      expect(title, '설정');
    });

    testWidgets('should display dark mode selector', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(buildApp());

      expect(find.byType(DarkModeSelector), findsOneWidget);
    });

    testWidgets('should display version info', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(buildApp());

      expect(find.text('버전'), findsOneWidget);
    });

    testWidgets('should show real app version after load, not stale fallback', (
      tester,
    ) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('v1.5.0'), findsOneWidget);
      expect(find.text('v1.1.0'), findsNothing);
    });

    testWidgets('should display update banner in idle state', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(buildApp());

      expect(find.text('업데이트 확인'), findsOneWidget);
    });

    testWidgets('should trigger checkForUpdate when check button tapped', (
      tester,
    ) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('업데이트 확인'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.getLatestRelease()).called(greaterThan(0));
    });

    testWidgets('should show update available state', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.2.0', htmlUrl: 'https://example.com'),
        ),
      );

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      container.read(updateProvider.notifier).checkForUpdate();
      await tester.pumpAndSettle();

      expect(find.text('v1.2.0 사용 가능'), findsOneWidget);
      expect(find.text('업데이트'), findsOneWidget);
    });

    testWidgets('should show up to date state', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      container.read(updateProvider.notifier).checkForUpdate();
      await tester.pumpAndSettle();

      expect(find.text('최신 버전입니다'), findsOneWidget);
    });

    testWidgets('should show error state with retry', (tester) async {
      when(
        () => mockRepository.getLatestRelease(),
      ).thenAnswer((_) async => const Left(UpdateFailure('Network error')));

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      container.read(updateProvider.notifier).checkForUpdate();
      await tester.pumpAndSettle();

      expect(find.text('확인 실패'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('should show checking state', (tester) async {
      final completer = Completer<Either<Failure, AppRelease>>();
      when(
        () => mockRepository.getLatestRelease(),
      ).thenAnswer((_) => completer.future);

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      container.read(updateProvider.notifier).checkForUpdate();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(
        const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('should show feedback when update URL cannot be opened', (
      tester,
    ) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(
            version: '1.2.0',
            htmlUrl: 'https://example.com/release',
            downloadUrl: 'https://example.com/app.apk',
          ),
        ),
      );
      fakeLauncher.canLaunchResult = false;

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      container.read(updateProvider.notifier).checkForUpdate();
      await tester.pumpAndSettle();

      await tester.tap(find.text('업데이트'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('업데이트 페이지를 열 수 없습니다.'), findsOneWidget);
    });
  });
}
