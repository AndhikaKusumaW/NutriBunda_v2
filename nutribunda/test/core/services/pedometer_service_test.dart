import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/core/services/pedometer_service.dart';

void main() {
  late PedometerService service;

  setUp(() {
    service = PedometerService();
  });

  tearDown(() {
    service.dispose();
  });

  group('PedometerService - Initial State', () {
    test('initial state should be correct', () {
      expect(service.currentSteps, 0);
      expect(service.initialSteps, 0);
      expect(service.pedestrianStatus, 'unknown');
      expect(service.errorMessage, null);
      expect(service.isListening, false);
    });
  });

  group('PedometerService - Step Management', () {
    test('setSteps should update current steps', () {
      // Act
      service.setSteps(1000);
      
      // Assert
      expect(service.currentSteps, 1000);
    });

    test('resetDailySteps should reset current steps to 0', () {
      // Arrange
      service.setSteps(5000);
      
      // Act
      service.resetDailySteps();
      
      // Assert
      expect(service.currentSteps, 0);
      expect(service.initialSteps, 5000);
    });

    test('resetDailySteps should preserve total step count in initialSteps', () {
      // Arrange
      service.setSteps(3000);
      final firstTotal = service.currentSteps + service.initialSteps;
      
      // Act
      service.resetDailySteps();
      service.setSteps(2000);
      final secondTotal = service.currentSteps + service.initialSteps;
      
      // Assert
      expect(secondTotal, firstTotal + 2000);
    });
  });

  group('PedometerService - Lifecycle', () {
    test('startListening should set isListening to true', () {
      // Note: This test requires platform channels which are not available in unit tests
      // Skip this test as it requires integration testing
    }, skip: 'Requires platform channels - test in integration tests');

    test('stopListening should set isListening to false', () {
      // Note: This test requires platform channels which are not available in unit tests
      // Skip this test as it requires integration testing
    }, skip: 'Requires platform channels - test in integration tests');

    test('dispose should stop listening', () {
      // Note: This test requires platform channels which are not available in unit tests
      // Skip this test as it requires integration testing
    }, skip: 'Requires platform channels - test in integration tests');

    test('startListening should not start twice', () {
      // Note: This test requires platform channels which are not available in unit tests
      // Skip this test as it requires integration testing
    }, skip: 'Requires platform channels - test in integration tests');
  });

  group('PedometerService - Error Handling', () {
    test('errorMessage should be null initially', () {
      expect(service.errorMessage, null);
    });
  });
}
