import 'package:meta/meta.dart';

@immutable
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ParseFailure extends Failure {
  const ParseFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
