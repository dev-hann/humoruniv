import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humoruniv/presentation/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _idsKey = 'readPostsIds';
const _dimKey = 'dimReadPosts';

class ReadPostsState {
  const ReadPostsState({Set<int>? ids, this.dimEnabled = true})
    : ids = ids ?? const <int>{};

  /// Maximum number of read-post ids retained. Beyond this the oldest ids are
  /// dropped to keep SharedPreferences small.
  static const int maxIds = 2000;

  final Set<int> ids;
  final bool dimEnabled;

  /// Whether [id] should be visually treated as read. Always false when the
  /// dim toggle is off, regardless of whether the post has been read.
  bool isRead(int id) => dimEnabled && ids.contains(id);
}

class ReadPostsNotifier extends StateNotifier<ReadPostsState> {
  ReadPostsNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static ReadPostsState _load(SharedPreferences prefs) {
    final raw = prefs.getStringList(_idsKey) ?? const <String>[];
    // LinkedHashSet (Dart `{}`) preserves insertion order so we can trim FIFO.
    final ids = <int>{};
    for (final s in raw) {
      final v = int.tryParse(s);
      if (v != null) ids.add(v);
    }
    final dim = prefs.getBool(_dimKey) ?? true;
    return ReadPostsState(ids: ids, dimEnabled: dim);
  }

  /// Marks [id] as read. Idempotent. Trims to the most recent
  /// [ReadPostsState.maxIds] ids when the cap is exceeded.
  void markRead(int id) {
    if (state.ids.contains(id)) return;
    final ids = {...state.ids, id};
    final trimmed = ids.length > ReadPostsState.maxIds
        ? ids.skip(ids.length - ReadPostsState.maxIds).toSet()
        : ids;
    state = ReadPostsState(ids: trimmed, dimEnabled: state.dimEnabled);
    _persist(trimmed);
  }

  Future<void> setDimEnabled(bool value) async {
    state = ReadPostsState(ids: state.ids, dimEnabled: value);
    await _prefs.setBool(_dimKey, value);
  }

  Future<void> clear() async {
    state = ReadPostsState(ids: const <int>{}, dimEnabled: state.dimEnabled);
    await _prefs.setStringList(_idsKey, const <String>[]);
  }

  void _persist(Set<int> ids) {
    _prefs.setStringList(_idsKey, ids.map((e) => e.toString()).toList());
  }
}

final readPostsProvider =
    StateNotifierProvider<ReadPostsNotifier, ReadPostsState>(
      (ref) => ReadPostsNotifier(ref.read(sharedPreferencesProvider)),
    );
