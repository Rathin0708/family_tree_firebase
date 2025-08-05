import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

// Family failures
class FamilyNotFoundFailure extends Failure {
  const FamilyNotFoundFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class InvalidInviteCodeFailure extends Failure {
  const InvalidInviteCodeFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class AlreadyInFamilyFailure extends Failure {
  const AlreadyInFamilyFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
