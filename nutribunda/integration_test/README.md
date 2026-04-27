# Integration Tests - Authentication Flow

## Overview

Integration tests untuk authentication flow NutriBunda yang mencakup:

### Test Coverage

#### 1. Login Flow (Requirements 1.1-1.7)
- ✅ Complete login flow dengan valid credentials
- ✅ Error handling untuk invalid credentials
- ✅ Email format validation
- ✅ Empty field validation
- ✅ Network error handling
- ✅ Session persistence

#### 2. Logout Flow (Requirement 1.7)
- ✅ Complete logout flow
- ✅ JWT deletion dari secure storage
- ✅ Redirect ke login screen

#### 3. Biometric Authentication (Requirements 2.1-2.5)
- ✅ Biometric option availability check (2.1)
- ✅ Successful biometric authentication (2.2)
- ✅ Device support detection (2.3)
- ✅ Failed attempts lockout mechanism (2.4)
- ✅ Password confirmation before enabling (2.5)

#### 4. Error Scenarios
- ✅ Network errors
- ✅ Expired token handling
- ✅ Invalid credentials

#### 5. UI Interactions
- ✅ Password visibility toggle
- ✅ Navigation to register screen
- ✅ Loading indicators

## Prerequisites

### 1. Backend API Running

Integration tests memerlukan backend API yang berjalan. Pastikan:

```bash
cd backend
go run cmd/api/main.go
```

Backend harus berjalan di `http://localhost:8080` (atau sesuai konfigurasi di `ApiConstants`).

### 2. Test User Account

Buat test user account di backend atau gunakan credentials yang sudah ada:

```
Email: test@nutribunda.com
Password: Test1234
```

### 3. Device/Emulator Setup

- **Android**: Emulator atau device dengan API level 23+
- **iOS**: Simulator atau device dengan iOS 12+
- **Biometric**: Untuk test biometric, gunakan device/emulator yang support fingerprint/Face ID

## Running Tests

### Method 1: Run All Integration Tests

```bash
# Dari root directory nutribunda
flutter test integration_test/auth_flow_test.dart
```

### Method 2: Run with Driver (Recommended)

```bash
# Run dengan test driver untuk lebih banyak kontrol
flutter drive \
  --driver=integration_test/test_driver.dart \
  --target=integration_test/auth_flow_test.dart
```

### Method 3: Run on Specific Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter test integration_test/auth_flow_test.dart -d <device_id>
```

### Method 4: Run with Verbose Output

```bash
flutter test integration_test/auth_flow_test.dart --verbose
```

## Test Configuration

### Skipped Tests

Beberapa tests di-skip secara default karena memerlukan:
- Backend API yang berjalan
- Valid test credentials
- Biometric hardware/simulation

Untuk menjalankan skipped tests:

1. Pastikan backend berjalan
2. Update test credentials di file test
3. Remove `skip: true` dari test yang ingin dijalankan

### Environment Variables

Anda bisa menggunakan environment variables untuk konfigurasi:

```bash
# Set API base URL
export API_BASE_URL=http://localhost:8080

# Run tests
flutter test integration_test/auth_flow_test.dart
```

## Test Structure

```
integration_test/
├── auth_flow_test.dart       # Main integration test file
├── test_driver.dart           # Test driver for flutter drive
└── README.md                  # This file
```

## Troubleshooting

### Test Timeout

Jika test timeout, increase timeout duration:

```dart
testWidgets(
  'test name',
  (WidgetTester tester) async {
    // test code
  },
  timeout: Timeout(Duration(minutes: 2)),
);
```

### Backend Connection Issues

Jika tidak bisa connect ke backend:

1. Verify backend is running: `curl http://localhost:8080/health`
2. Check firewall settings
3. For Android emulator, use `10.0.2.2` instead of `localhost`
4. Update `ApiConstants.baseUrl` accordingly

### Biometric Tests Failing

Untuk test biometric di emulator:

**Android:**
```bash
# Enable fingerprint
adb -e emu finger touch 1
```

**iOS:**
```
# In simulator: Features > Face ID/Touch ID > Enrolled
# Then: Features > Face ID/Touch ID > Matching Touch/Face
```

### Clean State Between Tests

Jika tests interfere dengan each other:

```bash
# Clear app data
flutter clean
flutter pub get

# Uninstall app from device
adb uninstall com.example.nutribunda  # Android
# or manually delete from iOS simulator
```

## Best Practices

1. **Run tests in isolation**: Each test should be independent
2. **Clean up after tests**: Use `tearDown()` to clear state
3. **Use meaningful test names**: Describe what is being tested
4. **Mock external dependencies**: When possible, mock backend responses
5. **Test real user flows**: Integration tests should mimic actual user behavior

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test integration_test/auth_flow_test.dart
```

## Coverage Report

Generate coverage report:

```bash
flutter test integration_test/auth_flow_test.dart --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Additional Resources

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Integration Test Package](https://pub.dev/packages/integration_test)
- [Testing Best Practices](https://docs.flutter.dev/testing/best-practices)

## Notes

- Integration tests are slower than unit tests
- Run integration tests before major releases
- Consider running subset of tests during development
- Full test suite should run in CI/CD pipeline
- Some tests require manual interaction (biometric)
