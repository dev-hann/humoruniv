import 'package:dartz/dartz.dart';
import 'dart:async';

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
      () => CheckForUpdate(
        repository: mockRepository,
        currentVersion: '1.0.0',
      ),
    );
  });

  tearDown(di.sl.reset);

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
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(release),
      );

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
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Right(release),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(updateProvider.notifier).checkForUpdate();

      final state = container.read(updateProvider);
      expect(state.status, UpdateCheckStatus.upToDate);
    });

    test('should emit error on failure', () async {
      when(() => mockRepository.getLatestRelease()).thenAnswer(
        (_) async => const Left(UpdateFailure('Network error')),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(updateProvider.notifier).checkForUpdate();

      final state = container.read(updateProvider);
      expect(state.status, UpdateCheckStatus.error);
    });

    test('should emit checking while in progress', () async {
      final completer = Completer<Either<Failure, AppRelease>>();
      when(() => mockRepository.getLatestRelease())
          .thenAnswer((_) => completer.future);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(updateProvider.notifier).checkForUpdate();

      final state = container.read(updateProvider);
      expect(state.status, UpdateCheckStatus.checking);

      completer.complete(const Right(
        AppRelease(version: '1.0.0', htmlUrl: 'https://example.com'),
      ));
      await container.read(updateProvider.notifier).stream.first;
    });
  });
}
