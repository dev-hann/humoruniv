import 'package:dartz/dartz.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/domain/entities/update_check_result.dart';
import 'package:humoruniv/domain/repositories/update_repository.dart';

class CheckForUpdate {
  const CheckForUpdate({
    required this.repository,
    required this.currentVersion,
  });
  final UpdateRepository repository;
  final String currentVersion;

  Future<Either<Failure, UpdateCheckResult>> call() async {
    final result = await repository.getLatestRelease();

    return result.fold(
      (failure) => Left(failure),
      (release) {
        final isNewer = _isNewerVersion(release.version, currentVersion);
        return Right(
          UpdateCheckResult(
            type: isNewer
                ? UpdateStatusType.updateAvailable
                : UpdateStatusType.upToDate,
            release: release,
          ),
        );
      },
    );
  }

  bool _isNewerVersion(String remote, String current) {
    final remoteParts = remote.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      final r = i < remoteParts.length ? remoteParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (r > c) return true;
      if (r < c) return false;
    }
    return false;
  }
}
