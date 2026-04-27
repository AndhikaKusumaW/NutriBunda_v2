import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Example Tests', () {
    test('basic arithmetic test', () {
      // Arrange
      const a = 2;
      const b = 3;
      
      // Act
      final result = a + b;
      
      // Assert
      expect(result, equals(5));
      expect(result, isPositive);
      expect(result, greaterThan(4));
    });

    test('string manipulation test', () {
      // Arrange
      const text = 'NutriBunda';
      
      // Act
      final lowercase = text.toLowerCase();
      
      // Assert
      expect(lowercase, equals('nutribunda'));
      expect(text, contains('Bunda'));
      expect(text.length, equals(10));
    });

    test('list operations test', () {
      // Arrange
      final numbers = [1, 2, 3, 4, 5];
      
      // Act
      final sum = numbers.reduce((a, b) => a + b);
      
      // Assert
      expect(sum, equals(15));
      expect(numbers, hasLength(5));
      expect(numbers, contains(3));
      expect(numbers, isNotEmpty);
    });
  });

  group('Error Handling Tests', () {
    test('exception throwing test', () {
      // Assert
      expect(
        () => throw Exception('Test error'),
        throwsException,
      );
    });

    test('null safety test', () {
      // Arrange
      String? nullableString;
      
      // Assert
      expect(nullableString, isNull);
      
      // Act
      nullableString = 'not null';
      
      // Assert
      expect(nullableString, isNotNull);
      expect(nullableString, equals('not null'));
    });
  });
}
