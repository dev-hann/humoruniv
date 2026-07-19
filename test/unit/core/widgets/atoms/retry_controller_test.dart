import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/atoms/retry_controller.dart';

void main() {
  group('RetryController', () {
    group('initial state', () {
      test('maxAttempts defaults to 3', () {
        final c = RetryController();
        addTearDown(c.dispose);
        expect(c.maxAttempts, 3);
      });

      test('retryDelay defaults to 500ms', () {
        final c = RetryController();
        addTearDown(c.dispose);
        expect(c.retryDelay, const Duration(milliseconds: 500));
      });

      test('attempt starts at 0', () {
        final c = RetryController();
        addTearDown(c.dispose);
        expect(c.attempt, 0);
      });

      test('hasError is false on fresh controller', () {
        final c = RetryController();
        addTearDown(c.dispose);
        expect(c.hasError, isFalse);
      });

      test('canAutoRetry is false on fresh controller', () {
        final c = RetryController(maxAttempts: 3);
        addTearDown(c.dispose);
        expect(c.canAutoRetry, isFalse);
      });

      test('isExhausted is false on fresh controller', () {
        final c = RetryController();
        addTearDown(c.dispose);
        expect(c.isExhausted, isFalse);
      });
    });

    group('after recordFailure (before retry timer fires)', () {
      test('hasError becomes true', () {
        fakeAsync((async) {
          final c = RetryController(maxAttempts: 3);
          addTearDown(c.dispose);

          c.recordFailure();

          expect(c.hasError, isTrue);
        });
      });

      test('canAutoRetry true when attempts remain', () {
        fakeAsync((async) {
          final c = RetryController(maxAttempts: 3);
          addTearDown(c.dispose);

          c.recordFailure();

          expect(c.canAutoRetry, isTrue);
        });
      });

      test('isExhausted false when attempts remain', () {
        fakeAsync((async) {
          final c = RetryController(maxAttempts: 3);
          addTearDown(c.dispose);

          c.recordFailure();

          expect(c.isExhausted, isFalse);
        });
      });

      test('isExhausted true on first failure when maxAttempts == 1', () {
        fakeAsync((async) {
          final c = RetryController(maxAttempts: 1);
          addTearDown(c.dispose);

          c.recordFailure();

          expect(c.isExhausted, isTrue);
          expect(c.canAutoRetry, isFalse);
        });
      });
    });

    group('after retry timer fires', () {
      test('hasError becomes false (new attempt starts)', () {
        fakeAsync((async) {
          final c = RetryController(
            maxAttempts: 3,
            retryDelay: const Duration(milliseconds: 100),
          );
          addTearDown(c.dispose);

          c.recordFailure();
          async.elapse(const Duration(milliseconds: 100));

          expect(c.hasError, isFalse);
          expect(c.attempt, 1);
        });
      });

      test('onRetry callback receives new attempt number', () {
        fakeAsync((async) {
          final attempts = <int>[];
          final c = RetryController(
            maxAttempts: 3,
            retryDelay: const Duration(milliseconds: 100),
            onRetry: attempts.add,
          );
          addTearDown(c.dispose);

          c.recordFailure();
          async.elapse(const Duration(milliseconds: 100));

          expect(attempts, [1]);
        });
      });

      test('each failure+retry advances attempt by 1', () {
        fakeAsync((async) {
          final c = RetryController(
            maxAttempts: 3,
            retryDelay: const Duration(milliseconds: 100),
          );
          addTearDown(c.dispose);

          c.recordFailure();
          async.elapse(const Duration(milliseconds: 100));
          expect(c.attempt, 1);
          expect(c.hasError, isFalse);

          c.recordFailure();
          async.elapse(const Duration(milliseconds: 100));
          expect(c.attempt, 2);
          expect(c.hasError, isFalse);

          c.recordFailure();
          expect(c.attempt, 2);
          expect(c.hasError, isTrue);
          expect(c.isExhausted, isTrue);
        });
      });

      test('exhausted controller does NOT schedule another retry', () {
        fakeAsync((async) {
          var retryCalls = 0;
          final c = RetryController(
            maxAttempts: 3,
            retryDelay: const Duration(milliseconds: 100),
            onRetry: (_) => retryCalls++,
          );
          addTearDown(c.dispose);

          for (var i = 0; i < 5; i++) {
            c.recordFailure();
            async.elapse(const Duration(milliseconds: 100));
          }

          expect(retryCalls, 2);
          expect(c.attempt, 2);
          expect(c.isExhausted, isTrue);
        });
      });
    });

    group('manualRetry', () {
      test('clears error state', () {
        fakeAsync((async) {
          final c = RetryController(
            maxAttempts: 1,
            retryDelay: const Duration(milliseconds: 100),
          );
          addTearDown(c.dispose);

          c.recordFailure();
          expect(c.isExhausted, isTrue);

          c.manualRetry();

          expect(c.hasError, isFalse);
          expect(c.attempt, 0);
          expect(c.isExhausted, isFalse);
        });
      });

      test('cancels pending auto-retry timer', () {
        fakeAsync((async) {
          var retryCalls = 0;
          final c = RetryController(
            maxAttempts: 3,
            retryDelay: const Duration(milliseconds: 500),
            onRetry: (_) => retryCalls++,
          );
          addTearDown(c.dispose);

          c.recordFailure();
          c.manualRetry();

          async.elapse(const Duration(seconds: 5));

          expect(retryCalls, 0);
          expect(c.attempt, 0);
          expect(c.hasError, isFalse);
        });
      });
    });

    group('resetForUrl', () {
      test('resets everything when URL changes', () {
        fakeAsync((async) {
          final c = RetryController(maxAttempts: 1);
          addTearDown(c.dispose);

          c.recordFailure();
          expect(c.isExhausted, isTrue);

          c.resetForUrl('new-url');

          expect(c.attempt, 0);
          expect(c.hasError, isFalse);
          expect(c.isExhausted, isFalse);
        });
      });

      test('no-op when URL is unchanged (empty default)', () {
        fakeAsync((async) {
          final c = RetryController(
            maxAttempts: 3,
            retryDelay: const Duration(milliseconds: 100),
          );
          addTearDown(c.dispose);

          c.recordFailure();
          async.elapse(const Duration(milliseconds: 100));
          expect(c.attempt, 1);

          c.resetForUrl('');

          expect(c.attempt, 1);
        });
      });
    });

    group('dispose', () {
      test('cancels pending timer', () {
        fakeAsync((async) {
          var retryCalls = 0;
          final c = RetryController(
            maxAttempts: 3,
            retryDelay: const Duration(milliseconds: 500),
            onRetry: (_) => retryCalls++,
          );

          c.recordFailure();
          c.dispose();

          async.elapse(const Duration(seconds: 5));

          expect(retryCalls, 0);
        });
      });
    });
  });
}
