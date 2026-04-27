import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/core/errors/failures.dart';
import 'package:nutribunda/core/utils/resource_state.dart';
import 'package:nutribunda/presentation/providers/base_provider.dart';

// Test implementation of BaseProvider
class TestProvider extends BaseProvider {
  int counter = 0;

  Future<void> incrementCounter() async {
    await executeWithLoading(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      counter++;
    });
  }

  Future<void> incrementCounterWithError() async {
    await executeWithLoading(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      throw Exception('Test error');
    });
  }

  Future<String> getDataWithState() async {
    final result = await executeWithState<String>(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return 'Test data';
    });

    if (result is Success<String>) {
      return result.data;
    }

    throw Exception('Failed to get data');
  }

  Future<String> getDataWithStateError() async {
    final result = await executeWithState<String>(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      throw Exception('Test error');
    });

    if (result is Error<String>) {
      throw result.failure;
    }

    return '';
  }
}

void main() {
  late TestProvider provider;

  setUp(() {
    provider = TestProvider();
  });

  tearDown(() {
    if (!provider.isDisposed) {
      provider.dispose();
    }
  });

  group('BaseProvider', () {
    test('initial state should be correct', () {
      expect(provider.isLoading, false);
      expect(provider.hasError, false);
      expect(provider.failure, null);
      expect(provider.errorMessage, null);
    });

    test('setLoading should update loading state', () {
      provider.setLoading(true);
      expect(provider.isLoading, true);

      provider.setLoading(false);
      expect(provider.isLoading, false);
    });

    test('setFailure should update failure state', () {
      const failure = ServerFailure(message: 'Test error');
      provider.setFailure(failure);

      expect(provider.hasError, true);
      expect(provider.failure, failure);
      expect(provider.errorMessage, 'Test error');
    });

    test('clearError should clear failure state', () {
      const failure = ServerFailure(message: 'Test error');
      provider.setFailure(failure);
      expect(provider.hasError, true);

      provider.clearError();
      expect(provider.hasError, false);
      expect(provider.failure, null);
    });

    test('executeWithLoading should handle success case', () async {
      expect(provider.isLoading, false);
      expect(provider.counter, 0);

      final future = provider.incrementCounter();
      
      // Should be loading during execution
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.isLoading, true);

      await future;

      // Should not be loading after completion
      expect(provider.isLoading, false);
      expect(provider.counter, 1);
      expect(provider.hasError, false);
    });

    test('executeWithLoading should handle error case', () async {
      expect(provider.isLoading, false);
      expect(provider.hasError, false);

      await provider.incrementCounterWithError();

      expect(provider.isLoading, false);
      expect(provider.hasError, true);
      expect(provider.failure, isA<ServerFailure>());
    });

    test('executeWithLoading should call onError callback', () async {
      Failure? capturedFailure;

      await provider.executeWithLoading(
        () async {
          throw Exception('Test error');
        },
        onError: (failure) {
          capturedFailure = failure;
        },
      );

      expect(capturedFailure, isNotNull);
      expect(capturedFailure, isA<ServerFailure>());
    });

    test('executeWithState should return Success on success', () async {
      final data = await provider.getDataWithState();
      expect(data, 'Test data');
    });

    test('executeWithState should return Error on failure', () async {
      expect(
        () => provider.getDataWithStateError(),
        throwsA(isA<Failure>()),
      );
    });

    test('resetState should reset all state', () {
      provider.setLoading(true);
      provider.setFailure(const ServerFailure(message: 'Test error'));

      provider.resetState();

      expect(provider.isLoading, false);
      expect(provider.hasError, false);
      expect(provider.failure, null);
    });

    test('should track disposed state correctly', () {
      expect(provider.isDisposed, false);
      
      provider.setLoading(true);
      expect(provider.isLoading, true);

      provider.dispose();
      expect(provider.isDisposed, true);
    });
  });
}
