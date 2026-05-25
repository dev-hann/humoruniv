import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/molecules/dark_mode_selector.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/app_release.dart';
import 'package:humoruniv/domain/repositories/update_repository.dart';
import 'package:humoruniv/domain/usecases/check_for_update.dart';
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
          child: MaterialApp(home: SettingsScreen()),
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
          child: MaterialApp(home: SettingsScreen()),
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
          child: MaterialApp(home: SettingsScreen()),
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
          child: MaterialApp(home: SettingsScreen()),
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
          child: MaterialApp(home: SettingsScreen()),
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
          child: MaterialApp(home: SettingsScreen()),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final updatedSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(updatedSwitch.value, false);
    });
  });
}
