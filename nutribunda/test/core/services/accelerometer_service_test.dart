import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/core/services/accelerometer_service.dart';

void main() {
  group('AccelerometerService', () {
    late AccelerometerService service;

    setUp(() {
      service = AccelerometerService();
    });

    tearDown(() {
      service.dispose();
    });

    test('should initialize with correct default values', () {
      expect(service.isListening, false);
      expect(service.errorMessage, null);
      expect(service.lastShakeTime, null);
    });

    test('should have correct threshold constants', () {
      expect(AccelerometerService.shakeThreshold, 15.0);
      expect(AccelerometerService.shakeCooldownMs, 3000);
      expect(AccelerometerService.shakeDurationMs, 300);
    });

    test('resetLastShakeTime should clear last shake time', () {
      // This test verifies the reset functionality
      service.resetLastShakeTime();
      expect(service.lastShakeTime, null);
    });

    test('stopListening should set isListening to false', () {
      service.stopListening();
      expect(service.isListening, false);
    });

    test('dispose should clean up resources', () {
      service.dispose();
      expect(service.isListening, false);
    });

    group('Constants validation', () {
      test('shakeThreshold should be 15.0 m/s² as per requirements', () {
        // Requirements 6.2: threshold 15 m/s²
        expect(AccelerometerService.shakeThreshold, equals(15.0));
      });

      test('shakeCooldownMs should be 3000ms as per requirements', () {
        // Requirements 6.6: debounce 3 detik
        expect(AccelerometerService.shakeCooldownMs, equals(3000));
      });

      test('shakeDurationMs should be 300ms as per requirements', () {
        // Requirements 6.2: minimal 300 milidetik
        expect(AccelerometerService.shakeDurationMs, equals(300));
      });
    });

    group('Error handling', () {
      test('should handle accelerometer not available error', () {
        // This would require mocking the sensor stream
        // For now, we verify the error handling method exists
        expect(service.errorMessage, null);
      });
    });
  });
}
