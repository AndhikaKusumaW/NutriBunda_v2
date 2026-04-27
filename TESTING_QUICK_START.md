# Testing Quick Start Guide - NutriBunda

## Overview

This project uses comprehensive testing frameworks for both backend (Go) and frontend (Flutter).

## Backend Testing (Go + Testify)

### Setup Complete ✓
- **Framework**: testify
- **Location**: `backend/`
- **Documentation**: `backend/README_TESTING.md`

### Quick Commands

```bash
cd backend

# Run all tests
go test ./...

# Run with verbose output
go test -v ./...

# Run with coverage
go test -cover ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html

# Run specific package
go test ./internal/database

# Run specific test
go test -run TestDatabaseTestSuite ./internal/database
```

### Example Test Structure

```go
import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/suite"
)

// Test Suite
type MyTestSuite struct {
    suite.Suite
}

func (suite *MyTestSuite) TestSomething() {
    result := 2 + 2
    assert.Equal(suite.T(), 4, result)
}

func TestMyTestSuite(t *testing.T) {
    suite.Run(t, new(MyTestSuite))
}

// Simple Test
func TestSimple(t *testing.T) {
    assert.True(t, true)
    assert.NotNil(t, "value")
}
```

### Common Assertions

```go
assert.Equal(t, expected, actual)
assert.NotEqual(t, expected, actual)
assert.Nil(t, object)
assert.NotNil(t, object)
assert.True(t, condition)
assert.False(t, condition)
assert.NoError(t, err)
assert.Error(t, err)
assert.Contains(t, "hello world", "hello")
assert.Greater(t, 5, 3)
assert.Len(t, slice, 3)
```

---

## Frontend Testing (Flutter + Mockito)

### Setup Complete ✓
- **Framework**: flutter_test + mockito
- **Location**: `nutribunda/test/`
- **Documentation**: `nutribunda/README_TESTING.md`

### Quick Commands

```bash
cd nutribunda

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/example_test.dart

# Run in watch mode
flutter test --watch

# Generate mocks (when needed)
flutter pub run build_runner build
```

### Example Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('My Tests', () {
    test('basic test', () {
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
  testWidgets('widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Text('Hello'),
      ),
    );
    
    expect(find.text('Hello'), findsOneWidget);
  });
}
```

### Common Matchers

```dart
expect(value, equals(expected));
expect(value, isNull);
expect(value, isNotNull);
expect(value, isTrue);
expect(value, isFalse);
expect(value, greaterThan(5));
expect(value, lessThan(10));
expect(text, contains('substring'));
expect(list, hasLength(3));
expect(find.text('Hello'), findsOneWidget);
expect(find.text('Missing'), findsNothing);
```

---

## Test Files Created

### Backend (Go)
- ✓ `backend/internal/database/database_test.go` - Example test suite
- ✓ `backend/README_TESTING.md` - Comprehensive testing guide

### Frontend (Flutter)
- ✓ `nutribunda/test/example_test.dart` - Basic unit tests
- ✓ `nutribunda/test/mock_example_test.dart` - Mockito examples
- ✓ `nutribunda/test/widget_test_example.dart` - Widget tests
- ✓ `nutribunda/test/test_helpers.dart` - Test utilities
- ✓ `nutribunda/test/README.md` - Test directory guide
- ✓ `nutribunda/README_TESTING.md` - Comprehensive testing guide
- ✓ `nutribunda/build.yaml` - Build configuration for mocks

---

## Running Tests Verification

### Backend Tests ✓
```bash
cd backend
go test ./internal/database -v
```
**Status**: PASSED (2 tests)

### Frontend Tests ✓
```bash
cd nutribunda
flutter test test/example_test.dart test/mock_example_test.dart test/widget_test_example.dart
```
**Status**: PASSED (16 tests)

---

## Next Steps

### For Backend Development
1. Write tests for each new feature in `internal/<feature>/<feature>_test.go`
2. Use test suites for complex testing scenarios
3. Mock external dependencies using testify/mock
4. Aim for >80% code coverage

### For Frontend Development
1. Write unit tests for providers and services
2. Write widget tests for UI components
3. Use mockito for mocking dependencies
4. Generate mocks with `flutter pub run build_runner build`
5. Aim for >80% code coverage

---

## Property-Based Testing

Both testing frameworks support property-based testing as outlined in the design document:

### Go Example
```go
func TestBMRProperty(t *testing.T) {
    for i := 0; i < 100; i++ {
        weight := 40 + rand.Float64()*100
        height := 140 + rand.Float64()*80
        age := 18 + rand.Intn(50)
        
        bmr := CalculateBMR(weight, height, age)
        assert.Greater(t, bmr, 0.0)
    }
}
```

### Flutter Example
```dart
test('BMR is always positive', () {
  final random = Random();
  
  for (int i = 0; i < 100; i++) {
    final weight = 40 + random.nextDouble() * 100;
    final height = 140 + random.nextDouble() * 80;
    final age = 18 + random.nextInt(50);
    
    final bmr = calculateBMR(weight, height, age);
    expect(bmr, greaterThan(0));
  }
});
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests
on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
        with:
          go-version: 1.26
      - run: cd backend && go test -v -cover ./...
  
  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.11.0'
      - run: cd nutribunda && flutter pub get
      - run: cd nutribunda && flutter test --coverage
```

---

## Resources

- **Backend**: See `backend/README_TESTING.md` for detailed Go testing guide
- **Frontend**: See `nutribunda/README_TESTING.md` for detailed Flutter testing guide
- **Testify**: https://github.com/stretchr/testify
- **Flutter Testing**: https://docs.flutter.dev/testing
- **Mockito**: https://pub.dev/packages/mockito

---

## Test Coverage Goals

- **Unit Tests**: >80% coverage
- **Widget Tests**: All critical UI components
- **Integration Tests**: Key user flows
- **Property Tests**: Critical calculations (BMR, TDEE, nutrition tracking)

---

## Support

For questions or issues with testing:
1. Check the respective README_TESTING.md files
2. Review example test files
3. Consult official documentation links above
