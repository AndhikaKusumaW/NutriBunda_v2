import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/presentation/providers/diet_plan_provider.dart';
import 'package:nutribunda/data/models/user_model.dart';
import 'dart:math';

/// Property-Based Test untuk BMR/TDEE Calculations
/// **Validates: Requirements 5.1, 5.2, 5.3**
/// 
/// Requirement 5.1: BMR calculation using Mifflin-St Jeor formula
/// BMR = (10 × weight_kg) + (6.25 × height_cm) − (5 × age_years) − 161
/// 
/// Requirement 5.2: TDEE calculation
/// TDEE = BMR × activity_factor (sedentary: 1.2, lightly_active: 1.375, moderately_active: 1.55)
/// 
/// Requirement 5.3: Target calories with safe deficit
/// Max 500 kcal below TDEE, minimum 80% of BMR
///
/// Property 5: BMR Calculation Accuracy
/// Property 6: Calorie Deficit Safety

void main() {
  late DietPlanProvider provider;
  final random = Random(42); // Fixed seed for reproducibility

  setUp(() {
    provider = DietPlanProvider();
  });

  group('Property 5: BMR Calculation Accuracy', () {
    /// Helper function to create a UserModel for testing
    UserModel createUser({
      required double weight,
      required double height,
      required int age,
      String activityLevel = 'sedentary',
      bool isBreastfeeding = false,
    }) {
      return UserModel(
        id: 'test-user-${DateTime.now().millisecondsSinceEpoch}',
        email: 'test@example.com',
        fullName: 'Test User',
        weight: weight,
        height: height,
        age: age,
        isBreastfeeding: isBreastfeeding,
        activityLevel: activityLevel,
        timezone: 'WIB',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    /// Helper function to calculate expected BMR
    double calculateExpectedBMR(double weight, double height, int age) {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    test('Property: BMR should always be positive for valid inputs', () {
      // Test with various valid input ranges
      final testCases = [
        {'weight': 45.0, 'height': 150.0, 'age': 20},
        {'weight': 50.0, 'height': 155.0, 'age': 25},
        {'weight': 55.0, 'height': 160.0, 'age': 30},
        {'weight': 60.0, 'height': 165.0, 'age': 35},
        {'weight': 65.0, 'height': 170.0, 'age': 40},
        {'weight': 70.0, 'height': 175.0, 'age': 45},
        {'weight': 75.0, 'height': 180.0, 'age': 50},
        {'weight': 80.0, 'height': 185.0, 'age': 55},
        {'weight': 85.0, 'height': 190.0, 'age': 60},
        {'weight': 90.0, 'height': 195.0, 'age': 65},
      ];

      for (final testCase in testCases) {
        final user = createUser(
          weight: testCase['weight'] as double,
          height: testCase['height'] as double,
          age: testCase['age'] as int,
        );

        provider.setUser(user);

        expect(
          provider.bmr,
          greaterThan(0),
          reason: 'BMR should be positive for weight=${testCase['weight']}, '
              'height=${testCase['height']}, age=${testCase['age']}',
        );
      }
    });

    test('Property: BMR should increase monotonically with weight', () {
      // Test that BMR increases as weight increases (holding height and age constant)
      const height = 165.0;
      const age = 30;
      final weights = [45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0];

      double? previousBMR;
      for (final weight in weights) {
        final user = createUser(weight: weight, height: height, age: age);
        provider.setUser(user);

        if (previousBMR != null) {
          expect(
            provider.bmr,
            greaterThan(previousBMR),
            reason: 'BMR should increase as weight increases from '
                '${weight - 5.0} to $weight',
          );
        }
        previousBMR = provider.bmr;
      }
    });

    test('Property: BMR should increase monotonically with height', () {
      // Test that BMR increases as height increases (holding weight and age constant)
      const weight = 60.0;
      const age = 30;
      final heights = [150.0, 155.0, 160.0, 165.0, 170.0, 175.0, 180.0];

      double? previousBMR;
      for (final height in heights) {
        final user = createUser(weight: weight, height: height, age: age);
        provider.setUser(user);

        if (previousBMR != null) {
          expect(
            provider.bmr,
            greaterThan(previousBMR),
            reason: 'BMR should increase as height increases from '
                '${height - 5.0} to $height',
          );
        }
        previousBMR = provider.bmr;
      }
    });

    test('Property: BMR should decrease monotonically with age', () {
      // Test that BMR decreases as age increases (holding weight and height constant)
      const weight = 60.0;
      const height = 165.0;
      final ages = [20, 25, 30, 35, 40, 45, 50, 55, 60];

      double? previousBMR;
      for (final age in ages) {
        final user = createUser(weight: weight, height: height, age: age);
        provider.setUser(user);

        if (previousBMR != null) {
          expect(
            provider.bmr,
            lessThan(previousBMR),
            reason: 'BMR should decrease as age increases from '
                '${age - 5} to $age',
          );
        }
        previousBMR = provider.bmr;
      }
    });

    test('Property: BMR calculation should match Mifflin-St Jeor formula exactly', () {
      // Test that the implementation matches the formula precisely
      final testCases = [
        {'weight': 45.0, 'height': 150.0, 'age': 20},
        {'weight': 52.5, 'height': 157.5, 'age': 27},
        {'weight': 60.0, 'height': 165.0, 'age': 30},
        {'weight': 67.3, 'height': 172.8, 'age': 35},
        {'weight': 75.0, 'height': 180.0, 'age': 42},
        {'weight': 82.4, 'height': 187.2, 'age': 48},
        {'weight': 90.0, 'height': 195.0, 'age': 55},
      ];

      for (final testCase in testCases) {
        final weight = testCase['weight'] as double;
        final height = testCase['height'] as double;
        final age = testCase['age'] as int;

        final user = createUser(weight: weight, height: height, age: age);
        provider.setUser(user);

        final expectedBMR = calculateExpectedBMR(weight, height, age);

        expect(
          provider.bmr,
          closeTo(expectedBMR, 0.001),
          reason: 'BMR should match formula for weight=$weight, '
              'height=$height, age=$age',
        );
      }
    });

    test('Property: BMR calculation with random valid inputs', () {
      // Generate random valid inputs and verify BMR is positive and matches formula
      for (int i = 0; i < 20; i++) {
        final weight = 40.0 + random.nextDouble() * 60.0; // 40-100 kg
        final height = 145.0 + random.nextDouble() * 55.0; // 145-200 cm
        final age = 18 + random.nextInt(52); // 18-70 years

        final user = createUser(
          weight: weight,
          height: height,
          age: age,
        );
        provider.setUser(user);

        final expectedBMR = calculateExpectedBMR(weight, height, age);

        expect(provider.bmr, greaterThan(0),
            reason: 'BMR should be positive for random input #$i');
        expect(provider.bmr, closeTo(expectedBMR, 0.001),
            reason: 'BMR should match formula for random input #$i');
      }
    });

    test('Property: BMR calculation with edge case values', () {
      // Test with edge cases: minimum and maximum realistic values
      final edgeCases = [
        {'weight': 40.0, 'height': 145.0, 'age': 18, 'description': 'minimum values'},
        {'weight': 100.0, 'height': 200.0, 'age': 70, 'description': 'maximum values'},
        {'weight': 45.0, 'height': 150.0, 'age': 18, 'description': 'young minimum'},
        {'weight': 95.0, 'height': 195.0, 'age': 65, 'description': 'older maximum'},
      ];

      for (final testCase in edgeCases) {
        final weight = testCase['weight'] as double;
        final height = testCase['height'] as double;
        final age = testCase['age'] as int;
        final description = testCase['description'] as String;

        final user = createUser(weight: weight, height: height, age: age);
        provider.setUser(user);

        final expectedBMR = calculateExpectedBMR(weight, height, age);

        expect(provider.bmr, greaterThan(0),
            reason: 'BMR should be positive for $description');
        expect(provider.bmr, closeTo(expectedBMR, 0.001),
            reason: 'BMR should match formula for $description');
      }
    });

    test('Property: BMR calculation with realistic postpartum mother values', () {
      // Test with realistic values for postpartum mothers
      final realisticCases = [
        {'weight': 55.0, 'height': 160.0, 'age': 25, 'description': 'young mother'},
        {'weight': 60.0, 'height': 165.0, 'age': 30, 'description': 'average mother'},
        {'weight': 65.0, 'height': 170.0, 'age': 35, 'description': 'older mother'},
        {'weight': 70.0, 'height': 168.0, 'age': 28, 'description': 'heavier mother'},
        {'weight': 50.0, 'height': 158.0, 'age': 32, 'description': 'lighter mother'},
      ];

      for (final testCase in realisticCases) {
        final weight = testCase['weight'] as double;
        final height = testCase['height'] as double;
        final age = testCase['age'] as int;
        final description = testCase['description'] as String;

        final user = createUser(weight: weight, height: height, age: age);
        provider.setUser(user);

        final expectedBMR = calculateExpectedBMR(weight, height, age);

        expect(provider.bmr, greaterThan(0),
            reason: 'BMR should be positive for $description');
        expect(provider.bmr, closeTo(expectedBMR, 0.001),
            reason: 'BMR should match formula for $description');
        
        // BMR for postpartum mothers should typically be in range 1200-1800
        expect(provider.bmr, greaterThan(1000),
            reason: 'BMR should be realistic for $description');
        expect(provider.bmr, lessThan(2000),
            reason: 'BMR should be realistic for $description');
      }
    });
  });

  group('Property 6: Calorie Deficit Safety', () {
    /// Helper function to create a UserModel for testing
    UserModel createUser({
      required double weight,
      required double height,
      required int age,
      required String activityLevel,
      required bool isBreastfeeding,
    }) {
      return UserModel(
        id: 'test-user-${DateTime.now().millisecondsSinceEpoch}',
        email: 'test@example.com',
        fullName: 'Test User',
        weight: weight,
        height: height,
        age: age,
        isBreastfeeding: isBreastfeeding,
        activityLevel: activityLevel,
        timezone: 'WIB',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    test('Property: Target calories should never be below 80% of BMR', () {
      // Test with various combinations that might result in aggressive deficits
      final testCases = [
        {'weight': 45.0, 'height': 150.0, 'age': 20, 'activity': 'sedentary', 'breastfeeding': false},
        {'weight': 50.0, 'height': 155.0, 'age': 25, 'activity': 'sedentary', 'breastfeeding': false},
        {'weight': 55.0, 'height': 160.0, 'age': 30, 'activity': 'lightly_active', 'breastfeeding': false},
        {'weight': 60.0, 'height': 165.0, 'age': 35, 'activity': 'lightly_active', 'breastfeeding': true},
        {'weight': 65.0, 'height': 170.0, 'age': 40, 'activity': 'moderately_active', 'breastfeeding': false},
        {'weight': 70.0, 'height': 175.0, 'age': 45, 'activity': 'moderately_active', 'breastfeeding': true},
      ];

      for (final testCase in testCases) {
        final user = createUser(
          weight: testCase['weight'] as double,
          height: testCase['height'] as double,
          age: testCase['age'] as int,
          activityLevel: testCase['activity'] as String,
          isBreastfeeding: testCase['breastfeeding'] as bool,
        );

        provider.setUser(user);

        final minimumSafe = provider.bmr! * 0.8;

        expect(
          provider.targetCalories,
          greaterThanOrEqualTo(minimumSafe),
          reason: 'Target calories should not be below 80% of BMR for '
              'weight=${testCase['weight']}, height=${testCase['height']}, '
              'age=${testCase['age']}, activity=${testCase['activity']}, '
              'breastfeeding=${testCase['breastfeeding']}',
        );
      }
    });

    test('Property: Target calories should not exceed TDEE', () {
      // Target calories should be TDEE - 500 or TDEE + breastfeeding adjustment
      final testCases = [
        {'weight': 60.0, 'height': 165.0, 'age': 30, 'activity': 'sedentary', 'breastfeeding': false},
        {'weight': 60.0, 'height': 165.0, 'age': 30, 'activity': 'lightly_active', 'breastfeeding': false},
        {'weight': 60.0, 'height': 165.0, 'age': 30, 'activity': 'moderately_active', 'breastfeeding': false},
        {'weight': 60.0, 'height': 165.0, 'age': 30, 'activity': 'sedentary', 'breastfeeding': true},
        {'weight': 60.0, 'height': 165.0, 'age': 30, 'activity': 'lightly_active', 'breastfeeding': true},
        {'weight': 60.0, 'height': 165.0, 'age': 30, 'activity': 'moderately_active', 'breastfeeding': true},
      ];

      for (final testCase in testCases) {
        final user = createUser(
          weight: testCase['weight'] as double,
          height: testCase['height'] as double,
          age: testCase['age'] as int,
          activityLevel: testCase['activity'] as String,
          isBreastfeeding: testCase['breastfeeding'] as bool,
        );

        provider.setUser(user);

        final isBreastfeeding = testCase['breastfeeding'] as bool;
        final expectedMaxTarget = isBreastfeeding 
            ? provider.tdee! - 500 + 400  // TDEE - deficit + breastfeeding
            : provider.tdee! - 500;        // TDEE - deficit

        expect(
          provider.targetCalories,
          lessThanOrEqualTo(expectedMaxTarget + 1), // +1 for floating point tolerance
          reason: 'Target calories should not exceed expected maximum for '
              'activity=${testCase['activity']}, breastfeeding=$isBreastfeeding',
        );
      }
    });

    test('Property: Deficit should be at most 500 kcal when safe', () {
      // When BMR is high enough, deficit should be exactly 500 kcal (or 100 with breastfeeding)
      final testCases = [
        {'weight': 70.0, 'height': 175.0, 'age': 30, 'activity': 'moderately_active', 'breastfeeding': false},
        {'weight': 75.0, 'height': 180.0, 'age': 35, 'activity': 'moderately_active', 'breastfeeding': false},
        {'weight': 80.0, 'height': 185.0, 'age': 40, 'activity': 'lightly_active', 'breastfeeding': false},
      ];

      for (final testCase in testCases) {
        final user = createUser(
          weight: testCase['weight'] as double,
          height: testCase['height'] as double,
          age: testCase['age'] as int,
          activityLevel: testCase['activity'] as String,
          isBreastfeeding: testCase['breastfeeding'] as bool,
        );

        provider.setUser(user);

        final minimumSafe = provider.bmr! * 0.8;
        final expectedTarget = provider.tdee! - 500;

        // If expected target is above minimum safe, deficit should be 500
        if (expectedTarget >= minimumSafe) {
          expect(
            provider.targetCalories,
            closeTo(expectedTarget, 0.1),
            reason: 'Deficit should be 500 kcal when safe for '
                'weight=${testCase['weight']}, height=${testCase['height']}, '
                'age=${testCase['age']}, activity=${testCase['activity']}',
          );
        }
      }
    });

    test('Property: Breastfeeding should add 400 kcal to target', () {
      // Compare same user with and without breastfeeding
      final testCases = [
        {'weight': 60.0, 'height': 165.0, 'age': 30, 'activity': 'sedentary'},
        {'weight': 65.0, 'height': 170.0, 'age': 35, 'activity': 'lightly_active'},
        {'weight': 70.0, 'height': 175.0, 'age': 40, 'activity': 'moderately_active'},
      ];

      for (final testCase in testCases) {
        // Test without breastfeeding
        final userNoBF = createUser(
          weight: testCase['weight'] as double,
          height: testCase['height'] as double,
          age: testCase['age'] as int,
          activityLevel: testCase['activity'] as String,
          isBreastfeeding: false,
        );
        provider.setUser(userNoBF);
        final targetNoBF = provider.targetCalories!;

        // Test with breastfeeding
        final userWithBF = createUser(
          weight: testCase['weight'] as double,
          height: testCase['height'] as double,
          age: testCase['age'] as int,
          activityLevel: testCase['activity'] as String,
          isBreastfeeding: true,
        );
        provider.setUser(userWithBF);
        final targetWithBF = provider.targetCalories!;

        // Difference should be 400 kcal (unless constrained by minimum safe)
        final minimumSafe = provider.bmr! * 0.8;
        final expectedDifference = (targetNoBF >= minimumSafe && targetWithBF >= minimumSafe) 
            ? 400.0 
            : targetWithBF - targetNoBF;

        expect(
          targetWithBF - targetNoBF,
          closeTo(expectedDifference, 0.1),
          reason: 'Breastfeeding should add 400 kcal for '
              'weight=${testCase['weight']}, height=${testCase['height']}, '
              'age=${testCase['age']}, activity=${testCase['activity']}',
        );
      }
    });

    test('Property: Safety constraint should activate for low BMR scenarios', () {
      // Test scenarios where 80% BMR constraint should be active
      final lowBMRCases = [
        {'weight': 45.0, 'height': 150.0, 'age': 20, 'activity': 'sedentary', 'breastfeeding': false},
        {'weight': 48.0, 'height': 152.0, 'age': 22, 'activity': 'sedentary', 'breastfeeding': false},
        {'weight': 50.0, 'height': 155.0, 'age': 25, 'activity': 'sedentary', 'breastfeeding': false},
      ];

      for (final testCase in lowBMRCases) {
        final user = createUser(
          weight: testCase['weight'] as double,
          height: testCase['height'] as double,
          age: testCase['age'] as int,
          activityLevel: testCase['activity'] as String,
          isBreastfeeding: testCase['breastfeeding'] as bool,
        );

        provider.setUser(user);

        final minimumSafe = provider.bmr! * 0.8;
        final naiveTarget = provider.tdee! - 500;

        // If naive target would be below minimum safe, target should equal minimum safe
        if (naiveTarget < minimumSafe) {
          expect(
            provider.targetCalories,
            closeTo(minimumSafe, 0.1),
            reason: 'Target should be clamped to 80% BMR for low BMR scenario: '
                'weight=${testCase['weight']}, height=${testCase['height']}, '
                'age=${testCase['age']}',
          );
        }
      }
    });

    test('Property: Target calories with random valid inputs', () {
      // Generate random valid inputs and verify safety constraints
      for (int i = 0; i < 20; i++) {
        final weight = 45.0 + random.nextDouble() * 45.0; // 45-90 kg
        final height = 150.0 + random.nextDouble() * 40.0; // 150-190 cm
        final age = 20 + random.nextInt(41); // 20-60 years
        final activities = ['sedentary', 'lightly_active', 'moderately_active'];
        final activityLevel = activities[random.nextInt(activities.length)];
        final isBreastfeeding = random.nextBool();

        final user = createUser(
          weight: weight,
          height: height,
          age: age,
          activityLevel: activityLevel,
          isBreastfeeding: isBreastfeeding,
        );

        provider.setUser(user);

        final minimumSafe = provider.bmr! * 0.8;

        expect(
          provider.targetCalories,
          greaterThanOrEqualTo(minimumSafe),
          reason: 'Target calories should not be below 80% of BMR for random input #$i',
        );

        expect(
          provider.targetCalories,
          greaterThan(0),
          reason: 'Target calories should be positive for random input #$i',
        );
      }
    });

    test('Property: Target calories should be realistic for postpartum mothers', () {
      // Test with realistic postpartum mother scenarios
      final realisticCases = [
        {
          'weight': 55.0,
          'height': 160.0,
          'age': 25,
          'activity': 'lightly_active',
          'breastfeeding': true,
          'description': 'young breastfeeding mother'
        },
        {
          'weight': 60.0,
          'height': 165.0,
          'age': 30,
          'activity': 'moderately_active',
          'breastfeeding': true,
          'description': 'average breastfeeding mother'
        },
        {
          'weight': 65.0,
          'height': 170.0,
          'age': 35,
          'activity': 'lightly_active',
          'breastfeeding': false,
          'description': 'non-breastfeeding mother'
        },
        {
          'weight': 70.0,
          'height': 168.0,
          'age': 28,
          'activity': 'sedentary',
          'breastfeeding': true,
          'description': 'sedentary breastfeeding mother'
        },
      ];

      for (final testCase in realisticCases) {
        final user = createUser(
          weight: testCase['weight'] as double,
          height: testCase['height'] as double,
          age: testCase['age'] as int,
          activityLevel: testCase['activity'] as String,
          isBreastfeeding: testCase['breastfeeding'] as bool,
        );

        provider.setUser(user);

        final description = testCase['description'] as String;
        final minimumSafe = provider.bmr! * 0.8;

        // Verify safety constraint
        expect(
          provider.targetCalories,
          greaterThanOrEqualTo(minimumSafe),
          reason: 'Target should be safe for $description',
        );

        // Target calories for postpartum mothers should typically be 1200-2500
        expect(
          provider.targetCalories,
          greaterThan(1000),
          reason: 'Target should be realistic (not too low) for $description',
        );
        expect(
          provider.targetCalories,
          lessThan(3000),
          reason: 'Target should be realistic (not too high) for $description',
        );
      }
    });
  });
}
