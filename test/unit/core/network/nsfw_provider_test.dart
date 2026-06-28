import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/presentation/providers/nsfw_provider.dart';
import 'package:humoruniv/presentation/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('NsfwNotifier', () {
    test('should start with nsfw warning enabled', () {
      final container = makeContainer();
      expect(container.read(nsfwProvider), true);
    });

    test('should toggle to disabled', () {
      final container = makeContainer();
      container.read(nsfwProvider.notifier).toggle();
      expect(container.read(nsfwProvider), false);
    });

    test('should toggle back to enabled', () {
      final container = makeContainer();
      container.read(nsfwProvider.notifier).toggle();
      container.read(nsfwProvider.notifier).toggle();
      expect(container.read(nsfwProvider), true);
    });

    test('should set enabled explicitly', () {
      final container = makeContainer();
      container.read(nsfwProvider.notifier).setEnabled(false);
      expect(container.read(nsfwProvider), false);
      container.read(nsfwProvider.notifier).setEnabled(true);
      expect(container.read(nsfwProvider), true);
    });

    test('should persist enabled state across instances', () {
      final container = makeContainer();
      container.read(nsfwProvider.notifier).setEnabled(false);
      container.dispose();

      final next = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(next.dispose);

      expect(next.read(nsfwProvider), false);
    });
  });

  group('NsfwAcknowledgedNotifier', () {
    test('should start unacknowledged', () {
      final container = makeContainer();
      expect(container.read(nsfwAcknowledgedProvider), false);
    });

    test('should become acknowledged after acknowledge()', () {
      final container = makeContainer();
      container.read(nsfwAcknowledgedProvider.notifier).acknowledge();
      expect(container.read(nsfwAcknowledgedProvider), true);
    });

    test('should persist acknowledgement across instances', () {
      final container = makeContainer();
      container.read(nsfwAcknowledgedProvider.notifier).acknowledge();
      container.dispose();

      final next = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(next.dispose);

      expect(next.read(nsfwAcknowledgedProvider), true);
    });
  });
}
