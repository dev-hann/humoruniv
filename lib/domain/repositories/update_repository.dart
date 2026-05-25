import 'package:dartz/dartz.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/domain/entities/app_release.dart';

abstract class UpdateRepository {
  Future<Either<Failure, AppRelease>> getLatestRelease();
}
