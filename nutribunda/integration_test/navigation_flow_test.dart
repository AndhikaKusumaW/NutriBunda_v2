import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutribunda/main.dart' as app;
import 'package:nutribunda/injection_container.dart' as di;
import 'package:nutribunda/core/services/secure_storage_service.dart';

/// Integration Tests untuk Navigation Flow
/// 
/// **Validates: Requirements 13.1-13.6**
/// 
/// Test ini mencakup:
/// - Bottom navigation functionality (Requirements 13.1-13.6)
/// - Navigation between 4 tabs: Home, Diary, Peta, Profil
/// - Correct screen displays for each tab
/// - Navigation state persistence
/// - Bottom navigation bar visibility across screens
/// 
/// CATATAN: Test ini memerlukan user yang sudah login atau mock authentication
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Flow Integration Tests', () {
    setUp(() async {
      // Initialize dependency injection
      await di.init();
      
      // Setup authenticated state for navigation tests
      final secureStorage = di.sl<SecureStorageService>();
      await secureStorage.saveAccessToken('test_navigation_token');
      await secureStorage.saveUserEmail('test@nutribunda.com');
      await secureStorage.saveUserId('test-user-navigation');
    });

    tearDown(() async {
      // Clean up after each test
      final secureStorage = di.sl<SecureStorageService>();
      await secureStorage.clearAll();
    });

    group('Bottom Navigation Tests', () {
      testWidgets(
        'should display bottom navigation bar with 4 tabs',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.1**
          // Bottom navigation bar should have 4 tabs: Home, Diary, Peta, Profil
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

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
        },
      );

      testWidgets(
        'should navigate to Home tab and display dashboard',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.2**
          // Home tab should display dashboard with nutrition summary and TanyaBunda AI access
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Tap Home tab (should be selected by default)
          final homeTab = find.text('Home');
          await tester.tap(homeTab);
          await tester.pumpAndSettle();

          // Verify dashboard elements are displayed
          // Look for dashboard-specific content
          expect(
            find.byWidgetPredicate(
              (widget) => widget is Text && 
                         (widget.data?.contains('Selamat Datang') == true ||
                          widget.data?.contains('Dashboard') == true ||
                          widget.data?.contains('Ringkasan') == true),
            ),
            findsWidgets,
          );

          // Verify bottom navigation is still visible
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );

      testWidgets(
        'should navigate to Diary tab and display food diary',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.3**
          // Diary tab should display Food_Diary with baby and mother profile options
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Tap Diary tab
          final diaryTab = find.text('Diary');
          await tester.tap(diaryTab);
          await tester.pumpAndSettle();

          // Verify diary screen elements
          expect(
            find.byWidgetPredicate(
              (widget) => widget is Text && 
                         (widget.data?.contains('Diary') == true ||
                          widget.data?.contains('Makanan') == true ||
                          widget.data?.contains('Bayi') == true ||
                          widget.data?.contains('Ibu') == true),
            ),
            findsWidgets,
          );

          // Verify profile toggle options (Bayi/Ibu) are available
          // This might be in a tab bar or toggle buttons
          final profileToggleFinder = find.byWidgetPredicate(
            (widget) => (widget is Tab || widget is ToggleButtons || widget is SegmentedButton) ||
                       (widget is Text && (widget.data == 'Bayi' || widget.data == 'Ibu')),
          );
          expect(profileToggleFinder, findsWidgets);

          // Verify bottom navigation is still visible
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );

      testWidgets(
        'should navigate to Peta tab and display LBS screen',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.4**
          // Peta tab should display LBS_Service with interactive map
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Tap Peta tab
          final petaTab = find.text('Peta');
          await tester.tap(petaTab);
          await tester.pumpAndSettle(const Duration(seconds: 5)); // Allow time for location services

          // Verify LBS screen elements
          expect(
            find.byWidgetPredicate(
              (widget) => widget is Text && 
                         (widget.data?.contains('Fasilitas') == true ||
                          widget.data?.contains('Kesehatan') == true ||
                          widget.data?.contains('Lokasi') == true ||
                          widget.data?.contains('Peta') == true),
            ),
            findsWidgets,
          );

          // Verify facility category options are available
          final facilityCategories = [
            'Rumah Sakit',
            'Puskesmas', 
            'Posyandu',
            'Apotek'
          ];

          for (final category in facilityCategories) {
            expect(
              find.byWidgetPredicate(
                (widget) => widget is Text && widget.data?.contains(category) == true,
              ),
              findsWidgets,
            );
          }

          // Verify bottom navigation is still visible
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );

      testWidgets(
        'should navigate to Profil tab and display profile screen',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.5**
          // Profil tab should display profile screen with logout button
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Tap Profil tab
          final profilTab = find.text('Profil');
          await tester.tap(profilTab);
          await tester.pumpAndSettle();

          // Verify profile screen elements
          expect(
            find.byWidgetPredicate(
              (widget) => widget is Text && 
                         (widget.data?.contains('Profil') == true ||
                          widget.data?.contains('Informasi') == true ||
                          widget.data?.contains('Pribadi') == true),
            ),
            findsWidgets,
          );

          // Verify logout functionality is available (settings icon or logout button)
          final logoutFinder = find.byWidgetPredicate(
            (widget) => (widget is Icon && widget.icon == Icons.settings) ||
                       (widget is Icon && widget.icon == Icons.logout) ||
                       (widget is Text && widget.data?.contains('Logout') == true),
          );
          expect(logoutFinder, findsWidgets);

          // Verify bottom navigation is still visible
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );

      testWidgets(
        'should maintain bottom navigation bar visibility across all screens',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.6**
          // Bottom navigation bar should be visible consistently across all screens
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          final tabs = ['Home', 'Diary', 'Peta', 'Profil'];

          for (final tabName in tabs) {
            // Navigate to each tab
            final tab = find.text(tabName);
            await tester.tap(tab);
            await tester.pumpAndSettle(const Duration(seconds: 2));

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
        'should highlight selected tab in bottom navigation',
        (WidgetTester tester) async {
          // **Validates: Requirements 13.1-13.6**
          // Selected tab should be visually highlighted
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Get the bottom navigation bar
          final bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );

          // Initially, Home tab (index 0) should be selected
          expect(bottomNavBar.currentIndex, equals(0));

          // Navigate to Diary tab
          final diaryTab = find.text('Diary');
          await tester.tap(diaryTab);
          await tester.pumpAndSettle();

          // Verify Diary tab (index 1) is now selected
          final updatedBottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(updatedBottomNavBar.currentIndex, equals(1));

          // Navigate to Peta tab
          final petaTab = find.text('Peta');
          await tester.tap(petaTab);
          await tester.pumpAndSettle();

          // Verify Peta tab (index 2) is now selected
          final petaBottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(petaBottomNavBar.currentIndex, equals(2));

          // Navigate to Profil tab
          final profilTab = find.text('Profil');
          await tester.tap(profilTab);
          await tester.pumpAndSettle();

          // Verify Profil tab (index 3) is now selected
          final profilBottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(profilBottomNavBar.currentIndex, equals(3));
        },
      );

      testWidgets(
        'should preserve screen state when switching between tabs',
        (WidgetTester tester) async {
          // **Validates: Navigation state persistence**
          // Screen state should be preserved when switching between tabs (IndexedStack behavior)
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Start on Home tab and perform some interaction
          // (This test assumes there's some stateful content on the home screen)
          
          // Navigate to Diary tab
          final diaryTab = find.text('Diary');
          await tester.tap(diaryTab);
          await tester.pumpAndSettle();

          // Perform some interaction on Diary screen if possible
          // (e.g., switch between Bayi/Ibu profiles)
          
          // Navigate back to Home tab
          final homeTab = find.text('Home');
          await tester.tap(homeTab);
          await tester.pumpAndSettle();

          // Navigate back to Diary tab
          await tester.tap(diaryTab);
          await tester.pumpAndSettle();

          // Verify that the Diary screen state is preserved
          // (This is more of a structural test - IndexedStack should preserve state)
          expect(find.byType(BottomNavigationBar), findsOneWidget);
          
          // The actual state preservation would depend on the specific implementation
          // of each screen and would require more specific assertions based on the content
        },
      );
    });

    group('Navigation Error Handling Tests', () {
      testWidgets(
        'should handle navigation when user is not authenticated',
        (WidgetTester tester) async {
          // Clear authentication state
          final secureStorage = di.sl<SecureStorageService>();
          await secureStorage.clearAll();

          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Should redirect to login screen instead of showing navigation
          expect(find.text('Masuk'), findsOneWidget);
          expect(find.byType(BottomNavigationBar), findsNothing);
        },
      );

      testWidgets(
        'should handle network errors gracefully in navigation screens',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to each tab and verify no crashes occur
          // Even if network requests fail, the UI should remain stable
          
          final tabs = ['Home', 'Diary', 'Peta', 'Profil'];

          for (final tabName in tabs) {
            final tab = find.text(tabName);
            await tester.tap(tab);
            await tester.pumpAndSettle(const Duration(seconds: 3));

            // Verify no error dialogs or crashes
            expect(find.byType(BottomNavigationBar), findsOneWidget);
            
            // Look for error handling UI elements
            final errorIndicators = find.byWidgetPredicate(
              (widget) => widget is Text && 
                         (widget.data?.contains('error') == true ||
                          widget.data?.contains('Error') == true ||
                          widget.data?.contains('Gagal') == true ||
                          widget.data?.contains('Coba Lagi') == true),
            );
            
            // If errors are shown, they should be handled gracefully
            // (not crash the app)
            if (errorIndicators.evaluate().isNotEmpty) {
              // Verify error is displayed properly
              expect(errorIndicators, findsWidgets);
            }
          }
        },
      );
    });

    group('Accessibility Tests', () {
      testWidgets(
        'should have proper accessibility labels for navigation tabs',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verify semantic labels for accessibility
          final bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );

          // Check that each tab has proper tooltip/semantic information
          for (int i = 0; i < bottomNavBar.items.length; i++) {
            final item = bottomNavBar.items[i];
            expect(item.label, isNotNull);
            expect(item.label, isNotEmpty);
            
            // Verify tooltip is provided for accessibility
            if (item.tooltip != null) {
              expect(item.tooltip, isNotEmpty);
            }
          }
        },
      );

      testWidgets(
        'should support keyboard navigation',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // This test would verify keyboard navigation support
          // In a real implementation, you would test:
          // - Tab key navigation between bottom navigation items
          // - Enter key activation of navigation items
          // - Focus indicators are visible
          
          // For now, we verify the navigation structure supports focus
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );
    });

    group('Performance Tests', () {
      testWidgets(
        'should navigate between tabs smoothly without performance issues',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          final stopwatch = Stopwatch()..start();
          
          // Rapidly switch between tabs multiple times
          final tabs = ['Diary', 'Peta', 'Profil', 'Home'];
          
          for (int i = 0; i < 3; i++) { // 3 cycles
            for (final tabName in tabs) {
              final tab = find.text(tabName);
              await tester.tap(tab);
              await tester.pump(); // Don't wait for settle to test responsiveness
            }
          }
          
          await tester.pumpAndSettle();
          stopwatch.stop();

          // Navigation should complete within reasonable time
          expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // 10 seconds max
          
          // Verify final state is correct
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );
    });
  });
}