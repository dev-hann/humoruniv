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
import 'package:humoruniv/presentation/providers/update_provider.dart';
import 'package:humoruniv/presentation/screens/settings_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockUpdateRepository extends Mock implements UpdateRepository {}

void main() {
  late MockUpdateRepository mockRepository;

  setUp(() {
    mockRepository = MockUpdateRepository();
    if (di.sl.isRegistered<UpdateRepository>()) {
      di.sl.unregister<UpdateRepository>();
    }
    if (di.sl.isRegistered<CheckForUpdate>()) {
      di.sl.unregister<CheckForUpdate>();
    }
    di.sl.registerLazySingleton<UpdateRepository>(() => mockRepository);
    di.sl.registerLazySingleton(
      () => CheckForUpdate(
        repository: mockRepository,
        currentVersion: '1.0.0',
      ),
    );
  });

  tearDown(di.sl.reset);

  group('SettingsScreen', () {
    testWidgets('should display all section titles', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );

      expect(find.text('화면 설정'), findsOneWidget);
      expect(find.text('콘텐츠'), findsOneWidget);
      expect(find.text('앱 정보'), findsOneWidget);
    });

    testWidgets('should display dark mode selector', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );

      expect(find.byType(DarkModeSelector), findsOneWidget);
    });

    testWidgets('should display NSFW toggle', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );

      expect(find.text('성인 콘텐츠 경고'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should display version info', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );

      expect(find.text('버전'), findsOneWidget);
    });

    testWidgets('should display update banner in idle state', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );

      expect(find.text('업데이트 확인'), findsOneWidget);
    });

    testWidgets('should toggle NSFW switch', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final updatedSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(updatedSwitch.value, false);
    });

    testWidgets('should trigger checkForUpdate when check button tapped', (
      tester,
    ) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );

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

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
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

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );

      container.read(updateProvider.notifier).checkForUpdate();
      await tester.pumpAndSettle();

      expect(find.text('최신 버전입니다'), findsOneWidget);
    });

    testWidgets('should show error state with retry', (tester) async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Left(UpdateFailure('Network error')),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );

      container.read(updateProvider.notifier).checkForUpdate();
      await tester.pumpAndSettle();

      expect(find.text('확인 실패'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('should show checking state', (tester) async {
      final completer = Completer<Either<Failure, AppRelease>>();
      when(() => mockRepository.getLatestRelease())
          .thenAnswer((_) => completer.future);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );

      container.read(updateProvider.notifier).checkForUpdate();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const Right(
        AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
      ));
      await tester.pumpAndSettle();
    });
  });
}
