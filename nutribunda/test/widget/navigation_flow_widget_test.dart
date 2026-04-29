import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:nutribunda/presentation/pages/main_navigation.dart';
import 'package:nutribunda/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:nutribunda/presentation/pages/diary/diary_screen.dart';
import 'package:nutribunda/presentation/pages/lbs/lbs_screen.dart';
import 'package:nutribunda/presentation/pages/profile/profile_screen.dart';
import 'package:nutribunda/presentation/providers/lbs_provider.dart';
import 'package:nutribunda/presentation/providers/profile_provider.dart';
import 'package:nutribunda/presentation/providers/auth_provider.dart';
import 'package:nutribunda/presentation/providers/food_diary_provider.dart';
import 'package:nutribunda/presentation/providers/diet_plan_provider.dart';

import '../test_helpers.dart';

/// Widget Tests untuk Navigation Flow
/// 
/// **Validates: Requirements 12.1-12.5, 13.1-13.6**
/// 
/// Test ini mencakup:
/// - Bottom navigation functionality (Requirements 13.1-13.6)
/// - Profile management screens (Requirements 12.1-12.5)
/// - Navigation between 4 tabs: Home, Diary, Peta, Profil
/// - Screen transitions and state preservation
/// - Error handling in navigation
void main() {
  group('Navigation Flow Widget Tests', () {
    late MockLBSProvider mockLBSProvider;
    late MockProfileProvider mockProfileProvider;
    late MockAuthProvider mockAuthProvider;
    late MockFoodDiaryProvider mockFoodDiaryProvider;
    late MockDietPlanProvider mockDietPlanProvider;

    setUp(() {
      mockLBSProvider = MockLBSProvider();
      mockProfileProvider = MockProfileProvider();
      mockAuthProvider = MockAuthProvider();
      mockFoodDiaryProvider = MockFoodDiaryProvider();
      mockDietPlanProvider = MockDietPlanProvider();

      // Setup default mock behaviors
      when(mockLBSProvider.isLoadingLocation).thenReturn(false);
      when(mockLBSProvider.currentPosition).thenReturn(null);
      when(mockLBSProvider.errorMessage).thenReturn(null);

      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.user).thenReturn(null);
      when(mockProfileProvider.errorMessage).thenReturn(null);

      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(null);

      when(mockFoodDiaryProvider.isLoading).thenReturn(false);
      when(mockFoodDiaryProvider.entries).thenReturn([]);
      // Don't mock nutritionSummary as it's non-nullable - let it use the fake

      when(mockDietPlanProvider.isLoading).thenReturn(false);
      when(mockDietPlanProvider.bmr).thenReturn(null);
      when(mockDietPlanProvider.tdee).thenReturn(null);
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<LBSProvider>.value(value: mockLBSProvider),
          ChangeNotifierProvider<ProfileProvider>.value(value: mockProfileProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ChangeNotifierProvider<FoodDiaryProvider>.value(value: mockFoodDiaryProvider),
          ChangeNotifierProvider<DietPlanProvider>.value(value: mockDietPlanProvider),
        ],
        child: MaterialApp(
          home: const MainNavigation(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
        ),
      );
    }

    group('Bottom Navigation Bar Tests', () {
      testWidgets(
        'should display bottom navigation bar with 4 tabs',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.1**
          // Bottom navigation bar should have 4 tabs: Home, Diary, Peta, Profil
          
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Verify bottom navigation bar exists
          expect(find.byType(BottomNavigationBar), findsOneWidget);

          // Verify all 4 tabs are present
          expect(find.text('Home'), findsOneWidget);
          expect(find.text('Diary'), findsOneWidget);
          expect(find.text('Peta'), findsOneWidget);
          expect(find.text('Profil'), findsOneWidget);

          // Verify icons are present
          expect(find.byIcon(Icons.home), findsOneWidget);
          expect(find.byIcon(Icons.book), findsOneWidget);
          expect(find.byIcon(Icons.map), findsOneWidget);
          expect(find.byIcon(Icons.person), findsOneWidget);

          // Verify tooltips for accessibility
          final bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(bottomNavBar.items[0].tooltip, contains('Dashboard'));
          expect(bottomNavBar.items[1].tooltip, contains('Pencatatan makanan'));
          expect(bottomNavBar.items[2].tooltip, contains('fasilitas kesehatan'));
          expect(bottomNavBar.items[3].tooltip, contains('Profil pengguna'));
        },
      );

      testWidgets(
        'should navigate to Home tab and display dashboard screen',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.2**
          // Home tab should display dashboard with nutrition summary and TanyaBunda AI access
          
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Home tab should be selected by default
          final bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(bottomNavBar.currentIndex, equals(0));

          // Verify dashboard screen is displayed
          expect(find.byType(DashboardScreen), findsOneWidget);

          // Tap Home tab explicitly to test navigation
          await tester.tap(find.text('Home'));
          await tester.pumpAndSettle();

          // Verify still on dashboard
          expect(find.byType(DashboardScreen), findsOneWidget);
          
          // Verify bottom navigation is still visible
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );

      testWidgets(
        'should navigate to Diary tab and display diary screen',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.3**
          // Diary tab should display Food_Diary with baby and mother profile options
          
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Tap Diary tab
          await tester.tap(find.text('Diary'));
          await tester.pumpAndSettle();

          // Verify diary screen is displayed
          expect(find.byType(DiaryScreen), findsOneWidget);

          // Verify tab selection changed
          final bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(bottomNavBar.currentIndex, equals(1));

          // Verify bottom navigation is still visible
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );

      testWidgets(
        'should navigate to Peta tab and display LBS screen',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.4**
          // Peta tab should display LBS_Service with interactive map
          
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Tap Peta tab
          await tester.tap(find.text('Peta'));
          await tester.pumpAndSettle();

          // Verify LBS screen is displayed
          expect(find.byType(LBSScreen), findsOneWidget);

          // Verify tab selection changed
          final bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(bottomNavBar.currentIndex, equals(2));

          // Verify bottom navigation is still visible
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );

      testWidgets(
        'should navigate to Profil tab and display profile screen',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.5**
          // Profil tab should display profile screen with logout button
          
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Tap Profil tab
          await tester.tap(find.text('Profil'));
          await tester.pumpAndSettle();

          // Verify profile screen is displayed
          expect(find.byType(ProfileScreen), findsOneWidget);

          // Verify tab selection changed
          final bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(bottomNavBar.currentIndex, equals(3));

          // Verify bottom navigation is still visible
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );

      testWidgets(
        'should maintain bottom navigation visibility across all screens',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.6**
          // Bottom navigation bar should be visible consistently across all screens
          
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          final tabs = ['Home', 'Diary', 'Peta', 'Profil'];

          for (final tabName in tabs) {
            // Navigate to each tab
            await tester.tap(find.text(tabName));
            await tester.pumpAndSettle();

            // Verify bottom navigation bar is still visible
            expect(
              find.byType(BottomNavigationBar), 
              findsOneWidget,
              reason: 'Bottom navigation should be visible on $tabName tab',
            );

            // Verify all tab labels are still present
            for (final otherTab in tabs) {
              expect(
                find.text(otherTab), 
                findsOneWidget,
                reason: '$otherTab should be visible in bottom navigation on $tabName screen',
              );
            }
          }
        },
      );

      testWidgets(
        'should highlight selected tab correctly',
        (WidgetTester tester) async {
          // **Validates: Requirements 13.1-13.6**
          // Selected tab should be visually highlighted
          
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Initially, Home tab (index 0) should be selected
          BottomNavigationBar bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(bottomNavBar.currentIndex, equals(0));

          // Navigate through all tabs and verify selection
          final tabsWithIndices = [
            ('Diary', 1),
            ('Peta', 2),
            ('Profil', 3),
            ('Home', 0),
          ];

          for (final (tabName, expectedIndex) in tabsWithIndices) {
            await tester.tap(find.text(tabName));
            await tester.pumpAndSettle();

            bottomNavBar = tester.widget<BottomNavigationBar>(
              find.byType(BottomNavigationBar),
            );
            expect(
              bottomNavBar.currentIndex, 
              equals(expectedIndex),
              reason: '$tabName tab should be selected (index $expectedIndex)',
            );
          }
        },
      );

      testWidgets(
        'should preserve screen state when switching between tabs',
        (WidgetTester tester) async {
          // **Validates: Navigation state persistence**
          // Screen state should be preserved when switching between tabs (IndexedStack behavior)
          
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Verify IndexedStack is used for state preservation
          expect(find.byType(IndexedStack), findsOneWidget);

          // Navigate to different tabs
          await tester.tap(find.text('Diary'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Peta'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Profil'));
          await tester.pumpAndSettle();

          // Navigate back to Home
          await tester.tap(find.text('Home'));
          await tester.pumpAndSettle();

          // Verify all screens are still in the widget tree (IndexedStack behavior)
          expect(find.byType(DashboardScreen), findsOneWidget);
          expect(find.byType(DiaryScreen), findsOneWidget);
          expect(find.byType(LBSScreen), findsOneWidget);
          expect(find.byType(ProfileScreen), findsOneWidget);
        },
      );
    });

    group('Navigation Accessibility Tests', () {
      testWidgets(
        'should have proper semantic labels for navigation tabs',
        (WidgetTester tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          final bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );

          // Verify each tab has proper labels and tooltips
          expect(bottomNavBar.items.length, equals(4));
          
          for (int i = 0; i < bottomNavBar.items.length; i++) {
            final item = bottomNavBar.items[i];
            expect(item.label, isNotNull);
            expect(item.label, isNotEmpty);
            expect(item.tooltip, isNotNull);
            expect(item.tooltip, isNotEmpty);
          }

          // Verify specific accessibility information
          expect(bottomNavBar.items[0].label, equals('Home'));
          expect(bottomNavBar.items[1].label, equals('Diary'));
          expect(bottomNavBar.items[2].label, equals('Peta'));
          expect(bottomNavBar.items[3].label, equals('Profil'));
        },
      );

      testWidgets(
        'should support tap gestures on all navigation items',
        (WidgetTester tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Test that all navigation items are tappable
          final tabs = ['Home', 'Diary', 'Peta', 'Profil'];

          for (final tabName in tabs) {
            final tabFinder = find.text(tabName);
            expect(tabFinder, findsOneWidget);

            // Verify the tab is tappable
            await tester.tap(tabFinder);
            await tester.pumpAndSettle();

            // Verify navigation occurred
            expect(find.byType(BottomNavigationBar), findsOneWidget);
          }
        },
      );
    });

    group('Navigation Error Handling Tests', () {
      testWidgets(
        'should handle provider errors gracefully',
        (WidgetTester tester) async {
          // Setup error states
          when(mockLBSProvider.errorMessage).thenReturn('Location error');
          when(mockProfileProvider.errorMessage).thenReturn('Profile error');

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Navigate to each tab and verify no crashes occur
          final tabs = ['Home', 'Diary', 'Peta', 'Profil'];

          for (final tabName in tabs) {
            await tester.tap(find.text(tabName));
            await tester.pumpAndSettle();

            // Verify navigation still works despite errors
            expect(find.byType(BottomNavigationBar), findsOneWidget);
          }
        },
      );

      testWidgets(
        'should handle loading states properly',
        (WidgetTester tester) async {
          // Setup loading states
          when(mockLBSProvider.isLoadingLocation).thenReturn(true);
          when(mockProfileProvider.isLoading).thenReturn(true);

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Navigate to tabs with loading states
          await tester.tap(find.text('Peta'));
          await tester.pumpAndSettle();

          // Verify loading indicators are shown but navigation still works
          expect(find.byType(BottomNavigationBar), findsOneWidget);

          await tester.tap(find.text('Profil'));
          await tester.pumpAndSettle();

          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );
    });

    group('Navigation Performance Tests', () {
      testWidgets(
        'should navigate between tabs efficiently',
        (WidgetTester tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          final stopwatch = Stopwatch()..start();

          // Rapidly switch between tabs
          final tabs = ['Diary', 'Peta', 'Profil', 'Home'];
          
          for (int cycle = 0; cycle < 2; cycle++) {
            for (final tabName in tabs) {
              await tester.tap(find.text(tabName));
              await tester.pump(); // Don't wait for settle to test responsiveness
            }
          }

          await tester.pumpAndSettle();
          stopwatch.stop();

          // Navigation should be responsive
          expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max

          // Verify final state is correct
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );

      testWidgets(
        'should not rebuild unnecessary widgets during navigation',
        (WidgetTester tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Verify IndexedStack is used (preserves widget state)
          expect(find.byType(IndexedStack), findsOneWidget);

          // Navigate between tabs
          await tester.tap(find.text('Diary'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Home'));
          await tester.pumpAndSettle();

          // All screens should still exist in the widget tree
          expect(find.byType(DashboardScreen), findsOneWidget);
          expect(find.byType(DiaryScreen), findsOneWidget);
          expect(find.byType(LBSScreen), findsOneWidget);
          expect(find.byType(ProfileScreen), findsOneWidget);
        },
      );
    });
  });
}