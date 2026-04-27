# Test Directory Structure

This directory contains all tests for the NutriBunda Flutter application.

## Directory Structure

```
test/
├── README.md                    # This file
├── example_test.dart            # Basic unit test examples
├── mock_example_test.dart       # Mockito usage examples
├── widget_test_example.dart     # Widget testing examples
├── unit/                        # Unit tests (business logic)
│   ├── providers/              # Provider tests
│   ├── services/               # Service tests
│   └── utils/                  # Utility function tests
├── widget/                      # Widget tests (UI components)
│   ├── screens/                # Screen widget tests
│   └── components/             # Component widget tests
└── integration/                 # Integration tests (optional)
```

## Running Tests

### All Tests
```bash
flutter test
```

### Specific Test File
```bash
flutter test test/example_test.dart
```

### With Coverage
```bash
flutter test --coverage
```

### Watch Mode
```bash
flutter test --watch
```

## Test Naming Convention

- Unit tests: `<feature>_test.dart`
- Widget tests: `<widget_name>_widget_test.dart`
- Integration tests: `<flow_name>_integration_test.dart`

## Example Test Files

- `example_test.dart` - Demonstrates basic unit testing patterns
- `mock_example_test.dart` - Shows how to use Mockito for mocking
- `widget_test_example.dart` - Examples of widget testing

## Writing New Tests

1. Create test file with `_test.dart` suffix
2. Import `package:flutter_test/flutter_test.dart`
3. Use `test()` for unit tests or `testWidgets()` for widget tests
4. Group related tests with `group()`
5. Use descriptive test names

## Resources

See `../README_TESTING.md` for comprehensive testing guide.
