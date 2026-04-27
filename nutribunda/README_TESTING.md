# Testing Guide - NutriBunda Flutter App

## Overview

Frontend testing menggunakan **flutter_test** untuk unit dan widget tests, serta **mockito** untuk mocking dependencies.

## Testing Framework

### Flutter Test
- **Unit Tests**: Test business logic dan functions
- **Widget Tests**: Test UI components dan interactions
- **Integration Tests**: Test complete user flows

### Mockito
- Generate mocks untuk dependencies
- Verify method calls dan interactions
- Stub return values untuk testing

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report (requires lcov)
```bash
# Install lcov (Windows with Chocolatey)
choco install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
start coverage/html/index.html
```

### Run Specific Test File
```bash
flutter test test/example_test.dart
```

### Run Tests with Name Pattern
```bash
flutter test --name "arithmetic"
```

### Run Tests in Watch Mode
```bash
flutter test --watch
```

## Test Structure

### Unit Test Example
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calculator Tests', () {
    test('addition works correctly', () {
      // Arrange
      const a = 2;
      const b = 3;
      
      // Act
      final result = a + b;
      
      // Assert
      expect(result, equals(5));
    });
  });
}
```

### Widget Test Example
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('button displays correct text', (WidgetTester tester) async {
    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: ElevatedButton(
          onPressed: () {},
          child: const Text('Click Me'),
        ),
      ),
    );

    // Verify
    expect(find.text('Click Me'), findsOneWidget);
  });
}
```

## Mockito Setup

### 1. Add Annotations
```dart
import 'package:mockito/annotations.dart';

// Define the class to mock
abstract class ApiService {
  Future<User> getUser(String id);
}

// Generate mock
@GenerateMocks([ApiService])
void main() {
  // Tests here
}
```

### 2. Generate Mocks
```bash
flutter pub run build_runner build
```

This creates a `.mocks.dart` file with generated mock classes.

### 3. Use Mocks in Tests
```dart
import 'package:mockito/mockito.dart';
import 'my_test.mocks.dart';

void main() {
  test('fetch user test', () async {
    // Arrange
    final mockApi = MockApiService();
    when(mockApi.getUser('123')).thenAnswer(
      (_) async => User(id: '123', name: 'John'),
    );
    
    // Act
    final user = await mockApi.getUser('123');
    
    // Assert
    expect(user.name, equals('John'));
    verify(mockApi.getUser('123')).called(1);
  });
}
```

## Common Test Patterns

### Testing Async Code
```dart
test('async operation test', () async {
  // Use async/await
  final result = await fetchData();
  expect(result, isNotNull);
});
```

### Testing Streams
```dart
test('stream emits correct values', () {
  final stream = Stream.fromIterable([1, 2, 3]);
  
  expect(
    stream,
    emitsInOrder([1, 2, 3, emitsDone]),
  );
});
```

### Testing Exceptions
```dart
test('throws exception on invalid input', () {
  expect(
    () => divide(10, 0),
    throwsA(isA<ArgumentError>()),
  );
});
```

### Widget Interaction Tests
```dart
testWidgets('button tap triggers callback', (tester) async {
  bool tapped = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: ElevatedButton(
        onPressed: () => tapped = true,
        child: const Text('Tap Me'),
      ),
    ),
  );
  
  await tester.tap(find.text('Tap Me'));
  await tester.pump();
  
  expect(tapped, isTrue);
});
```

### Text Input Tests
```dart
testWidgets('text field accepts input', (tester) async {
  final controller = TextEditingController();
  
  await tester.pumpWidget(
    MaterialApp(
      home: TextField(controller: controller),
    ),
  );
  
  await tester.enterText(find.byType(TextField), 'Hello');
  expect(controller.text, equals('Hello'));
});
```

### Navigation Tests
```dart
testWidgets('navigation works', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SecondPage()),
          ),
          child: const Text('Navigate'),
        ),
      ),
    ),
  );
  
  await tester.tap(find.text('Navigate'));
  await tester.pumpAndSettle();
  
  expect(find.byType(SecondPage), findsOneWidget);
});
```

## Common Matchers

### Equality
```dart
expect(actual, equals(expected));
expect(actual, isNot(equals(expected)));
```

### Type Checking
```dart
expect(value, isA<String>());
expect(value, isNotA<int>());
```

