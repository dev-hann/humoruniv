import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humoruniv/di/injection.dart';
import 'package:humoruniv/domain/entities/app_release.dart';
import 'package:humoruniv/domain/usecases/check_for_update.dart';

enum UpdateCheckStatus { idle, checking, available, upToDate, error }

class UpdateState {
  const UpdateState({
    this.status = UpdateCheckStatus.idle,
    this.release,
  });
  final UpdateCheckStatus status;
  final AppRelease? release;

  UpdateState copyWith({
    UpdateCheckStatus? status,
    AppRelease? release,
  }) =>
      UpdateState(
        status: status ?? this.status,
        release: release ?? this.release,
      );
}

class UpdateNotifier extends StateNotifier<UpdateState> {
  UpdateNotifier(this._checkForUpdate) : super(const UpdateState());
  final CheckForUpdate _checkForUpdate;

  Future<void> checkForUpdate() async {
    state = const UpdateState(status: UpdateCheckStatus.checking);

    final result = await _checkForUpdate();

    result.fold(
      (_) => state = const UpdateState(status: UpdateCheckStatus.error),
      (checkResult) {
        if (checkResult.isUpdateAvailable) {
          state = UpdateState(
            status: UpdateCheckStatus.available,
            release: checkResult.release,
          );
        } else {
          state = UpdateState(
            status: UpdateCheckStatus.upToDate,
            release: checkResult.release,
          );
        }
      },
    );
  }
}

final updateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>(
  (ref) => UpdateNotifier(sl<CheckForUpdate>()),
);
