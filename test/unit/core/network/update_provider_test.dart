import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/app_release.dart';
import 'package:humoruniv/domain/repositories/update_repository.dart';
import 'package:humoruniv/domain/usecases/check_for_update.dart';
import 'package:humoruniv/presentation/providers/update_provider.dart';
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
      () => CheckForUpdate(repository: mockRepository, currentVersion: '1.0.0'),
    );
  });

  tearDown(di.sl.reset);

  group('UpdateState', () {
    test('copyWith updates status only', () {
      const state = UpdateState(
        release: AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
      );
      final copied = state.copyWith(status: UpdateCheckStatus.checking);

      expect(copied.status, UpdateCheckStatus.checking);
      expect(copied.release?.version, '1.0.0');
    });

    test('copyWith updates release only', () {
      const state = UpdateState();
      const newRelease = AppRelease(
        version: '2.0.0',
        htmlUrl: 'https://example.com/v2',
      );
      final copied = state.copyWith(release: newRelease);

      expect(copied.status, UpdateCheckStatus.idle);
      expect(copied.release?.version, '2.0.0');
    });

    test('copyWith with no args returns identical state', () {
      const state = UpdateState(
        status: UpdateCheckStatus.available,
        release: AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
      );
      final copied = state.copyWith();

      expect(copied.status, state.status);
      expect(copied.release?.version, state.release?.version);
    });

    test('copyWith updates both fields', () {
      const state = UpdateState();
      const newRelease = AppRelease(
        version: '2.0.0',
        htmlUrl: 'https://example.com/v2',
      );
      final copied = state.copyWith(
        status: UpdateCheckStatus.available,
        release: newRelease,
      );

      expect(copied.status, UpdateCheckStatus.available);
      expect(copied.release?.version, '2.0.0');
    });

    test('default state has idle status and null release', () {
      const state = UpdateState();

      expect(state.status, UpdateCheckStatus.idle);
      expect(state.release, isNull);
    });
  });

  group('updateProvider', () {
    test('should emit idle initially', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(updateProvider);

      expect(state.status, UpdateCheckStatus.idle);
    });

    test('should emit available when update found', () async {
      const release = AppRelease(
        version: '1.2.0',
        htmlUrl: 'https://example.com',
      );
      when(
        () => mockRepository.getLatestRelease(),
      ).thenAnswer((_) async => const Right(release));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(updateProvider.notifier).checkForUpdate();

      final state = container.read(updateProvider);
      expect(state.status, UpdateCheckStatus.available);
      expect(state.release?.version, '1.2.0');
    });

    test('should emit upToDate when no update', () async {
      const release = AppRelease(
        version: '1.0.0',
        htmlUrl: 'https://example.com',
      );
      when(
        () => mockRepository.getLatestRelease(),
      ).thenAnswer((_) async => const Right(release));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(updateProvider.notifier).checkForUpdate();

      final state = container.read(updateProvider);
      expect(state.status, UpdateCheckStatus.upToDate);
    });

    test('should emit error on failure', () async {
      when(
        () => mockRepository.getLatestRelease(),
      ).thenAnswer((_) async => const Left(UpdateFailure('Network error')));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(updateProvider.notifier).checkForUpdate();

      final state = container.read(updateProvider);
      expect(state.status, UpdateCheckStatus.error);
      expect(state.release, isNull);
    });

    test('should set release on upToDate', () async {
      const release = AppRelease(
        version: '1.0.0',
        htmlUrl: 'https://example.com',
        downloadUrl: 'https://example.com/app.apk',
      );
      when(
        () => mockRepository.getLatestRelease(),
      ).thenAnswer((_) async => const Right(release));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(updateProvider.notifier).checkForUpdate();

      final state = container.read(updateProvider);
      expect(state.status, UpdateCheckStatus.upToDate);
      expect(state.release?.version, '1.0.0');
      expect(state.release?.downloadUrl, 'https://example.com/app.apk');
    });

    test('should emit checking while in progress', () async {
      final completer = Completer<Either<Failure, AppRelease>>();
      when(
        () => mockRepository.getLatestRelease(),
      ).thenAnswer((_) => completer.future);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(updateProvider.notifier).checkForUpdate();

      final state = container.read(updateProvider);
      expect(state.status, UpdateCheckStatus.checking);

      completer.complete(
        const Right(
          AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
        ),
      );
      await container.read(updateProvider.notifier).stream.first;
    });
  });
}
