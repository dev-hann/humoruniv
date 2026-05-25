import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/presentation/providers/nsfw_provider.dart';

void main() {
  group('NsfwNotifier', () {
    test('should start with nsfw warning enabled', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(nsfwProvider), true);
    });

    test('should toggle to disabled', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(nsfwProvider.notifier).toggle();

      expect(container.read(nsfwProvider), false);
    });

    test('should toggle back to enabled', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(nsfwProvider.notifier).toggle();
      container.read(nsfwProvider.notifier).toggle();

      expect(container.read(nsfwProvider), true);
    });

    test('should set enabled explicitly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(nsfwProvider.notifier).setEnabled(false);

      expect(container.read(nsfwProvider), false);

      container.read(nsfwProvider.notifier).setEnabled(true);

      expect(container.read(nsfwProvider), true);
    });
  });
}
