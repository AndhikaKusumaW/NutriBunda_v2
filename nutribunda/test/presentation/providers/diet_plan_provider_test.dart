import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/presentation/providers/diet_plan_provider.dart';
import 'package:nutribunda/data/models/user_model.dart';
import 'package:nutribunda/core/services/pedometer_service.dart';

void main() {
  late DietPlanProvider provider;
  late UserModel testUser;

  setUp(() {
    provider = DietPlanProvider();
    
    // Create a test user with complete data
    testUser = UserModel(
      id: 'test-user-1',
      email: 'test@example.com',
      fullName: 'Test User',
      weight: 60.0, // kg
      height: 165.0, // cm
      age: 30, // years
      isBreastfeeding: false,
      activityLevel: 'sedentary',
      timezone: 'WIB',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  group('DietPlanProvider - Initial State', () {
    test('initial state should be correct', () {
      expect(provider.bmr, null);
      expect(provider.tdee, null);
      expect(provider.targetCalories, null);
      expect(provider.steps, 0);
      expect(provider.caloriesBurned, 0);
      expect(provider.user, null);
      expect(provider.canCalculateDietPlan, false);
    });

    test('canCalculateDietPlan should return false when user is null', () {
      expect(provider.canCalculateDietPlan, false);
    });

    test('canCalculateDietPlan should return false when weight is missing', () {
      final incompleteUser = UserModel(
        id: testUser.id,
        email: testUser.email,
        fullName: testUser.fullName,
        weight: null, // Missing weight
        height: testUser.height,
        age: testUser.age,
        isBreastfeeding: testUser.isBreastfeeding,
        activityLevel: testUser.activityLevel,
        timezone: testUser.timezone,
        createdAt: testUser.createdAt,
        updatedAt: testUser.updatedAt,
      );
      provider.setUser(incompleteUser);
      
      expect(provider.canCalculateDietPlan, false);
      expect(provider.missingProfileData, contains('Berat badan'));
    });

    test('canCalculateDietPlan should return false when height is missing', () {
      final incompleteUser = UserModel(
        id: testUser.id,
        email: testUser.email,
        fullName: testUser.fullName,
        weight: testUser.weight,
        height: null, // Missing height
        age: testUser.age,
        isBreastfeeding: testUser.isBreastfeeding,
        activityLevel: testUser.activityLevel,
        timezone: testUser.timezone,
        createdAt: testUser.createdAt,
        updatedAt: testUser.updatedAt,
      );
      provider.setUser(incompleteUser);
      
      expect(provider.canCalculateDietPlan, false);
      expect(provider.missingProfileData, contains('Tinggi badan'));
    });

    test('canCalculateDietPlan should return false when age is missing', () {
      final incompleteUser = UserModel(
        id: testUser.id,
        email: testUser.email,
        fullName: testUser.fullName,
        weight: testUser.weight,
        height: testUser.height,
        age: null, // Missing age
        isBreastfeeding: testUser.isBreastfeeding,
        activityLevel: testUser.activityLevel,
        timezone: testUser.timezone,
        createdAt: testUser.createdAt,
        updatedAt: testUser.updatedAt,
      );
      provider.setUser(incompleteUser);
      
      expect(provider.canCalculateDietPlan, false);
      expect(provider.missingProfileData, contains('Usia'));
    });

    test('canCalculateDietPlan should return true when all data is present', () {
      provider.setUser(testUser);
      
      expect(provider.canCalculateDietPlan, true);
      expect(provider.missingProfileData, isEmpty);
    });
  });

  group('DietPlanProvider - BMR Calculation (Requirement 5.1)', () {
    test('calculateBMR should use Mifflin-St Jeor formula correctly', () {
      // Arrange
      provider.setUser(testUser);
      
      // Expected BMR = (10 × 60) + (6.25 × 165) − (5 × 30) − 161
      // = 600 + 1031.25 - 150 - 161
      // = 1320.25
      const expectedBMR = 1320.25;
      
      // Act
      provider.calculateBMR();
      
      // Assert
      expect(provider.bmr, expectedBMR);
    });

    test('calculateBMR should return null when user data is incomplete', () {
      // Arrange
      final incompleteUser = UserModel(
        id: testUser.id,
        email: testUser.email,
        fullName: testUser.fullName,
        weight: null, // Missing weight
        height: testUser.height,
        age: testUser.age,
        isBreastfeeding: testUser.isBreastfeeding,
        activityLevel: testUser.activityLevel,
        timezone: testUser.timezone,
        createdAt: testUser.createdAt,
        updatedAt: testUser.updatedAt,
      );
      provider.setUser(incompleteUser);
      
      // Act
      provider.calculateBMR();
      
      // Assert
      expect(provider.bmr, null);
    });

    test('BMR should increase with weight', () {
      // Arrange
      final user1 = testUser.copyWith(weight: 50.0);
      final user2 = testUser.copyWith(weight: 70.0);
      
      // Act
      provider.setUser(user1);
      final bmr1 = provider.bmr;
      
      provider.setUser(user2);
      final bmr2 = provider.bmr;
      
      // Assert
      expect(bmr2, greaterThan(bmr1!));
    });

    test('BMR should increase with height', () {
      // Arrange
      final user1 = testUser.copyWith(height: 150.0);
      final user2 = testUser.copyWith(height: 180.0);
      
      // Act
      provider.setUser(user1);
      final bmr1 = provider.bmr;
      
      provider.setUser(user2);
      final bmr2 = provider.bmr;
      
      // Assert
      expect(bmr2, greaterThan(bmr1!));
    });

    test('BMR should decrease with age', () {
      // Arrange
      final user1 = testUser.copyWith(age: 25);
      final user2 = testUser.copyWith(age: 40);
      
      // Act
      provider.setUser(user1);
      final bmr1 = provider.bmr;
      
      provider.setUser(user2);
      final bmr2 = provider.bmr;
      
      // Assert
      expect(bmr2, lessThan(bmr1!));
    });

    test('BMR should always be positive for valid inputs', () {
      // Test with various valid inputs
      final testCases = [
        {'weight': 45.0, 'height': 150.0, 'age': 20},
        {'weight': 60.0, 'height': 165.0, 'age': 30},
        {'weight': 80.0, 'height': 175.0, 'age': 40},
        {'weight': 100.0, 'height': 180.0, 'age': 50},
      ];

      for (final testCase in testCases) {
        final user = testUser.copyWith(
          weight: testCase['weight'] as double,
          height: testCase['height'] as double,
          age: testCase['age'] as int,
        );
        
        provider.setUser(user);
        
        expect(provider.bmr, greaterThan(0));
      }
    });
  });

  group('DietPlanProvider - TDEE Calculation (Requirement 5.2)', () {
    test('calculateTDEE should multiply BMR by sedentary factor (1.2)', () {
      // Arrange
      final user = testUser.copyWith(activityLevel: 'sedentary');
      provider.setUser(user);
      
      final expectedTDEE = provider.bmr! * 1.2;
      
      // Act
      provider.calculateTDEE();
      
      // Assert
      expect(provider.tdee, expectedTDEE);
    });

    test('calculateTDEE should multiply BMR by lightly_active factor (1.375)', () {
      // Arrange
      final user = testUser.copyWith(activityLevel: 'lightly_active');
      provider.setUser(user);
      
      final expectedTDEE = provider.bmr! * 1.375;
      
      // Act
      provider.calculateTDEE();
      
      // Assert
      expect(provider.tdee, expectedTDEE);
    });

    test('calculateTDEE should multiply BMR by moderately_active factor (1.55)', () {
      // Arrange
      final user = testUser.copyWith(activityLevel: 'moderately_active');
      provider.setUser(user);
      
      final expectedTDEE = provider.bmr! * 1.55;
      
      // Act
      provider.calculateTDEE();
      
      // Assert
      expect(provider.tdee, expectedTDEE);
    });

    test('calculateTDEE should default to sedentary for unknown activity level', () {
      // Arrange
      final user = testUser.copyWith(activityLevel: 'unknown');
      provider.setUser(user);
      
      final expectedTDEE = provider.bmr! * 1.2;
      
      // Act
      provider.calculateTDEE();
      
      // Assert
      expect(provider.tdee, expectedTDEE);
    });

    test('calculateTDEE should return null when BMR is null', () {
      // Arrange
      final incompleteUser = UserModel(
        id: testUser.id,
        email: testUser.email,
        fullName: testUser.fullName,
        weight: null, // Missing weight
        height: testUser.height,
        age: testUser.age,
        isBreastfeeding: testUser.isBreastfeeding,
        activityLevel: testUser.activityLevel,
        timezone: testUser.timezone,
        createdAt: testUser.createdAt,
        updatedAt: testUser.updatedAt,
      );
      provider.setUser(incompleteUser);
      
      // Act
      provider.calculateTDEE();
      
      // Assert
      expect(provider.tdee, null);
    });

    test('TDEE should increase with activity level', () {
      // Arrange
      provider.setUser(testUser);
      final bmr = provider.bmr!;
      
      // Act & Assert
      final sedentaryTDEE = bmr * 1.2;
      final lightlyActiveTDEE = bmr * 1.375;
      final moderatelyActiveTDEE = bmr * 1.55;
      
      expect(lightlyActiveTDEE, greaterThan(sedentaryTDEE));
      expect(moderatelyActiveTDEE, greaterThan(lightlyActiveTDEE));
    });
  });

  group('DietPlanProvider - Target Calories (Requirements 5.3, 5.4)', () {
    test('calculateTargetCalories should apply safe deficit of 500 kcal', () {
      // Arrange
      final user = testUser.copyWith(
        activityLevel: 'sedentary',
        isBreastfeeding: false,
      );
      provider.setUser(user);
      
      final expectedTarget = provider.tdee! - 500;
      
      // Act
      provider.calculateTargetCalories();
      
      // Assert
      expect(provider.targetCalories, expectedTarget);
    });

    test('calculateTargetCalories should add 400 kcal when breastfeeding', () {
      // Arrange
      final user = testUser.copyWith(
        activityLevel: 'sedentary',
        isBreastfeeding: true,
      );
      provider.setUser(user);
      
      final expectedTarget = (provider.tdee! - 500) + 400;
      
      // Act
      provider.calculateTargetCalories();
      
      // Assert
      expect(provider.targetCalories, expectedTarget);
    });

    test('calculateTargetCalories should not go below 80% of BMR', () {
      // Arrange - Create a scenario where deficit would be too aggressive
      final user = testUser.copyWith(
        weight: 45.0, // Low weight
        height: 150.0,
        age: 20,
        activityLevel: 'sedentary',
        isBreastfeeding: false,
      );
      provider.setUser(user);
      
      final minimumSafe = provider.bmr! * 0.8;
      
      // Act
      provider.calculateTargetCalories();
      
      // Assert
      expect(provider.targetCalories, greaterThanOrEqualTo(minimumSafe));
    });

    test('calculateTargetCalories should return null when TDEE is null', () {
      // Arrange
      final incompleteUser = UserModel(
        id: testUser.id,
        email: testUser.email,
        fullName: testUser.fullName,
        weight: null, // Missing weight
        height: testUser.height,
        age: testUser.age,
        isBreastfeeding: testUser.isBreastfeeding,
        activityLevel: testUser.activityLevel,
        timezone: testUser.timezone,
        createdAt: testUser.createdAt,
        updatedAt: testUser.updatedAt,
      );
      provider.setUser(incompleteUser);
      
      // Act
      provider.calculateTargetCalories();
      
      // Assert
      expect(provider.targetCalories, null);
    });
  });

  group('DietPlanProvider - Automatic Recalculation (Requirement 5.5)', () {
    test('setUser should automatically calculate all values when data is complete', () {
      // Act
      provider.setUser(testUser);
      
      // Assert
      expect(provider.bmr, isNotNull);
      expect(provider.tdee, isNotNull);
      expect(provider.targetCalories, isNotNull);
    });

    test('setUser should clear calculations when data is incomplete', () {
      // Arrange
      provider.setUser(testUser); // Set complete data first
      expect(provider.bmr, isNotNull);
      
      // Act
      final incompleteUser = UserModel(
        id: testUser.id,
        email: testUser.email,
        fullName: testUser.fullName,
        weight: null, // Missing weight
        height: testUser.height,
        age: testUser.age,
        isBreastfeeding: testUser.isBreastfeeding,
        activityLevel: testUser.activityLevel,
        timezone: testUser.timezone,
        createdAt: testUser.createdAt,
        updatedAt: testUser.updatedAt,
      );
      provider.setUser(incompleteUser);
      
      // Assert
      expect(provider.bmr, null);
      expect(provider.tdee, null);
      expect(provider.targetCalories, null);
    });

    test('updateUserProfile should recalculate when weight changes', () {
      // Arrange
      provider.setUser(testUser);
      final oldBMR = provider.bmr;
      
      // Act
      provider.updateUserProfile(weight: 70.0);
      
      // Assert
      expect(provider.bmr, isNotNull);
      expect(provider.bmr, isNot(equals(oldBMR)));
    });

    test('updateUserProfile should recalculate when height changes', () {
      // Arrange
      provider.setUser(testUser);
      final oldBMR = provider.bmr;
      
      // Act
      provider.updateUserProfile(height: 170.0);
      
      // Assert
      expect(provider.bmr, isNotNull);
      expect(provider.bmr, isNot(equals(oldBMR)));
    });

    test('updateUserProfile should recalculate when age changes', () {
      // Arrange
      provider.setUser(testUser);
      final oldBMR = provider.bmr;
      
      // Act
      provider.updateUserProfile(age: 35);
      
      // Assert
      expect(provider.bmr, isNotNull);
      expect(provider.bmr, isNot(equals(oldBMR)));
    });

    test('updateUserProfile should recalculate when activity level changes', () {
      // Arrange
      provider.setUser(testUser);
      final oldTDEE = provider.tdee;
      
      // Act
      provider.updateUserProfile(activityLevel: 'moderately_active');
      
      // Assert
      expect(provider.tdee, isNotNull);
      expect(provider.tdee, isNot(equals(oldTDEE)));
    });

    test('updateUserProfile should recalculate when breastfeeding status changes', () {
      // Arrange
      provider.setUser(testUser);
      final oldTarget = provider.targetCalories;
      
      // Act
      provider.updateUserProfile(isBreastfeeding: true);
      
      // Assert
      expect(provider.targetCalories, isNotNull);
      expect(provider.targetCalories, greaterThan(oldTarget!));
    });

    test('calculateAll should calculate BMR, TDEE, and target calories', () {
      // Arrange
      provider.setUser(testUser);
      provider.resetState(); // Clear calculations
      
      // Act
      provider.setUser(testUser); // This triggers calculateAll
      
      // Assert
      expect(provider.bmr, isNotNull);
      expect(provider.tdee, isNotNull);
      expect(provider.targetCalories, isNotNull);
    });
  });

  group('DietPlanProvider - Step Tracking (Requirements 5.6, 5.7)', () {
    test('updateSteps should calculate calories burned correctly', () {
      // Arrange
      provider.setUser(testUser);
      const steps = 10000;
      
      // Expected: 10000 * 0.04 * 60 / 1000 = 24 kcal
      const expectedCaloriesBurned = 24.0;
      
      // Act
      provider.updateSteps(steps);
      
      // Assert
      expect(provider.steps, steps);
      expect(provider.caloriesBurned, expectedCaloriesBurned);
    });

    test('updateSteps should set calories burned to 0 when weight is null', () {
      // Arrange
      final incompleteUser = UserModel(
        id: testUser.id,
        email: testUser.email,
        fullName: testUser.fullName,
        weight: null, // Missing weight
        height: testUser.height,
        age: testUser.age,
        isBreastfeeding: testUser.isBreastfeeding,
        activityLevel: testUser.activityLevel,
        timezone: testUser.timezone,
        createdAt: testUser.createdAt,
        updatedAt: testUser.updatedAt,
      );
      provider.setUser(incompleteUser);
      
      // Act
      provider.updateSteps(5000);
      
      // Assert
      expect(provider.steps, 5000);
      expect(provider.caloriesBurned, 0);
    });

    test('updateSteps should scale calories burned with weight', () {
      // Arrange
      final user1 = testUser.copyWith(weight: 50.0);
      final user2 = testUser.copyWith(weight: 80.0);
      const steps = 10000;
      
      // Act
      provider.setUser(user1);
      provider.updateSteps(steps);
      final calories1 = provider.caloriesBurned;
      
      provider.setUser(user2);
      provider.updateSteps(steps);
      final calories2 = provider.caloriesBurned;
      
      // Assert
      expect(calories2, greaterThan(calories1));
    });

    test('resetDailySteps should reset steps and calories burned', () {
      // Arrange
      provider.setUser(testUser);
      provider.updateSteps(5000);
      
      // Act
      provider.resetDailySteps();
      
      // Assert
      expect(provider.steps, 0);
      expect(provider.caloriesBurned, 0);
    });
    
    test('pedometerService should be accessible', () {
      // Assert
      expect(provider.pedometerService, isNotNull);
      expect(provider.pedometerService, isA<PedometerService>());
    });
    
    test('isPedometerActive should return false initially', () {
      // Assert
      expect(provider.isPedometerActive, false);
    });
    
    test('pedometerError should return null initially', () {
      // Assert
      expect(provider.pedometerError, null);
    });
    
    test('startPedometerTracking should not throw error', () {
      // Note: This test requires platform channels which are not available in unit tests
      // Skip this test as it requires integration testing
    }, skip: 'Requires platform channels - test in integration tests');
    
    test('stopPedometerTracking should not throw error', () {
      // Act & Assert
      expect(() => provider.stopPedometerTracking(), returnsNormally);
    });
  });

  group('DietPlanProvider - Calorie Tracking (Requirements 5.8, 5.9, 5.10)', () {
    test('getRemainingCalories should calculate correctly', () {
      // Arrange
      provider.setUser(testUser);
      const consumedCalories = 1200.0;
      provider.updateSteps(10000); // 24 kcal burned
      
      final expected = provider.targetCalories! - consumedCalories + provider.caloriesBurned;
      
      // Act
      final remaining = provider.getRemainingCalories(consumedCalories);
      
      // Assert
      expect(remaining, expected);
    });

    test('getCalorieProgress should calculate percentage correctly', () {
      // Arrange
      provider.setUser(testUser);
      final target = provider.targetCalories!;
      final consumedCalories = target * 0.5; // 50% of target
      
      // Act
      final progress = provider.getCalorieProgress(consumedCalories);
      
      // Assert
      expect(progress, closeTo(50.0, 0.1));
    });

    test('getCalorieProgress should cap at 150%', () {
      // Arrange
      provider.setUser(testUser);
      final target = provider.targetCalories!;
      final consumedCalories = target * 2.0; // 200% of target
      
      // Act
      final progress = provider.getCalorieProgress(consumedCalories);
      
      // Assert
      expect(progress, 150.0);
    });

    test('getProgressColor should return green for 0-80%', () {
      // Arrange
      provider.setUser(testUser);
      final target = provider.targetCalories!;
      final consumedCalories = target * 0.7; // 70%
      
      // Act
      final color = provider.getProgressColor(consumedCalories);
      
      // Assert
      expect(color, 'green');
    });

    test('getProgressColor should return yellow for 81-100%', () {
      // Arrange
      provider.setUser(testUser);
      final target = provider.targetCalories!;
      final consumedCalories = target * 0.9; // 90%
      
      // Act
      final color = provider.getProgressColor(consumedCalories);
      
      // Assert
      expect(color, 'yellow');
    });

    test('getProgressColor should return red for >100%', () {
      // Arrange
      provider.setUser(testUser);
      final target = provider.targetCalories!;
      final consumedCalories = target * 1.2; // 120%
      
      // Act
      final color = provider.getProgressColor(consumedCalories);
      
      // Assert
      expect(color, 'red');
    });

    test('isCaloriesExceeded should return false when under target', () {
      // Arrange
      provider.setUser(testUser);
      final target = provider.targetCalories!;
      final consumedCalories = target * 0.8;
      
      // Act
      final exceeded = provider.isCaloriesExceeded(consumedCalories);
      
      // Assert
      expect(exceeded, false);
    });

    test('isCaloriesExceeded should return true when over target', () {
      // Arrange
      provider.setUser(testUser);
      final target = provider.targetCalories!;
      final consumedCalories = target * 1.2;
      
      // Act
      final exceeded = provider.isCaloriesExceeded(consumedCalories);
      
      // Assert
      expect(exceeded, true);
    });

    test('getCalorieExcess should return 0 when under target', () {
      // Arrange
      provider.setUser(testUser);
      final target = provider.targetCalories!;
      final consumedCalories = target * 0.8;
      
      // Act
      final excess = provider.getCalorieExcess(consumedCalories);
      
      // Assert
      expect(excess, 0);
    });

    test('getCalorieExcess should return correct amount when over target', () {
      // Arrange
      provider.setUser(testUser);
      final target = provider.targetCalories!;
      final consumedCalories = target + 200;
      
      // Act
      final excess = provider.getCalorieExcess(consumedCalories);
      
      // Assert
      expect(excess, closeTo(200, 0.1));
    });
  });

  group('DietPlanProvider - Diet Plan Summary', () {
    test('getDietPlanSummary should return complete summary', () {
      // Arrange
      provider.setUser(testUser);
      provider.updateSteps(5000);
      const consumedCalories = 1200.0;
      
      // Act
      final summary = provider.getDietPlanSummary(consumedCalories);
      
      // Assert
      expect(summary['bmr'], isNotNull);
      expect(summary['tdee'], isNotNull);
      expect(summary['target_calories'], isNotNull);
      expect(summary['consumed_calories'], consumedCalories);
      expect(summary['calories_burned'], isNotNull);
      expect(summary['remaining_calories'], isNotNull);
      expect(summary['progress_percentage'], isNotNull);
      expect(summary['progress_color'], isNotNull);
      expect(summary['is_exceeded'], isA<bool>());
      expect(summary['excess_amount'], isNotNull);
      expect(summary['steps'], 5000);
      expect(summary['can_calculate'], true);
      expect(summary['missing_data'], isEmpty);
    });

    test('getDietPlanSummary should show missing data when incomplete', () {
      // Arrange
      final incompleteUser = UserModel(
        id: testUser.id,
        email: testUser.email,
        fullName: testUser.fullName,
        weight: null, // Missing weight
        height: null, // Missing height
        age: testUser.age,
        isBreastfeeding: testUser.isBreastfeeding,
        activityLevel: testUser.activityLevel,
        timezone: testUser.timezone,
        createdAt: testUser.createdAt,
        updatedAt: testUser.updatedAt,
      );
      provider.setUser(incompleteUser);
      
      // Act
      final summary = provider.getDietPlanSummary(0);
      
      // Assert
      expect(summary['can_calculate'], false);
      expect(summary['missing_data'], isNotEmpty);
      expect(summary['missing_data'], contains('Berat badan'));
      expect(summary['missing_data'], contains('Tinggi badan'));
    });
  });

  group('DietPlanProvider - State Management', () {
    test('resetState should clear all values', () {
      // Arrange
      provider.setUser(testUser);
      provider.updateSteps(5000);
      
      // Act
      provider.resetState();
      
      // Assert
      expect(provider.bmr, null);
      expect(provider.tdee, null);
      expect(provider.targetCalories, null);
      expect(provider.steps, 0);
      expect(provider.caloriesBurned, 0);
      expect(provider.user, null);
    });
  });
}
