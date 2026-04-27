import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/core/utils/resource_state.dart';
import 'package:nutribunda/core/errors/failures.dart';
import 'package:nutribunda/presentation/providers/stateful_provider.dart';

// Test implementation of StatefulProvider
class TestStatefulProvider extends StatefulProvider<String> {
  Future<void> loadData() async {
    await executeWithStateManagement(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return 'Test data';
    });
  }

  Future<void> loadDataWithError() async {
    await executeWithStateManagement(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      throw Exception('Test error');
    });
  }

  void setCustomState(ResourceState<String> newState) {
    setState(newState);
  }
}

void main() {
  late TestStatefulProvider provider;

  setUp(() {
    provider = TestStatefulProvider();
  });

  tearDown(() {
    provider.dispose();
  });

  group('StatefulProvider', () {
    test('initial state should be Initial', () {
      expect(provider.state, isA<Initial<String>>());
      expect(provider.isStateInitial, true);
      expect(provider.isStateLoading, false);
      expect(provider.isStateSuccess, false);
      expect(provider.isStateError, false);
      expect(provider.data, null);
    });

    test('setState should update state correctly', () {
      const newState = Success<String>('Test data');
      provider.setCustomState(newState);

      expect(provider.state, newState);
      expect(provider.isStateSuccess, true);
      expect(provider.data, 'Test data');
    });

    test('setState with Error should update failure', () {
      const failure = ServerFailure(message: 'Test error');
      const errorState = Error<String>(failure);
      provider.setCustomState(errorState);

      expect(provider.state, errorState);
      expect(provider.isStateError, true);
      expect(provider.hasError, true);
      expect(provider.failure, failure);
    });

    test('setState with Loading should update loading state', () {
      const loadingState = Loading<String>();
      provider.setCustomState(loadingState);

      expect(provider.state, loadingState);
      expect(provider.isStateLoading, true);
      expect(provider.isLoading, true);
    });

    test('executeWithStateManagement should handle success', () async {
      expect(provider.isStateInitial, true);

      final future = provider.loadData();

      // Should be loading during execution
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.isStateLoading, true);

      await future;

      // Should be success after completion
      expect(provider.isStateSuccess, true);
      expect(provider.data, 'Test data');
      expect(provider.hasError, false);
    });

    test('executeWithStateManagement should handle error', () async {
      expect(provider.isStateInitial, true);

      await provider.loadDataWithError();

      expect(provider.isStateError, true);
      expect(provider.hasError, true);
      expect(provider.failure, isA<ServerFailure>());
      expect(provider.data, null);
    });

    test('data getter should return null for non-Success states', () {
      provider.setCustomState(const Initial<String>());
      expect(provider.data, null);

      provider.setCustomState(const Loading<String>());
      expect(provider.data, null);

      const failure = ServerFailure(message: 'Error');
      provider.setCustomState(const Error<String>(failure));
      expect(provider.data, null);
    });

    test('data getter should return data for Success state', () {
      provider.setCustomState(const Success<String>('Test data'));
      expect(provider.data, 'Test data');
    });

    test('resetState should reset to Initial', () {
      provider.setCustomState(const Success<String>('Test data'));
      expect(provider.isStateSuccess, true);

      provider.resetState();

      expect(provider.isStateInitial, true);
      expect(provider.isLoading, false);
      expect(provider.hasError, false);
    });

    test('state changes should notify listeners', () {
      var notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.setCustomState(const Loading<String>());
      expect(notifyCount, 1);

      provider.setCustomState(const Success<String>('Data'));
      expect(notifyCount, 2);

      provider.setCustomState(
        const Error<String>(ServerFailure(message: 'Error')),
      );
      expect(notifyCount, 3);
    });
  });
}
