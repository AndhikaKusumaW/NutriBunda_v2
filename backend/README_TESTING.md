# Testing Guide - NutriBunda Backend

## Overview

Backend testing menggunakan framework **testify** untuk assertions dan test suites yang lebih ekspresif dan mudah dibaca.

## Testing Framework

### Testify

Testify menyediakan:
- **assert**: Assertions yang mudah dibaca
- **require**: Assertions yang menghentikan test jika gagal
- **suite**: Test suite dengan setup/teardown hooks
- **mock**: Mocking untuk dependencies

## Running Tests

### Run All Tests
```bash
go test ./...
```

### Run Tests with Verbose Output
```bash
go test -v ./...
```

### Run Tests with Coverage
```bash
go test -cover ./...
```

### Generate Coverage Report
```bash
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

### Run Specific Package Tests
```bash
go test ./internal/database
```

### Run Specific Test Function
```bash
go test -run TestDatabaseTestSuite ./internal/database
```

## Test Structure

### Basic Test Function
```go
func TestFunctionName(t *testing.T) {
    // Arrange
    expected := "expected value"
    
    // Act
    actual := FunctionToTest()
    
    // Assert
    assert.Equal(t, expected, actual, "should return expected value")
}
```

### Test Suite
```go
type MyTestSuite struct {
    suite.Suite
    // Add fields for shared test data
}

func (suite *MyTestSuite) SetupSuite() {
    // Runs once before all tests
}

func (suite *MyTestSuite) TearDownSuite() {
    // Runs once after all tests
}

func (suite *MyTestSuite) SetupTest() {
    // Runs before each test
}

func (suite *MyTestSuite) TearDownTest() {
    // Runs after each test
}

func (suite *MyTestSuite) TestSomething() {
    // Test implementation
    assert.True(suite.T(), true)
}

func TestMyTestSuite(t *testing.T) {
    suite.Run(t, new(MyTestSuite))
}
```

## Common Assertions

### Equality
```go
assert.Equal(t, expected, actual)
assert.NotEqual(t, expected, actual)
```

### Nil Checks
```go
assert.Nil(t, object)
assert.NotNil(t, object)
```

### Boolean
```go
assert.True(t, condition)
assert.False(t, condition)
```

### Strings
```go
assert.Contains(t, "hello world", "hello")
assert.NotContains(t, "hello world", "goodbye")
assert.Empty(t, "")
assert.NotEmpty(t, "text")
```

### Numbers
```go
assert.Greater(t, 5, 3)
assert.GreaterOrEqual(t, 5, 5)
assert.Less(t, 3, 5)
assert.LessOrEqual(t, 3, 3)
```

### Collections
```go
assert.Len(t, slice, 3)
assert.Empty(t, []int{})
assert.NotEmpty(t, []int{1, 2, 3})
```

### Errors
```go
assert.NoError(t, err)
assert.Error(t, err)
assert.EqualError(t, err, "expected error message")
```

## Testing Best Practices

### 1. Use Table-Driven Tests
```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a        int
        b        int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -2, -3, -5},
        {"mixed numbers", -2, 3, 1},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            assert.Equal(t, tt.expected, result)
        })
    }
}
```

### 2. Use Subtests for Organization
```go
func TestUserService(t *testing.T) {
    t.Run("Create", func(t *testing.T) {
        // Test user creation
    })
    
    t.Run("Update", func(t *testing.T) {
        // Test user update
    })
    
    t.Run("Delete", func(t *testing.T) {
        // Test user deletion
    })
}
```

### 3. Mock External Dependencies
```go
type MockDatabase struct {
    mock.Mock
}

func (m *MockDatabase) GetUser(id string) (*User, error) {
    args := m.Called(id)
    return args.Get(0).(*User), args.Error(1)
}

func TestGetUser(t *testing.T) {
    mockDB := new(MockDatabase)
    mockDB.On("GetUser", "123").Return(&User{ID: "123"}, nil)
    
    // Use mockDB in your test
    user, err := mockDB.GetUser("123")
    
    assert.NoError(t, err)
    assert.Equal(t, "123", user.ID)
    mockDB.AssertExpectations(t)
}
```

### 4. Test Error Cases
```go
func TestDivide(t *testing.T) {
    t.Run("valid division", func(t *testing.T) {
        result, err := Divide(10, 2)
        assert.NoError(t, err)
        assert.Equal(t, 5.0, result)
    })
    
    t.Run("division by zero", func(t *testing.T) {
        _, err := Divide(10, 0)
        assert.Error(t, err)
        assert.EqualError(t, err, "division by zero")
    })
}
```

### 5. Use require for Critical Assertions
```go
func TestCriticalOperation(t *testing.T) {
    db, err := ConnectDatabase()
    require.NoError(t, err, "database connection is critical")
    // Test continues only if connection succeeds
    
    user, err := db.GetUser("123")
    assert.NoError(t, err)
    assert.NotNil(t, user)
}
```

## Integration Testing

For integration tests that require database:

```go
func TestDatabaseIntegration(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test")
    }
    
    // Setup test database
    db := setupTestDB(t)
    defer cleanupTestDB(t, db)
    
    // Run integration tests
}
```

Run only unit tests:
```bash
go test -short ./...
```

Run all tests including integration:
```bash
go test ./...
```

## Property-Based Testing

For property-based tests (as mentioned in design document):

```go
func TestBMRCalculationProperty(t *testing.T) {
    // Property: BMR should always be positive for valid inputs
    for i := 0; i < 100; i++ {
        weight := float64(40 + rand.Intn(100))  // 40-140 kg
        height := float64(140 + rand.Intn(80))  // 140-220 cm
        age := 18 + rand.Intn(50)               // 18-68 years
        
        bmr := CalculateBMR(weight, height, age)
        assert.Greater(t, bmr, 0.0, "BMR should be positive")
    }
}
```

## CI/CD Integration

Add to your CI pipeline:

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
        with:
          go-version: 1.26
      - run: go test -v -cover ./...
```

## Example Test Files

See `internal/database/database_test.go` for a complete example of test suite setup.

## Resources

- [Testify Documentation](https://github.com/stretchr/testify)
- [Go Testing Package](https://pkg.go.dev/testing)
- [Table Driven Tests](https://dave.cheney.net/2019/05/07/prefer-table-driven-tests)
