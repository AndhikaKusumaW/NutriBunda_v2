# Testing Documentation

Dokumentasi lengkap untuk testing NutriBunda (Backend & Frontend).

## 📚 Contents

### Backend Testing
- [Backend Testing Overview](./backend/)

### Frontend Testing
- [Frontend Testing Guide](./frontend/README.md)
- [Quiz & Notification Tests](./frontend/quiz-notification-tests.md)
- [UI Navigation Tests](./frontend/ui-navigation-tests.md)

### Property-Based Testing
- [Property-Based Testing Overview](./property-based/)

## 🧪 Testing Strategy

### Backend Testing (Go)

#### Unit Tests
```bash
# Run all tests
go test ./...

# Run with verbose output
go test -v ./...

# Run with coverage
go test -cover ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

#### Test Framework
- **testify** - Assertions dan test suites
- **mock** - Mocking dependencies

#### Test Structure
```go
func TestFunctionName(t *testing.T) {
    // Arrange
    expected := "expected value"
    
    // Act
    actual := FunctionToTest()
    
    // Assert
    assert.Equal(t, expected, actual)
}
```

See: [Backend Testing Guide](../backend/testing-guide.md)

---

### Frontend Testing (Flutter)

#### Unit Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/providers/auth_provider_test.dart
```

#### Widget Tests
```bash
flutter test test/widgets/
```

#### Integration Tests
```bash
flutter test integration_test/
```

#### Test Framework
- **flutter_test** - Testing framework
- **mockito** - Mocking
- **integration_test** - Integration testing

#### Test Structure
```dart
testWidgets('should display login form', (tester) async {
  // Arrange
  await tester.pumpWidget(MyApp());
  
  // Act
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  // Assert
  expect(find.text('Login'), findsOneWidget);
});
```

See: [Frontend Testing Guide](./frontend/README.md)

---

## 📊 Test Coverage

### Backend Coverage

| Module | Coverage | Status |
|--------|----------|--------|
| Auth | 85% | ✅ Good |
| User | 80% | ✅ Good |
| Food | 75% | ⚠️ Needs improvement |
| Diary | 90% | ✅ Excellent |
| Recipe | 70% | ⚠️ Needs improvement |

### Frontend Coverage

| Module | Coverage | Status |
|--------|----------|--------|
| Providers | 85% | ✅ Good |
| Services | 80% | ✅ Good |
| Widgets | 60% | ⚠️ Needs improvement |
| Pages | 50% | ⚠️ Needs improvement |

---

## 🔬 Property-Based Testing

Property-based testing digunakan untuk memvalidasi correctness properties.

### Backend Properties

#### BMR Calculation
```go
// Property: BMR should always be positive for valid inputs
func TestBMRCalculationProperty(t *testing.T) {
    for i := 0; i < 100; i++ {
        weight := float64(40 + rand.Intn(100))
        height := float64(140 + rand.Intn(80))
        age := 18 + rand.Intn(50)
        
        bmr := CalculateBMR(weight, height, age)
        assert.Greater(t, bmr, 0.0)
    }
}
```

#### Nutrition Tracking
```go
// Property: Total calories should equal sum of individual entries
func TestNutritionTrackingProperty(t *testing.T) {
    entries := generateRandomEntries(10)
    
    totalCalories := 0.0
    for _, entry := range entries {
        totalCalories += entry.Calories
    }
    
    summary := CalculateNutritionSummary(entries)
    assert.Equal(t, totalCalories, summary.TotalCalories)
}
```

### Frontend Properties

#### Step Count Validation
```dart
test('step count should always be non-negative', () {
  for (int i = 0; i < 100; i++) {
    final steps = generateRandomSteps();
    expect(steps, greaterThanOrEqualTo(0));
  }
});
```

#### Calorie Calculation
```dart
test('calories burned should increase with more steps', () {
  final steps1 = 1000;
  final steps2 = 2000;
  
  final calories1 = calculateCalories(steps1);
  final calories2 = calculateCalories(steps2);
  
  expect(calories2, greaterThan(calories1));
});
```

See: [Property-Based Testing Documentation](./property-based/)

---

## 🎯 Testing Best Practices

### 1. Test Naming
```dart
// Good
test('should return user when login is successful')

// Bad
test('test1')
```

### 2. Arrange-Act-Assert Pattern
```dart
test('should calculate BMR correctly', () {
  // Arrange
  final weight = 70.0;
  final height = 170.0;
  final age = 30;
  
  // Act
  final bmr = calculateBMR(weight, height, age);
  
  // Assert
  expect(bmr, greaterThan(0));
});
```

### 3. Test Independence
```dart
// Each test should be independent
setUp(() {
  // Reset state before each test
  provider = AuthProvider();
});

tearDown(() {
  // Clean up after each test
  provider.dispose();
});
```

### 4. Mock External Dependencies
```dart
// Mock HTTP client
final mockClient = MockHttpClient();
when(mockClient.get(any)).thenAnswer((_) async => Response(data: testData));

// Use mock in test
final service = ApiService(client: mockClient);
```

### 5. Test Error Cases
```dart
test('should throw exception when API fails', () async {
  when(mockClient.get(any)).thenThrow(DioException());
  
  expect(
    () => service.fetchData(),
    throwsA(isA<ApiException>()),
  );
});
```

---

## 🚀 Running Tests in CI/CD

### GitHub Actions

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
      - run: go test -v -cover ./...
  
  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.x
      - run: flutter test --coverage
```

---

## 📝 Test Documentation

### Backend Tests
- [Auth Service Tests](../backend/modules/auth.md)
- [Diary Service Tests](../backend/modules/diary/property-testing.md)
- [Recipe Service Tests](../backend/modules/recipe/testing.md)

### Frontend Tests
- [Auth Provider Tests](./frontend/README.md)
- [Diary Provider Tests](./frontend/README.md)
- [Quiz & Notification Tests](./frontend/quiz-notification-tests.md)
- [UI Navigation Tests](./frontend/ui-navigation-tests.md)

### Property-Based Tests
- [Backend Property Tests](../backend/modules/diary/property-test-summary.md)
- [Frontend Property Tests](../tasks/task-8/task-8.3-property-tests.md)

---

## 🔗 Related Documentation

- [Backend Documentation](../backend/)
- [Frontend Documentation](../frontend/)
- [Implementation Guides](../implementation/)
- [Task Summaries](../tasks/)

---

**Last Updated**: April 29, 2026
