import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humoruniv/presentation/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _nsfwEnabledKey = 'nsfwEnabled';
const _nsfwAcknowledgedKey = 'nsfwAcknowledged';

final nsfwProvider = StateNotifierProvider<NsfwNotifier, bool>(
  (ref) => NsfwNotifier(ref.read(sharedPreferencesProvider)),
);

class NsfwNotifier extends StateNotifier<bool> {
  NsfwNotifier(this._prefs) : super(_prefs.getBool(_nsfwEnabledKey) ?? true);

  final SharedPreferences _prefs;

  void toggle() {
    state = !state;
    _prefs.setBool(_nsfwEnabledKey, state);
  }

  void setEnabled(bool enabled) {
    state = enabled;
    _prefs.setBool(_nsfwEnabledKey, state);
  }
}

final nsfwAcknowledgedProvider =
    StateNotifierProvider<NsfwAcknowledgedNotifier, bool>(
      (ref) => NsfwAcknowledgedNotifier(ref.read(sharedPreferencesProvider)),
    );

class NsfwAcknowledgedNotifier extends StateNotifier<bool> {
  NsfwAcknowledgedNotifier(this._prefs)
    : super(_prefs.getBool(_nsfwAcknowledgedKey) ?? false);

  final SharedPreferences _prefs;

  void acknowledge() {
    state = true;
    _prefs.setBool(_nsfwAcknowledgedKey, true);
  }
}
