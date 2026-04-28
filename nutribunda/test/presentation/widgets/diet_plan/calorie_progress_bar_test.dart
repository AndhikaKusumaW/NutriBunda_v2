import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nutribunda/presentation/widgets/diet_plan/calorie_progress_bar.dart';
import 'package:nutribunda/presentation/providers/diet_plan_provider.dart';
import 'package:nutribunda/data/models/user_model.dart';

void main() {
  group('CalorieProgressBar Widget Tests', () {
    late DietPlanProvider dietPlanProvider;

    setUp(() {
      dietPlanProvider = DietPlanProvider();
      
      // Setup user with complete data
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        fullName: 'Test User',
        weight: 60.0,
        height: 165.0,
        age: 30,
        isBreastfeeding: false,
        activityLevel: 'sedentary',
        timezone: 'WIB',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      dietPlanProvider.setUser(user);
    });

    Widget createTestWidget({
      required double consumedCalories,
      required double targetCalories,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<DietPlanProvider>.value(
            value: dietPlanProvider,
            child: CalorieProgressBar(
              consumedCalories: consumedCalories,
              targetCalories: targetCalories,
            ),
          ),
        ),
      );
    }

    testWidgets('Requirement 5.9: Shows green color for 0-80% progress',
        (WidgetTester tester) async {
      // Arrange: 50% of target (green zone)
      final targetCalories = dietPlanProvider.targetCalories ?? 1000;
      final consumedCalories = targetCalories * 0.5;

      // Act
      await tester.pumpWidget(createTestWidget(
        consumedCalories: consumedCalories,
        targetCalories: targetCalories,
      ));

      // Assert: Should show "Baik" label (appears in both label and legend)
      expect(find.text('Baik'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Requirement 5.9: Shows yellow color for 81-100% progress',
        (WidgetTester tester) async {
      // Arrange: 90% of target (yellow zone)
      final targetCalories = dietPlanProvider.targetCalories ?? 1000;
      final consumedCalories = targetCalories * 0.9;

      // Act
      await tester.pumpWidget(createTestWidget(
        consumedCalories: consumedCalories,
        targetCalories: targetCalories,
      ));

      // Assert: Should show "Mendekati Target" label
      expect(find.text('Mendekati Target'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('Requirement 5.9: Shows red color for >100% progress',
        (WidgetTester tester) async {
      // Arrange: 120% of target (red zone)
      final targetCalories = dietPlanProvider.targetCalories ?? 1000;
      final consumedCalories = targetCalories * 1.2;

      // Act
      await tester.pumpWidget(createTestWidget(
        consumedCalories: consumedCalories,
        targetCalories: targetCalories,
      ));

      // Assert: Should show "Melebihi Target" label
      expect(find.text('Melebihi Target'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('Shows progress percentage correctly',
        (WidgetTester tester) async {
      // Arrange
      final targetCalories = dietPlanProvider.targetCalories ?? 1000;
      final consumedCalories = targetCalories * 0.75; // 75%

      // Act
      await tester.pumpWidget(createTestWidget(
        consumedCalories: consumedCalories,
        targetCalories: targetCalories,
      ));

      // Assert: Should show percentage
      expect(find.textContaining('%'), findsWidgets);
    });

    testWidgets('Shows color legend with all zones',
        (WidgetTester tester) async {
      // Arrange
      final targetCalories = dietPlanProvider.targetCalories ?? 1000;
      final consumedCalories = targetCalories * 0.5;

      // Act
      await tester.pumpWidget(createTestWidget(
        consumedCalories: consumedCalories,
        targetCalories: targetCalories,
      ));

      // Assert: Should show all legend items
      expect(find.text('0-80%'), findsOneWidget);
      expect(find.text('81-100%'), findsOneWidget);
      expect(find.text('>100%'), findsOneWidget);
      expect(find.text('Baik'), findsAtLeastNWidgets(1)); // Label + legend
      expect(find.text('Mendekati'), findsOneWidget);
      expect(find.text('Melebihi'), findsOneWidget);
    });

    testWidgets('Shows warning icon when calories exceeded',
        (WidgetTester tester) async {
      // Arrange: Exceed target
      final targetCalories = dietPlanProvider.targetCalories ?? 1000;
      final consumedCalories = targetCalories * 1.5;

      // Act
      await tester.pumpWidget(createTestWidget(
        consumedCalories: consumedCalories,
        targetCalories: targetCalories,
      ));

      // Assert: Should show warning icon in progress bar
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });
}
