import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Example classes to demonstrate mocking
abstract class DatabaseService {
  Future<String> getUserName(String userId);
  Future<void> saveData(String key, String value);
}

abstract class ApiService {
  Future<Map<String, dynamic>> fetchData(String endpoint);
}

// Generate mocks using build_runner:
// flutter pub run build_runner build
@GenerateMocks([DatabaseService, ApiService])
void main() {
  // Note: After running build_runner, import the generated mocks:
  // import 'mock_example_test.mocks.dart';
  
  group('Mockito Example Tests', () {
    test('mock basic usage example', () {
      // This is a conceptual example
      // In real usage, you would use the generated MockDatabaseService
      
      // Arrange
      // final mockDb = MockDatabaseService();
      // when(mockDb.getUserName('123')).thenAnswer((_) async => 'John Doe');
      
      // Act
      // final name = await mockDb.getUserName('123');
      
      // Assert
      // expect(name, equals('John Doe'));
      // verify(mockDb.getUserName('123')).called(1);
      
      // This test passes as a placeholder
      expect(true, isTrue);
    });

    test('mock with multiple calls example', () {
      // Conceptual example of verifying multiple calls
      
      // Arrange
      // final mockApi = MockApiService();
      // when(mockApi.fetchData(any)).thenAnswer(
      //   (_) async => {'status': 'success'},
      // );
      
      // Act
      // await mockApi.fetchData('/users');
      // await mockApi.fetchData('/posts');
      
      // Assert
      // verify(mockApi.fetchData(any)).called(2);
      
      expect(true, isTrue);
    });

    test('mock with argument matchers example', () {
      // Conceptual example of argument matchers
      
      // Arrange
      // final mockDb = MockDatabaseService();
      // when(mockDb.saveData(any, any)).thenAnswer((_) async => null);
      
      // Act
      // await mockDb.saveData('key1', 'value1');
      
      // Assert
      // verify(mockDb.saveData('key1', 'value1')).called(1);
      // verifyNever(mockDb.saveData('key2', 'value2'));
      
      expect(true, isTrue);
    });
  });

  group('Async Testing Examples', () {
    test('future completion test', () async {
      // Arrange
      Future<int> calculateAsync() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 42;
      }
      
      // Act
      final result = await calculateAsync();
      
      // Assert
      expect(result, equals(42));
    });

    test('stream testing example', () async {
      // Arrange
      Stream<int> countStream() async* {
        for (int i = 1; i <= 3; i++) {
          yield i;
        }
      }
      
      // Assert
      expect(
        countStream(),
        emitsInOrder([1, 2, 3, emitsDone]),
      );
    });
  });
}
