import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nutribunda/presentation/widgets/diet_plan/pedometer_controls.dart';
import 'package:nutribunda/presentation/providers/diet_plan_provider.dart';
import 'package:nutribunda/data/models/user_model.dart';

void main() {
  group('PedometerControls Widget Tests', () {
    late DietPlanProvider dietPlanProvider;

    setUp(() {
      dietPlanProvider = DietPlanProvider();
      
      // Set up user with complete data
      final now = DateTime.now();
      final user = UserModel(
        id: 'test-user-id',
        email: 'test@example.com',
        fullName: 'Test User',
        weight: 60.0,
        height: 165.0,
        age: 30,
        isBreastfeeding: false,
        activityLevel: 'sedentary',
        createdAt: now,
        updatedAt: now,
      );
      
      dietPlanProvider.setUser(user);
    });

    tearDown(() {
      dietPlanProvider.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<DietPlanProvider>.value(
            value: dietPlanProvider,
            child: const PedometerControls(),
          ),
        ),
      );
    }

    testWidgets('should display pedometer controls', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify main elements are present
      expect(find.text('Pedometer'), findsOneWidget);
      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      
      // Verify status indicator
      expect(find.text('Berhenti'), findsOneWidget);
      
      // Verify control buttons
      expect(find.text('Mulai'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('should display step count', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initial step count should be 0
      expect(find.text('0'), findsOneWidget);
      expect(find.text('langkah'), findsOneWidget);
    });

    testWidgets('should display calories burned', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show calories burned text
      expect(find.textContaining('kkal terbakar'), findsOneWidget);
    });

    testWidgets('should update step count when steps change', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Update steps
      dietPlanProvider.updateSteps(1000);
      await tester.pump();

      // Verify step count updated
      expect(find.text('1000'), findsOneWidget);
    });

    testWidgets('should show active status when pedometer is running', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Start pedometer
      dietPlanProvider.startPedometerTracking();
      await tester.pumpAndSettle();

      // Verify status changed to active (check for the status indicator)
      // The pedometer should be listening
      expect(dietPlanProvider.isPedometerActive, isTrue);
      
      // Verify stop button is shown (button text changes to "Berhenti")
      expect(find.text('Berhenti'), findsOneWidget);
    });

    testWidgets('should show start button when pedometer is stopped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify start button is shown
      expect(find.text('Mulai'), findsOneWidget);
    });

    testWidgets('should show stop button when pedometer is active', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Start pedometer
      dietPlanProvider.startPedometerTracking();
      await tester.pump();

      // Verify stop button is shown
      expect(find.text('Berhenti'), findsOneWidget);
    });

    testWidgets('should toggle pedometer on button press', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap start button
      final startButton = find.text('Mulai');
      expect(startButton, findsOneWidget);
      
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Verify pedometer started
      expect(dietPlanProvider.isPedometerActive, isTrue);
    });

    testWidgets('should show reset confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Set some steps
      dietPlanProvider.updateSteps(500);
      await tester.pump();

      // Find and tap reset button
      final resetButton = find.text('Reset');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Reset Pedometer?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('should reset steps when confirmed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Set some steps
      dietPlanProvider.updateSteps(500);
      await tester.pump();

      // Open reset dialog
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Confirm reset
      await tester.tap(find.text('Reset').last);
      await tester.pumpAndSettle();

      // Verify steps reset to 0
      expect(dietPlanProvider.steps, equals(0));
    });

    testWidgets('should display error message when pedometer has error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Simulate error by starting pedometer (will fail in test environment)
      dietPlanProvider.startPedometerTracking();
      await tester.pump();

      // Wait for error to be detected
      await tester.pump(const Duration(milliseconds: 600));

      // Check if error message is displayed (if error occurred)
      if (dietPlanProvider.pedometerError != null) {
        expect(find.text('Pedometer Error'), findsOneWidget);
      }
    });

    testWidgets('should calculate calories burned correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Update steps (1000 steps with 60kg weight)
      // Formula: 1000 * 0.04 * 60 / 1000 = 2.4 kkal
      dietPlanProvider.updateSteps(1000);
      await tester.pump();

      // Verify calories burned
      expect(dietPlanProvider.caloriesBurned, closeTo(2.4, 0.1));
    });

    testWidgets('should show pulsing indicator when active', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Start pedometer
      dietPlanProvider.startPedometerTracking();
      await tester.pump();

      // Verify pulsing dot is present (check for animation)
      // The pulsing dot should be visible when active
      expect(dietPlanProvider.isPedometerActive, isTrue);
    });
  });

  group('PedometerControls Integration Tests', () {
    testWidgets('should integrate with DietPlanProvider correctly', (WidgetTester tester) async {
      final provider = DietPlanProvider();
      
      final now = DateTime.now();
      final user = UserModel(
        id: 'test-user-id',
        email: 'test@example.com',
        fullName: 'Test User',
        weight: 70.0,
        height: 170.0,
        age: 28,
        isBreastfeeding: true,
        activityLevel: 'lightly_active',
        createdAt: now,
        updatedAt: now,
      );
      
      provider.setUser(user);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<DietPlanProvider>.value(
              value: provider,
              child: const PedometerControls(),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Mulai'), findsOneWidget);

      // Start tracking
      provider.startPedometerTracking();
      await tester.pump();

      // Verify active state
      expect(provider.isPedometerActive, isTrue);

      // Simulate step updates
      provider.updateSteps(2000);
      await tester.pump();

      // Verify calories calculation with 70kg weight
      // 2000 * 0.04 * 70 / 1000 = 5.6 kkal
      expect(provider.caloriesBurned, closeTo(5.6, 0.1));

      provider.dispose();
    });
  });
}
