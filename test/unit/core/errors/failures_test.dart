import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';

void main() {
  group('ServerFailure', () {
    test('should store message', () {
      const failure = ServerFailure('HTTP 500');

      expect(failure.message, 'HTTP 500');
    });

    test('should support value equality when message matches', () {
      const a = ServerFailure('err');
      const b = ServerFailure('err');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should not be equal when message differs', () {
      const a = ServerFailure('err1');
      const b = ServerFailure('err2');

      expect(a, isNot(equals(b)));
    });
  });

  group('NetworkFailure', () {
    test('should store message', () {
      const failure = NetworkFailure('No connection');

      expect(failure.message, 'No connection');
    });

    test('should support value equality', () {
      const a = NetworkFailure('err');
      const b = NetworkFailure('err');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should not be equal to ServerFailure', () {
      const a = NetworkFailure('err');
      const b = ServerFailure('err');

      expect(a, isNot(equals(b)));
    });
  });

  group('ParseFailure', () {
    test('should store message', () {
      const failure = ParseFailure('Invalid HTML');

      expect(failure.message, 'Invalid HTML');
    });

    test('should support value equality', () {
      const a = ParseFailure('err');
      const b = ParseFailure('err');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should not be equal to other failure types', () {
      const a = ParseFailure('err');
      const b = ServerFailure('err');
      const c = NetworkFailure('err');

      expect(a, isNot(equals(b)));
      expect(a, isNot(equals(c)));
    });
  });

  group('AuthFailure', () {
    test('should store message', () {
      const failure = AuthFailure('Login required');

      expect(failure.message, 'Login required');
    });

    test('should support value equality', () {
      const a = AuthFailure('err');
      const b = AuthFailure('err');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should not be equal to other failure types', () {
      const a = AuthFailure('err');

      expect(a, isNot(equals(const ServerFailure('err'))));
      expect(a, isNot(equals(const NetworkFailure('err'))));
      expect(a, isNot(equals(const ParseFailure('err'))));
    });
  });

  group('Failure cross-type', () {
    test(
      'all four types with same message should not be equal to each other',
      () {
        const server = ServerFailure('x');
        const network = NetworkFailure('x');
        const parse = ParseFailure('x');
        const auth = AuthFailure('x');

        expect({server, network, parse, auth}, hasLength(4));
      },
    );
  });
}
