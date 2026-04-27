import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/core/services/nutrition_tracker_service.dart';
import 'package:nutribunda/data/models/nutrition_summary.dart';

/// Unit tests untuk NutritionTrackerService
/// Requirements: 4.3, 4.6, 13.2 - Nutrition calculation dan visualization
void main() {
  group('NutritionTrackerService', () {
    group('getTargets', () {
      test('should return baby targets for baby profile', () {
        final targets = NutritionTrackerService.getTargets('baby');

        expect(targets['calories'], 1000.0);
        expect(targets['protein'], 15.0);
        expect(targets['carbs'], 130.0);
        expect(targets['fat'], 35.0);
      });

      test('should return mother targets for mother profile', () {
        final targets = NutritionTrackerService.getTargets('mother');

        expect(targets['calories'], 2300.0);
        expect(targets['protein'], 65.0);
        expect(targets['carbs'], 300.0);
        expect(targets['fat'], 75.0);
      });

      test('should return baby targets for unknown profile', () {
        final targets = NutritionTrackerService.getTargets('unknown');

        expect(targets['calories'], 1000.0);
      });
    });

    group('calculatePercentage', () {
      test('should calculate percentage correctly', () {
        expect(NutritionTrackerService.calculatePercentage(50, 100), 50.0);
        expect(NutritionTrackerService.calculatePercentage(100, 100), 100.0);
        expect(NutritionTrackerService.calculatePercentage(150, 100), 150.0);
      });

      test('should return 0 for zero target', () {
        expect(NutritionTrackerService.calculatePercentage(50, 0), 0.0);
      });

      test('should cap at 200%', () {
        expect(NutritionTrackerService.calculatePercentage(300, 100), 200.0);
      });

      test('should return 0 for negative values', () {
        expect(NutritionTrackerService.calculatePercentage(-50, 100), 0.0);
      });
    });

    group('getColorForPercentage', () {
      test('should return green for 0-80%', () {
        expect(
          NutritionTrackerService.getColorForPercentage(0),
          NutritionColor.green,
        );
        expect(
          NutritionTrackerService.getColorForPercentage(50),
          NutritionColor.green,
        );
        expect(
          NutritionTrackerService.getColorForPercentage(80),
          NutritionColor.green,
        );
      });

      test('should return yellow for 81-100%', () {
        expect(
          NutritionTrackerService.getColorForPercentage(81),
          NutritionColor.yellow,
        );
        expect(
          NutritionTrackerService.getColorForPercentage(90),
          NutritionColor.yellow,
        );
        expect(
          NutritionTrackerService.getColorForPercentage(100),
          NutritionColor.yellow,
        );
      });

      test('should return red for >100%', () {
        expect(
          NutritionTrackerService.getColorForPercentage(101),
          NutritionColor.red,
        );
        expect(
          NutritionTrackerService.getColorForPercentage(150),
          NutritionColor.red,
        );
      });
    });

    group('calculateProgress', () {
      test('should calculate progress correctly for baby profile', () {
        const summary = NutritionSummary(
          calories: 500,
          protein: 10,
          carbs: 65,
          fat: 20,
        );

        final progress = NutritionTrackerService.calculateProgress(
          summary: summary,
          profileType: 'baby',
        );

        expect(progress.summary, summary);
        expect(progress.caloriesPercentage, 50.0);
        expect(progress.proteinPercentage, closeTo(66.67, 0.1));
        expect(progress.carbsPercentage, 50.0);
        expect(progress.fatPercentage, closeTo(57.14, 0.1));
        expect(progress.caloriesColor, NutritionColor.green);
      });

      test('should calculate progress correctly for mother profile', () {
        const summary = NutritionSummary(
          calories: 2000,
          protein: 60,
          carbs: 250,
          fat: 70,
        );

        final progress = NutritionTrackerService.calculateProgress(
          summary: summary,
          profileType: 'mother',
        );

        expect(progress.summary, summary);
        expect(progress.caloriesPercentage, closeTo(86.96, 0.1));
        expect(progress.proteinPercentage, closeTo(92.31, 0.1));
        expect(progress.carbsPercentage, closeTo(83.33, 0.1));
        expect(progress.fatPercentage, closeTo(93.33, 0.1));
        expect(progress.caloriesColor, NutritionColor.yellow);
      });

      test('should handle exceeded targets', () {
        const summary = NutritionSummary(
          calories: 1200,
          protein: 20,
          carbs: 150,
          fat: 40,
        );

        final progress = NutritionTrackerService.calculateProgress(
          summary: summary,
          profileType: 'baby',
        );

        expect(progress.caloriesPercentage, 120.0);
        expect(progress.caloriesColor, NutritionColor.red);
      });
    });

    group('hasExceededTarget', () {
      test('should return false when no nutrient exceeds target', () {
        const summary = NutritionSummary(
          calories: 500,
          protein: 10,
          carbs: 65,
          fat: 20,
        );

        final progress = NutritionTrackerService.calculateProgress(
          summary: summary,
          profileType: 'baby',
        );

        expect(NutritionTrackerService.hasExceededTarget(progress), false);
      });

      test('should return true when any nutrient exceeds target', () {
        const summary = NutritionSummary(
          calories: 1200,
          protein: 10,
          carbs: 65,
          fat: 20,
        );

        final progress = NutritionTrackerService.calculateProgress(
          summary: summary,
          profileType: 'baby',
        );

        expect(NutritionTrackerService.hasExceededTarget(progress), true);
      });
    });

    group('getWarningMessage', () {
      test('should return null when no nutrient exceeds target', () {
        const summary = NutritionSummary(
          calories: 500,
          protein: 10,
          carbs: 65,
          fat: 20,
        );

        final progress = NutritionTrackerService.calculateProgress(
          summary: summary,
          profileType: 'baby',
        );

        expect(NutritionTrackerService.getWarningMessage(progress), null);
      });

      test('should return warning message when nutrients exceed target', () {
        const summary = NutritionSummary(
          calories: 1200,
          protein: 20,
          carbs: 150,
          fat: 40,
        );

        final progress = NutritionTrackerService.calculateProgress(
          summary: summary,
          profileType: 'baby',
        );

        final message = NutritionTrackerService.getWarningMessage(progress);
        expect(message, isNotNull);
        expect(message, contains('Target'));
        expect(message, contains('terlampaui'));
      });
    });

    group('NutritionProgress', () {
      test('should get target for specific nutrient', () {
        const summary = NutritionSummary(
          calories: 500,
          protein: 10,
          carbs: 65,
          fat: 20,
        );

        final progress = NutritionTrackerService.calculateProgress(
          summary: summary,
          profileType: 'baby',
        );

        expect(progress.getTarget('calories'), 1000.0);
        expect(progress.getTarget('protein'), 15.0);
        expect(progress.getTarget('carbs'), 130.0);
        expect(progress.getTarget('fat'), 35.0);
      });

      test('should get current value for specific nutrient', () {
        const summary = NutritionSummary(
          calories: 500,
          protein: 10,
          carbs: 65,
          fat: 20,
        );

        final progress = NutritionTrackerService.calculateProgress(
          summary: summary,
          profileType: 'baby',
        );

        expect(progress.getCurrent('calories'), 500.0);
        expect(progress.getCurrent('protein'), 10.0);
        expect(progress.getCurrent('carbs'), 65.0);
        expect(progress.getCurrent('fat'), 20.0);
      });

      test('should get percentage for specific nutrient', () {
        const summary = NutritionSummary(
          calories: 500,
          protein: 10,
          carbs: 65,
          fat: 20,
        );

        final progress = NutritionTrackerService.calculateProgress(
          summary: summary,
          profileType: 'baby',
        );

        expect(progress.getPercentage('calories'), 50.0);
        expect(progress.getPercentage('protein'), closeTo(66.67, 0.1));
      });

      test('should get color for specific nutrient', () {
        const summary = NutritionSummary(
          calories: 500,
          protein: 10,
          carbs: 65,
          fat: 20,
        );

        final progress = NutritionTrackerService.calculateProgress(
          summary: summary,
          profileType: 'baby',
        );

        expect(progress.getColor('calories'), NutritionColor.green);
        expect(progress.getColor('protein'), NutritionColor.green);
      });
    });
  });
}
