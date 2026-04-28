class ServerException implements Exception {
  final String message;
  
  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  
  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
}

class AuthenticationException implements Exception {
  final String message;
  
  AuthenticationException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  
  UnauthorizedException(this.message);
}

class ValidationException implements Exception {
  final String message;
  
  ValidationException(this.message);
}

class BiometricException implements Exception {
  final String message;
  
  BiometricException(this.message);
}

class SensorException implements Exception {
  final String message;
  
  SensorException(this.message);
}

class LocationException implements Exception {
  final String message;
  
  LocationException(this.message);
}

class ChatException implements Exception {
  final String message;
  final ChatErrorType type;
  
  ChatException(this.message, this.type);
  
  @override
  String toString() => message;
}

enum ChatErrorType {
  networkError,
  apiTimeout,
  invalidResponse,
  rateLimitExceeded,
  apiKeyInvalid,
  unknown,
}
