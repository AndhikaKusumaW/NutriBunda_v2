import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/data/models/nutrition_summary.dart';
import 'package:nutribunda/data/models/diary_entry.dart';

/// Property-Based Test untuk Nutrition Calculations
/// **Validates: Requirements 4.3, 4.5**
/// 
/// Requirement 4.3: WHEN entri makanan ditambahkan, THE Nutrition_Tracker SHALL 
/// menghitung dan memperbarui total Kalori, Protein, Karbohidrat, dan Lemak harian
/// 
/// Requirement 4.5: WHEN pengguna menghapus entri makanan, THE Nutrition_Tracker 
/// SHALL mengurangi total nutrisi harian sesuai dengan kandungan nutrisi entri yang dihapus
///
/// Property 4: Add/remove entry consistency
/// Adding and removing the same entry should result in original state

void main() {
  group('Nutrition Calculations Property Tests', () {
    group('Property 4: Add/remove entry consistency', () {
      /// Helper function to create a DiaryEntry for testing
      DiaryEntry createDiaryEntry({
        required double calories,
        required double protein,
        required double carbs,
        required double fat,
      }) {
        return DiaryEntry(
          id: 'test-entry-${DateTime.now().millisecondsSinceEpoch}',
          userId: 'test-user',
          profileType: 'baby',
          servingSize: 100.0,
          mealTime: 'breakfast',
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      /// Helper function to add a DiaryEntry to NutritionSummary
      NutritionSummary addEntry(NutritionSummary summary, DiaryEntry entry) {
        return summary.add(entry.calories, entry.protein, entry.carbs, entry.fat);
      }

      /// Helper function to remove a DiaryEntry from NutritionSummary
      NutritionSummary removeEntry(NutritionSummary summary, DiaryEntry entry) {
        return summary.remove(entry.calories, entry.protein, entry.carbs, entry.fat);
      }

      /// Property test: Adding and removing the same entry should result in original state
      test('should return to original state after add then remove - zero values', () {
        // Arrange: Original state with zero values
        const original = NutritionSummary(
          calories: 0.0,
          protein: 0.0,
          carbs: 0.0,
          fat: 0.0,
        );

        final entry = createDiaryEntry(
          calories: 100.0,
          protein: 5.0,
          carbs: 20.0,
          fat: 3.0,
        );

        // Act: Add entry then remove it
        final afterAdd = addEntry(original, entry);
        final afterRemove = removeEntry(afterAdd, entry);

        // Assert: Should return to original state
        expect(afterRemove.calories, equals(original.calories));
        expect(afterRemove.protein, equals(original.protein));
        expect(afterRemove.carbs, equals(original.carbs));
        expect(afterRemove.fat, equals(original.fat));
      });

      test('should return to original state after add then remove - small values', () {
        // Arrange: Original state with small values
        const original = NutritionSummary(
          calories: 50.0,
          protein: 2.5,
          carbs: 10.0,
          fat: 1.5,
        );

        final entry = createDiaryEntry(
          calories: 25.0,
          protein: 1.0,
          carbs: 5.0,
          fat: 0.5,
        );

        // Act: Add entry then remove it
        final afterAdd = addEntry(original, entry);
        final afterRemove = removeEntry(afterAdd, entry);

        // Assert: Should return to original state
        expect(afterRemove.calories, equals(original.calories));
        expect(afterRemove.protein, equals(original.protein));
        expect(afterRemove.carbs, equals(original.carbs));
        expect(afterRemove.fat, equals(original.fat));
      });

      test('should return to original state after add then remove - large values', () {
        // Arrange: Original state with large values
        const original = NutritionSummary(
          calories: 1500.0,
          protein: 75.0,
          carbs: 200.0,
          fat: 50.0,
        );

        final entry = createDiaryEntry(
          calories: 500.0,
          protein: 25.0,
          carbs: 60.0,
          fat: 15.0,
        );

        // Act: Add entry then remove it
        final afterAdd = addEntry(original, entry);
        final afterRemove = removeEntry(afterAdd, entry);

        // Assert: Should return to original state
        expect(afterRemove.calories, equals(original.calories));
        expect(afterRemove.protein, equals(original.protein));
        expect(afterRemove.carbs, equals(original.carbs));
        expect(afterRemove.fat, equals(original.fat));
      });

      test('should return to original state after add then remove - decimal values', () {
        // Arrange: Original state with decimal values
        const original = NutritionSummary(
          calories: 123.45,
          protein: 6.78,
          carbs: 15.32,
          fat: 4.21,
        );

        final entry = createDiaryEntry(
          calories: 67.89,
          protein: 3.21,
          carbs: 8.76,
          fat: 2.34,
        );

        // Act: Add entry then remove it
        final afterAdd = addEntry(original, entry);
        final afterRemove = removeEntry(afterAdd, entry);

        // Assert: Should return to original state (with floating point tolerance)
        expect(afterRemove.calories, closeTo(original.calories, 0.001));
        expect(afterRemove.protein, closeTo(original.protein, 0.001));
        expect(afterRemove.carbs, closeTo(original.carbs, 0.001));
        expect(afterRemove.fat, closeTo(original.fat, 0.001));
      });

      test('should return to original state after add then remove - multiple entries', () {
        // Arrange: Original state
        const original = NutritionSummary(
          calories: 200.0,
          protein: 10.0,
          carbs: 30.0,
          fat: 8.0,
        );

        final entry1 = createDiaryEntry(
          calories: 150.0,
          protein: 7.5,
          carbs: 20.0,
          fat: 5.0,
        );

        final entry2 = createDiaryEntry(
          calories: 100.0,
          protein: 5.0,
          carbs: 15.0,
          fat: 3.0,
        );

        final entry3 = createDiaryEntry(
          calories: 75.0,
          protein: 3.5,
          carbs: 10.0,
          fat: 2.5,
        );

        // Act: Add multiple entries then remove them in reverse order
        var current = original;
        current = addEntry(current, entry1);
        current = addEntry(current, entry2);
        current = addEntry(current, entry3);
        
        // Remove in reverse order
        current = removeEntry(current, entry3);
        current = removeEntry(current, entry2);
        current = removeEntry(current, entry1);

        // Assert: Should return to original state
        expect(current.calories, closeTo(original.calories, 0.001));
        expect(current.protein, closeTo(original.protein, 0.001));
        expect(current.carbs, closeTo(original.carbs, 0.001));
        expect(current.fat, closeTo(original.fat, 0.001));
      });

      test('should return to original state after add then remove - edge case with very small values', () {
        // Arrange: Original state with very small values
        const original = NutritionSummary(
          calories: 0.1,
          protein: 0.05,
          carbs: 0.2,
          fat: 0.03,
        );

        final entry = createDiaryEntry(
          calories: 0.5,
          protein: 0.25,
          carbs: 0.8,
          fat: 0.15,
        );

        // Act: Add entry then remove it
        final afterAdd = addEntry(original, entry);
        final afterRemove = removeEntry(afterAdd, entry);

        // Assert: Should return to original state (with floating point tolerance)
        expect(afterRemove.calories, closeTo(original.calories, 0.001));
        expect(afterRemove.protein, closeTo(original.protein, 0.001));
        expect(afterRemove.carbs, closeTo(original.carbs, 0.001));
        expect(afterRemove.fat, closeTo(original.fat, 0.001));
      });

      test('should handle add/remove with mixed positive values', () {
        // Arrange: Test various combinations of nutrition values
        final testCases = [
          {
            'original': const NutritionSummary(calories: 100, protein: 5, carbs: 15, fat: 3),
            'entry': createDiaryEntry(calories: 200, protein: 10, carbs: 25, fat: 7),
          },
          {
            'original': const NutritionSummary(calories: 500, protein: 25, carbs: 60, fat: 15),
            'entry': createDiaryEntry(calories: 300, protein: 15, carbs: 40, fat: 10),
          },
          {
            'original': const NutritionSummary(calories: 1000, protein: 50, carbs: 120, fat: 30),
            'entry': createDiaryEntry(calories: 150, protein: 8, carbs: 20, fat: 5),
          },
          {
            'original': const NutritionSummary(calories: 250.5, protein: 12.3, carbs: 35.7, fat: 8.9),
            'entry': createDiaryEntry(calories: 125.25, protein: 6.15, carbs: 17.85, fat: 4.45),
          },
        ];

        for (var testCase in testCases) {
          final original = testCase['original'] as NutritionSummary;
          final entry = testCase['entry'] as DiaryEntry;

          // Act: Add entry then remove it
          final afterAdd = addEntry(original, entry);
          final afterRemove = removeEntry(afterAdd, entry);

          // Assert: Should return to original state
          expect(afterRemove.calories, closeTo(original.calories, 0.001),
              reason: 'Calories should match for case: $testCase');
          expect(afterRemove.protein, closeTo(original.protein, 0.001),
              reason: 'Protein should match for case: $testCase');
          expect(afterRemove.carbs, closeTo(original.carbs, 0.001),
              reason: 'Carbs should match for case: $testCase');
          expect(afterRemove.fat, closeTo(original.fat, 0.001),
              reason: 'Fat should match for case: $testCase');
        }
      });

      test('should verify add increases nutrition totals correctly', () {
        // Arrange
        const original = NutritionSummary(
          calories: 100.0,
          protein: 5.0,
          carbs: 15.0,
          fat: 3.0,
        );

        final entry = createDiaryEntry(
          calories: 200.0,
          protein: 10.0,
          carbs: 25.0,
          fat: 7.0,
        );

        // Act
        final afterAdd = addEntry(original, entry);

        // Assert: Values should increase by entry amounts
        expect(afterAdd.calories, equals(300.0));
        expect(afterAdd.protein, equals(15.0));
        expect(afterAdd.carbs, equals(40.0));
        expect(afterAdd.fat, equals(10.0));
      });

      test('should verify remove decreases nutrition totals correctly', () {
        // Arrange
        const original = NutritionSummary(
          calories: 300.0,
          protein: 15.0,
          carbs: 40.0,
          fat: 10.0,
        );

        final entry = createDiaryEntry(
          calories: 200.0,
          protein: 10.0,
          carbs: 25.0,
          fat: 7.0,
        );

        // Act
        final afterRemove = removeEntry(original, entry);

        // Assert: Values should decrease by entry amounts
        expect(afterRemove.calories, equals(100.0));
        expect(afterRemove.protein, equals(5.0));
        expect(afterRemove.carbs, equals(15.0));
        expect(afterRemove.fat, equals(3.0));
      });

      test('should not allow negative values when removing', () {
        // Arrange: Original state with small values
        const original = NutritionSummary(
          calories: 50.0,
          protein: 2.0,
          carbs: 5.0,
          fat: 1.0,
        );

        // Entry with larger values than original
        final entry = createDiaryEntry(
          calories: 100.0,
          protein: 5.0,
          carbs: 10.0,
          fat: 3.0,
        );

        // Act: Remove entry (should clamp to 0)
        final afterRemove = removeEntry(original, entry);

        // Assert: Values should be clamped to 0, not negative
        expect(afterRemove.calories, equals(0.0));
        expect(afterRemove.protein, equals(0.0));
        expect(afterRemove.carbs, equals(0.0));
        expect(afterRemove.fat, equals(0.0));
      });

      test('should handle add/remove in different orders', () {
        // Arrange
        const original = NutritionSummary(
          calories: 100.0,
          protein: 5.0,
          carbs: 15.0,
          fat: 3.0,
        );

        final entry1 = createDiaryEntry(
          calories: 150.0,
          protein: 7.5,
          carbs: 20.0,
          fat: 5.0,
        );

        final entry2 = createDiaryEntry(
          calories: 100.0,
          protein: 5.0,
          carbs: 15.0,
          fat: 3.0,
        );

        // Act: Add both, then remove in different order
        var current = original;
        current = addEntry(current, entry1);
        current = addEntry(current, entry2);
        
        // Remove entry2 first, then entry1
        current = removeEntry(current, entry2);
        current = removeEntry(current, entry1);

        // Assert: Should return to original state regardless of removal order
        expect(current.calories, closeTo(original.calories, 0.001));
        expect(current.protein, closeTo(original.protein, 0.001));
        expect(current.carbs, closeTo(original.carbs, 0.001));
        expect(current.fat, closeTo(original.fat, 0.001));
      });

      test('should maintain consistency with real-world MPASI nutrition values', () {
        // Arrange: Realistic MPASI nutrition values
        const original = NutritionSummary(
          calories: 450.0,  // Typical daily intake for 6-12 month baby
          protein: 15.0,
          carbs: 60.0,
          fat: 12.0,
        );

        // Typical MPASI meal: Bubur ayam (100g)
        final entry = createDiaryEntry(
          calories: 130.0,
          protein: 5.5,
          carbs: 18.0,
          fat: 3.5,
        );

        // Act
        final afterAdd = addEntry(original, entry);
        final afterRemove = removeEntry(afterAdd, entry);

        // Assert
        expect(afterRemove.calories, closeTo(original.calories, 0.001));
        expect(afterRemove.protein, closeTo(original.protein, 0.001));
        expect(afterRemove.carbs, closeTo(original.carbs, 0.001));
        expect(afterRemove.fat, closeTo(original.fat, 0.001));
      });

      test('should maintain consistency with real-world mother nutrition values', () {
        // Arrange: Realistic mother nutrition values
        const original = NutritionSummary(
          calories: 1800.0,  // Typical daily intake for breastfeeding mother
          protein: 75.0,
          carbs: 225.0,
          fat: 60.0,
        );

        // Typical meal: Nasi dengan lauk (200g)
        final entry = createDiaryEntry(
          calories: 350.0,
          protein: 18.0,
          carbs: 45.0,
          fat: 12.0,
        );

        // Act
        final afterAdd = addEntry(original, entry);
        final afterRemove = removeEntry(afterAdd, entry);

        // Assert
        expect(afterRemove.calories, closeTo(original.calories, 0.001));
        expect(afterRemove.protein, closeTo(original.protein, 0.001));
        expect(afterRemove.carbs, closeTo(original.carbs, 0.001));
        expect(afterRemove.fat, closeTo(original.fat, 0.001));
      });
    });
  });
}
