/// Base class for all custom exceptions in the app
class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when there's an error communicating with the server
class ServerException extends AppException {
  const ServerException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Exception thrown when there's a cache-related error
class CacheException extends AppException {
  const CacheException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Exception thrown when there's an authentication-related error
class AuthenticationException extends AppException {
  const AuthenticationException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Exception thrown when a requested resource is not found
class NotFoundException extends AppException {
  const NotFoundException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Exception thrown when there's a validation error
class ValidationException extends AppException {
  const ValidationException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Exception thrown when there's a permission-related error
class PermissionException extends AppException {
  const PermissionException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