### Null Checks
```dart
expect(value, isNull);
expect(value, isNotNull);
```

### Numeric
```dart
expect(value, greaterThan(5));
expect(value, lessThan(10));
expect(value, greaterThanOrEqualTo(5));
expect(value, lessThanOrEqualTo(10));
expect(value, closeTo(3.14, 0.01));
```

### Strings
```dart
expect(text, contains('substring'));
expect(text, startsWith('prefix'));
expect(text, endsWith('suffix'));
expect(text, matches(RegExp(r'\d+')));
```

### Collections
```dart
expect(list, isEmpty);
expect(list, isNotEmpty);
expect(list, hasLength(3));
expect(list, contains(item));
expect(list, containsAll([1, 2, 3]));
```

### Widget Finders
```dart
expect(find.text('Hello'), findsOneWidget);
expect(find.text('Missing'), findsNothing);
expect(find.byType(ElevatedButton), findsWidgets);
expect(find.byKey(Key('my_key')), findsOneWidget);
```

## Mockito Verification

### Verify Method Calls
```dart
verify(mock.method()).called(1);
verify(mock.method()).called(greaterThan(1));
verifyNever(mock.method());
verifyNoMoreInteractions(mock);
```

### Argument Matchers
```dart
when(mock.method(any)).thenReturn(value);
when(mock.method(argThat(isNotNull))).thenReturn(value);
verify(mock.method(captureAny));
```

### Stubbing
```dart
// Return value
when(mock.method()).thenReturn(value);

// Return future
when(mock.method()).thenAnswer((_) async => value);

// Throw exception
when(mock.method()).thenThrow(Exception('error'));

// Multiple calls
when(mock.method())
  .thenReturn(value1)
  .thenReturn(value2);
```

## Testing Best Practices

### 1. Use setUp and tearDown
```dart
void main() {
  late MyService service;
  
  setUp(() {
    service = MyService();
  });
  
  tearDown(() {
    service.dispose();
  });
  
  test('test 1', () {
    // Use service
  });
}
```

### 2. Group Related Tests
```dart
void main() {
  group('Authentication', () {
    test('login succeeds with valid credentials', () {});
    test('login fails with invalid credentials', () {});
  });
  
  group('User Profile', () {
    test('profile loads correctly', () {});
    test('profile updates successfully', () {});
  });
}
```

### 3. Use Descriptive Test Names
```dart
// Good
test('calculateBMR returns positive value for valid inputs', () {});

// Bad
test('test1', () {});
```

### 4. Test Edge Cases
```dart
group('BMR Calculation', () {
  test('handles minimum valid values', () {});
  test('handles maximum valid values', () {});
  test('throws error for negative weight', () {});
  test('throws error for zero height', () {});
});
```

### 5. Keep Tests Independent
```dart
// Each test should be able to run independently
test('test A', () {
  // Don't rely on state from test B
});

test('test B', () {
  // Don't rely on state from test A
});
```

## Property-Based Testing

For property-based tests (as mentioned in design document):

```dart
import 'dart:math';

test('BMR is always positive for valid inputs', () {
  final random = Random();
  
  for (int i = 0; i < 100; i++) {
    final weight = 40 + random.nextDouble() * 100; // 40-140 kg
    final height = 140 + random.nextDouble() * 80;  // 140-220 cm
    final age = 18 + random.nextInt(50);            // 18-68 years
    
    final bmr = calculateBMR(weight, height, age);
    
    expect(bmr, greaterThan(0), 
      reason: 'BMR should be positive for weight=$weight, height=$height, age=$age');
  }
});
```

## Integration Testing

Create integration tests in `integration_test/` directory:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete user flow test', (tester) async {
    // Launch app
    await tester.pumpWidget(MyApp());
    
    // Login
    await tester.enterText(find.byKey(Key('email')), 'test@example.com');
    await tester.enterText(find.byKey(Key('password')), 'password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    
    // Verify home screen
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
```

Run integration tests:
```bash
flutter test integration_test
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.11.0'
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
        with:
          files: coverage/lcov.info
```

## Example Test Files

- `test/example_test.dart` - Basic unit tests
- `test/mock_example_test.dart` - Mockito examples
- `test/widget_test_example.dart` - Widget testing examples

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)
