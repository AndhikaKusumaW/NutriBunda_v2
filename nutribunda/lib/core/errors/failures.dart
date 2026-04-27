import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({String message = 'Server error occurred'}) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache error occurred'}) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'Network error occurred'}) : super(message);
}

// Auth failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({String message = 'Authentication failed'}) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({String message = 'Unauthorized access'}) : super(message);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({String message = 'Validation failed'}) : super(message);
}

// Biometric failures
class BiometricFailure extends Failure {
  const BiometricFailure({String message = 'Biometric authentication failed'}) : super(message);
}

// Sensor failures
class SensorFailure extends Failure {
  const SensorFailure({String message = 'Sensor error occurred'}) : super(message);
}

// Location failures
class LocationFailure extends Failure {
  const LocationFailure({String message = 'Location error occurred'}) : super(message);
}
