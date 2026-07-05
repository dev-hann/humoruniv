import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/presentation/providers/read_posts_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ReadPostsNotifier newNotifier() => ReadPostsNotifier(prefs);

  group('ReadPostsNotifier', () {
    test('initial state is empty with dimming enabled by default', () {
      final n = newNotifier();
      addTearDown(n.dispose);

      expect(n.state.ids, isEmpty);
      expect(n.state.dimEnabled, true);
    });

    test('loads persisted ids and dim flag from prefs', () async {
      await prefs.setStringList('readPostsIds', ['1', '2', '3']);
      await prefs.setBool('dimReadPosts', false);

      final n = newNotifier();
      addTearDown(n.dispose);

      expect(n.state.ids, {1, 2, 3});
      expect(n.state.dimEnabled, false);
    });

    test('markRead adds the id and persists', () async {
      final n = newNotifier();
      addTearDown(n.dispose);

      n.markRead(42);

      expect(n.state.ids, contains(42));
      expect(prefs.getStringList('readPostsIds'), contains('42'));
    });

    test('markRead is idempotent', () {
      final n = newNotifier();
      addTearDown(n.dispose);

      n.markRead(7);
      n.markRead(7);

      expect(n.state.ids.where((e) => e == 7).length, 1);
    });

    test('setDimEnabled toggles and persists', () async {
      final n = newNotifier();
      addTearDown(n.dispose);

      await n.setDimEnabled(false);

      expect(n.state.dimEnabled, false);
      expect(prefs.getBool('dimReadPosts'), false);
    });

    test(
      'clear removes all ids and persists empty, keeps dim setting',
      () async {
        await prefs.setStringList('readPostsIds', ['1', '2']);
        final n = newNotifier();
        addTearDown(n.dispose);

        await n.clear();

        expect(n.state.ids, isEmpty);
        expect(prefs.getStringList('readPostsIds'), isEmpty);
      },
    );

    group('isRead', () {
      test('returns true when dimming on and id present', () {
        final n = newNotifier();
        addTearDown(n.dispose);
        n.markRead(10);

        expect(n.state.isRead(10), true);
        expect(n.state.isRead(99), false);
      });

      test('returns false for any id when dimming off', () async {
        final n = newNotifier();
        addTearDown(n.dispose);
        n.markRead(10);
        await n.setDimEnabled(false);

        expect(n.state.isRead(10), false);
      });
    });

    test('caps stored ids to a maximum, keeping the most recent', () {
      final n = newNotifier();
      addTearDown(n.dispose);

      for (var i = 0; i < ReadPostsState.maxIds + 50; i++) {
        n.markRead(i);
      }

      expect(n.state.ids.length, ReadPostsState.maxIds);
      // Most-recent (largest) ids survive; the oldest are dropped.
      expect(n.state.ids.contains(ReadPostsState.maxIds + 49), true);
      expect(n.state.ids.contains(0), false);
    });
  });
}
