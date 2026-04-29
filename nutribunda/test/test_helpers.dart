import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nutribunda/presentation/providers/lbs_provider.dart';
import 'package:nutribunda/presentation/providers/profile_provider.dart';
import 'package:nutribunda/presentation/providers/auth_provider.dart';
import 'package:nutribunda/presentation/providers/food_diary_provider.dart';
import 'package:nutribunda/presentation/providers/diet_plan_provider.dart';

import 'test_helpers.mocks.dart';

// Export mock classes for use in tests
export 'test_helpers.mocks.dart';

/// Helper functions for testing

/// Wraps a widget with MaterialApp for testing
Widget makeTestableWidget(Widget child) {
  return MaterialApp(
    home: child,
  );
}

/// Wraps a widget with MaterialApp and Scaffold for testing
Widget makeTestableWidgetWithScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

/// Pumps a widget and waits for all animations to complete
Future<void> pumpWidgetAndSettle(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

/// Finds a widget by its text and taps it
Future<void> tapByText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pump();
}

/// Finds a widget by its key and taps it
Future<void> tapByKey(WidgetTester tester, Key key) async {
  await tester.tap(find.byKey(key));
  await tester.pump();
}

/// Enters text into a TextField found by key
Future<void> enterTextByKey(
  WidgetTester tester,
  Key key,
  String text,
) async {
  await tester.enterText(find.byKey(key), text);
  await tester.pump();
}

/// Scrolls until a widget is visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder,
  double scrollDelta, {
  Finder? scrollable,
}) async {
  scrollable ??= find.byType(Scrollable).first;
  
  await tester.dragUntilVisible(
    finder,
    scrollable,
    Offset(0, scrollDelta),
  );
}

/// Waits for a specific duration (use sparingly, prefer pumpAndSettle)
Future<void> wait(WidgetTester tester, Duration duration) async {
  await tester.pump(duration);
}

/// Verifies that a widget with the given text exists
void expectTextExists(String text) {
  expect(find.text(text), findsOneWidget);
}

/// Verifies that a widget with the given text does not exist
void expectTextNotExists(String text) {
  expect(find.text(text), findsNothing);
}

/// Verifies that a widget of the given type exists
void expectWidgetExists<T>() {
  expect(find.byType(T), findsOneWidget);
}

/// Verifies that a widget with the given key exists
void expectKeyExists(Key key) {
  expect(find.byKey(key), findsOneWidget);
}

/// Mock data generators for testing

/// Generates a mock user ID
String mockUserId() => 'test-user-123';

/// Generates a mock email
String mockEmail() => 'test@nutribunda.com';

/// Generates a mock password
String mockPassword() => 'Test123!@#';

/// Generates a mock user name
String mockUserName() => 'Test User';

/// Generates a mock food name
String mockFoodName() => 'Nasi Putih';

/// Generates mock nutrition values
Map<String, double> mockNutrition() => {
      'calories': 130.0,
      'protein': 2.7,
      'carbs': 28.0,
      'fat': 0.3,
    };

/// Test constants
class TestConstants {
  static const Duration shortDelay = Duration(milliseconds: 100);
  static const Duration mediumDelay = Duration(milliseconds: 500);
  static const Duration longDelay = Duration(seconds: 1);
  
  static const String testEmail = 'test@nutribunda.com';
  static const String testPassword = 'Test123!@#';
  static const String testUserName = 'Test User';
  
  static const double testWeight = 60.0; // kg
  static const double testHeight = 165.0; // cm
  static const int testAge = 28;
}

/// Custom matchers for testing

/// Matcher for checking if a value is within a range
Matcher inRange(num min, num max) {
  return _InRangeMatcher(min, max);
}

class _InRangeMatcher extends Matcher {
  final num min;
  final num max;

  _InRangeMatcher(this.min, this.max);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! num) return false;
    return item >= min && item <= max;
  }

  @override
  Description describe(Description description) {
    return description.add('a value between $min and $max');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    return mismatchDescription.add('$item is not between $min and $max');
  }
}

/// Matcher for checking if a value is positive
Matcher get isPositive => greaterThan(0);

/// Matcher for checking if a value is negative
Matcher get isNegative => lessThan(0);

/// Matcher for checking if a string is a valid email
Matcher get isValidEmail => matches(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

/// Test data builders

/// Builder for creating test user data
class TestUserBuilder {
  String id = mockUserId();
  String email = mockEmail();
  String name = mockUserName();
  double? weight;
  double? height;
  int? age;
  bool isBreastfeeding = false;

  TestUserBuilder withId(String id) {
    this.id = id;
    return this;
  }

  TestUserBuilder withEmail(String email) {
    this.email = email;
    return this;
  }

  TestUserBuilder withName(String name) {
    this.name = name;
    return this;
  }

  TestUserBuilder withWeight(double weight) {
    this.weight = weight;
    return this;
  }

  TestUserBuilder withHeight(double height) {
    this.height = height;
    return this;
  }

  TestUserBuilder withAge(int age) {
    this.age = age;
    return this;
  }

  TestUserBuilder withBreastfeeding(bool isBreastfeeding) {
    this.isBreastfeeding = isBreastfeeding;
    return this;
  }

  Map<String, dynamic> build() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'weight': weight,
      'height': height,
      'age': age,
      'is_breastfeeding': isBreastfeeding,
    };
  }
}

/// Builder for creating test food data
class TestFoodBuilder {
  String id = 'test-food-123';
  String name = mockFoodName();
  String category = 'mpasi';
  double calories = 130.0;
  double protein = 2.7;
  double carbs = 28.0;
  double fat = 0.3;

  TestFoodBuilder withId(String id) {
    this.id = id;
    return this;
  }

  TestFoodBuilder withName(String name) {
    this.name = name;
    return this;
  }

  TestFoodBuilder withCategory(String category) {
    this.category = category;
    return this;
  }

  TestFoodBuilder withNutrition({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) {
    this.calories = calories;
    this.protein = protein;
    this.carbs = carbs;
    this.fat = fat;
    return this;
  }

  Map<String, dynamic> build() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'calories_per_100g': calories,
      'protein_per_100g': protein,
      'carbs_per_100g': carbs,
      'fat_per_100g': fat,
    };
  }
}
// Mock annotations for generating mock classes
@GenerateMocks([
  LBSProvider,
  ProfileProvider,
  AuthProvider,
  FoodDiaryProvider,
  DietPlanProvider,
])
void main() {}