# Property-Based Testing for Nutrition Tracking

## Overview

This directory contains property-based tests for the Nutrition Tracking feature (Task 4.3). These tests validate **Property 3: Nutrition tracking consistency** as specified in Requirements 4.3 and 4.5.

## Property Being Tested

**Property 3: Nutrition Tracking Consistency**

The nutrition tracking system must maintain mathematical consistency when entries are added and removed:

1. **Inverse Operation**: Adding an entry and then removing the same entry should result in the original nutrition state
2. **Commutativity**: The order of adding entries should not affect the final nutrition summary
3. **Associativity**: Grouping of nutrition calculations should not affect the result
4. **Non-negativity**: Nutrition values should never become negative
5. **Profile Isolation**: Baby and mother profiles should be completely isolated

## Test Files

- `service_property_test.go` - Contains all property-based tests for nutrition tracking

## Test Functions

### 1. TestProperty_NutritionTrackingConsistency_AddRemove
- **Iterations**: 100
- **Property**: Adding and removing the same entry results in original state
- **Validates**: Requirements 4.3, 4.5

### 2. TestProperty_NutritionTrackingConsistency_MultipleEntries
- **Iterations**: 50 (with 5 entries each)
- **Property**: Multiple add/remove operations maintain consistency
- **Validates**: Requirements 4.3, 4.5

### 3. TestProperty_NutritionTrackingConsistency_Commutativity
- **Iterations**: 30 (with 4 entries each)
- **Property**: Order of adding entries doesn't affect final summary
- **Validates**: Requirement 4.3

### 4. TestProperty_NutritionTrackingConsistency_Associativity
- **Iterations**: 50
- **Property**: (a + b) + c = a + (b + c) for nutrition calculations
- **Validates**: Requirement 4.3

### 5. TestProperty_NutritionTrackingConsistency_NonNegativity
- **Iterations**: 100
- **Property**: Nutrition values never become negative
- **Validates**: Requirements 4.3, 4.5

### 6. TestProperty_NutritionTrackingConsistency_ProfileIsolation
- **Iterations**: 50
- **Property**: Baby and mother profiles are completely isolated
- **Validates**: Requirement 4.1, 4.2

## Running the Tests

### Prerequisites

The property tests require CGO to be enabled because they use SQLite for in-memory testing.

**Windows:**
1. Install TDM-GCC or MinGW-w64 to get a C compiler
2. Add the compiler to your PATH
3. Ensure CGO is enabled (it's enabled by default)

**Linux/Mac:**
- GCC is usually pre-installed
- If not, install build-essential (Linux) or Xcode Command Line Tools (Mac)

### Run All Property Tests

```bash
cd backend
go test -v -run TestProperty ./internal/diary
```

### Run Specific Property Test

```bash
cd backend
go test -v -run TestProperty_NutritionTrackingConsistency_AddRemove ./internal/diary
```

### Run with Coverage

```bash
cd backend
go test -v -cover -run TestProperty ./internal/diary
```

### Run All Tests (Unit + Property)

```bash
cd backend
go test -v ./internal/diary
```

## Test Strategy

### Randomization
- Each test uses randomized inputs (food items, serving sizes, dates, profiles)
- Seeds are based on time + iteration number for reproducibility
- Random values are within realistic ranges:
  - Calories: 0-600 kcal per 100g
  - Protein: 0-60g per 100g
  - Carbs: 0-100g per 100g
  - Fat: 0-50g per 100g
  - Serving size: 50-350 grams

### Assertions
- Uses `assert.InDelta` with tolerance of 0.01 for floating-point comparisons
- This accounts for floating-point arithmetic precision issues

### Database Setup
- Each test iteration uses a fresh in-memory SQLite database
- Ensures complete isolation between test runs
- No test pollution or side effects

## Expected Results

All property tests should **PASS** if the nutrition tracking implementation is correct.

If any test fails, it indicates a violation of the mathematical properties that the nutrition tracking system must uphold.

## Troubleshooting

### Error: "gcc not found"

**Solution**: Install a C compiler:
- **Windows**: Install TDM-GCC from https://jmeubank.github.io/tdm-gcc/
- **Linux**: `sudo apt-get install build-essential`
- **Mac**: `xcode-select --install`

### Error: "CGO_ENABLED=0"

**Solution**: Enable CGO:
```bash
export CGO_ENABLED=1  # Linux/Mac
$env:CGO_ENABLED="1"  # Windows PowerShell
```

### Tests are slow

This is expected. Property-based tests run many iterations with randomized inputs. The full suite may take 10-30 seconds to complete.

## Integration with CI/CD

For CI/CD pipelines, ensure:
1. C compiler is available in the build environment
2. CGO is enabled
3. Sufficient timeout is configured (at least 60 seconds for property tests)

Example GitHub Actions:
```yaml
- name: Run Property Tests
  run: |
    cd backend
    go test -v -timeout 60s -run TestProperty ./internal/diary
```

## References

- **Requirements**: `.kiro/specs/nutribunda/requirements.md` (Requirements 4.3, 4.5)
- **Design**: `.kiro/specs/nutribunda/design.md` (Property 3: Nutrition tracking consistency)
- **Tasks**: `.kiro/specs/nutribunda/tasks.md` (Task 4.3)
