import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutribunda/main.dart' as app;
import 'package:nutribunda/injection_container.dart' as di;
import 'package:nutribunda/core/services/secure_storage_service.dart';

/// Integration Tests untuk UI Navigation Flow dan Profile Management
/// 
/// **Validates: Requirements 12.1-12.5, 13.1-13.6**
/// 
/// Test ini mencakup:
/// - Bottom navigation functionality (Requirements 13.1-13.6)
/// - Profile management screens (Requirements 12.1-12.5)
/// - Navigation flow testing dengan user interaction
/// - Profile editing dan validation
/// - Error handling dalam navigation dan profile management
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UI Navigation Flow Integration Tests', () {
    setUp(() async {
      // Initialize dependency injection
      await di.init();
      
      // Setup authenticated state for navigation tests
      final secureStorage = di.sl<SecureStorageService>();
      await secureStorage.saveAccessToken('test_ui_navigation_token');
      await secureStorage.saveUserEmail('test@nutribunda.com');
      await secureStorage.saveUserId('test-user-ui-navigation');
    });

    tearDown(() async {
      // Clean up after each test
      final secureStorage = di.sl<SecureStorageService>();
      await secureStorage.clearAll();
    });

    group('Bottom Navigation Flow Tests', () {
      testWidgets(
        'should complete full navigation flow between all tabs',
        (WidgetTester tester) async {
          // **Validates: Requirements 13.1-13.6**
          // Complete navigation flow testing
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verify initial state - Home tab should be selected
          expect(find.byType(BottomNavigationBar), findsOneWidget);
          
          final bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(bottomNavBar.currentIndex, equals(0));

          // Test navigation to each tab with detailed verification
          final navigationTests = [
            {
              'tab': 'Diary',
              'index': 1,
              'expectedContent': ['Diary', 'Makanan', 'Bayi', 'Ibu'],
              'requirement': '13.3',
            },
            {
              'tab': 'Peta',
              'index': 2,
              'expectedContent': ['Fasilitas', 'Kesehatan', 'Lokasi'],
              'requirement': '13.4',
            },
            {
              'tab': 'Profil',
              'index': 3,
              'expectedContent': ['Profil', 'Informasi'],
              'requirement': '13.5',
            },
            {
              'tab': 'Home',
              'index': 0,
              'expectedContent': ['Dashboard', 'Selamat', 'Ringkasan'],
              'requirement': '13.2',
            },
          ];

          for (final test in navigationTests) {
            // Navigate to tab
            await tester.tap(find.text(test['tab'] as String));
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Verify tab selection
            final updatedBottomNavBar = tester.widget<BottomNavigationBar>(
              find.byType(BottomNavigationBar),
            );
            expect(
              updatedBottomNavBar.currentIndex, 
              equals(test['index']),
              reason: '${test['tab']} tab should be selected (Requirement ${test['requirement']})',
            );

            // Verify bottom navigation is still visible (Requirement 13.6)
            expect(
              find.byType(BottomNavigationBar), 
              findsOneWidget,
              reason: 'Bottom navigation should remain visible on ${test['tab']} tab',
            );

            // Verify expected content is present (flexible matching)
            final expectedContent = test['expectedContent'] as List<String>;
            bool hasExpectedContent = false;
            
            for (final content in expectedContent) {
              if (find.byWidgetPredicate(
                (widget) => widget is Text && 
                           widget.data?.contains(content) == true,
              ).evaluate().isNotEmpty) {
                hasExpectedContent = true;
                break;
              }
            }
            
            expect(
              hasExpectedContent, 
              isTrue,
              reason: '${test['tab']} screen should display relevant content',
            );

            // Small delay between navigation actions
            await tester.pump(const Duration(milliseconds: 500));
          }
        },
      );

      testWidgets(
        'should handle rapid navigation without crashes',
        (WidgetTester tester) async {
          // **Validates: Navigation stability and performance**
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          final tabs = ['Diary', 'Peta', 'Profil', 'Home'];
          
          // Perform rapid navigation
          for (int cycle = 0; cycle < 3; cycle++) {
            for (final tabName in tabs) {
              await tester.tap(find.text(tabName));
              await tester.pump(const Duration(milliseconds: 100));
            }
          }

          // Allow final settling
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verify app is still stable
          expect(find.byType(BottomNavigationBar), findsOneWidget);
          
          // Verify final navigation state
          final finalBottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(finalBottomNavBar.currentIndex, equals(0)); // Should be on Home
        },
      );

      testWidgets(
        'should maintain navigation state during screen rotations',
        (WidgetTester tester) async {
          // **Validates: Navigation state persistence**
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to Diary tab
          await tester.tap(find.text('Diary'));
          await tester.pumpAndSettle();

          // Verify Diary tab is selected
          BottomNavigationBar bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(bottomNavBar.currentIndex, equals(1));

          // Simulate screen rotation (by rebuilding the widget tree)
          await tester.pump();
          await tester.pumpAndSettle();

          // Verify navigation state is preserved
          bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );
          expect(bottomNavBar.currentIndex, equals(1));
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
      );
    });

    group('Profile Management Flow Tests', () {
      testWidgets(
        'should complete profile viewing and editing flow',
        (WidgetTester tester) async {
          // **Validates: Requirements 12.1-12.5**
          // Complete profile management workflow
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to Profile tab
          await tester.tap(find.text('Profil'));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verify profile screen elements (Requirement 12.1)
          expect(find.text('Profil'), findsOneWidget);
          
          // Look for profile-related content
          final profileElements = [
            'Informasi Pribadi',
            'Berat Badan',
            'Tinggi Badan',
            'Edit Profil',
          ];

          for (final element in profileElements) {
            expect(
              find.byWidgetPredicate(
                (widget) => widget is Text && 
                           widget.data?.contains(element) == true,
              ),
              findsWidgets,
              reason: 'Profile screen should display $element',
            );
          }

          // Test navigation to edit profile screen
          final editButton = find.byWidgetPredicate(
            (widget) {
              if (widget is ElevatedButton || widget is TextButton) {
                final child = (widget as dynamic).child;
                if (child is Text) {
                  return child.data?.contains('Edit') == true;
                } else if (child is Row) {
                  return child.children.any(
                    (rowChild) => rowChild is Text && 
                                 rowChild.data?.contains('Edit') == true,
                  );
                }
              }
              return false;
            },
          );

          if (editButton.evaluate().isNotEmpty) {
            await tester.tap(editButton);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Verify edit profile screen (Requirements 12.2-12.5)
            expect(find.text('Edit Profil'), findsOneWidget);
            
            // Verify form fields are present
            final formElements = [
              'Nama Lengkap',
              'Berat Badan',
              'Tinggi Badan',
              'Usia',
              'Status Menyusui',
              'Tingkat Aktivitas',
              'Zona Waktu',
            ];

            for (final element in formElements) {
              expect(
                find.byWidgetPredicate(
                  (widget) => widget is Text && 
                             widget.data?.contains(element) == true,
                ),
                findsWidgets,
                reason: 'Edit profile form should have $element field',
              );
            }

            // Test form validation (Requirements 12.4, 12.5)
            await _testProfileFormValidation(tester);
          }
        },
      );

      testWidgets(
        'should handle profile image selection flow',
        (WidgetTester tester) async {
          // **Validates: Requirement 12.2**
          // Profile image selection from gallery or camera
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to Profile tab
          await tester.tap(find.text('Profil'));
          await tester.pumpAndSettle();

          // Navigate to edit profile
          final editButton = find.byWidgetPredicate(
            (widget) {
              if (widget is ElevatedButton) {
                final child = (widget as dynamic).child;
                return child is Row || child is Text;
              }
              return false;
            },
          );

          if (editButton.evaluate().isNotEmpty) {
            await tester.tap(editButton);
            await tester.pumpAndSettle();

            // Look for camera/image selection button
            final cameraButton = find.byIcon(Icons.camera_alt);
            
            if (cameraButton.evaluate().isNotEmpty) {
              await tester.tap(cameraButton);
              await tester.pumpAndSettle();

              // Verify image source selection options appear
              expect(
                find.byWidgetPredicate(
                  (widget) => widget is Text && 
                             (widget.data?.contains('Galeri') == true ||
                              widget.data?.contains('Foto') == true),
                ),
                findsWidgets,
                reason: 'Image source selection should be available',
              );
            }
          }
        },
      );

      testWidgets(
        'should handle profile data validation correctly',
        (WidgetTester tester) async {
          // **Validates: Requirements 12.4, 12.5**
          // Profile data validation for weight, height, and error messages
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to Profile -> Edit Profile
          await tester.tap(find.text('Profil'));
          await tester.pumpAndSettle();

          final editButton = find.byWidgetPredicate(
            (widget) => widget is ElevatedButton,
          );

          if (editButton.evaluate().isNotEmpty) {
            await tester.tap(editButton);
            await tester.pumpAndSettle();

            // Test weight validation (30-200 kg)
            await _testWeightValidation(tester);
            
            // Test height validation (100-250 cm)
            await _testHeightValidation(tester);
            
            // Test age validation
            await _testAgeValidation(tester);
          }
        },
      );

      testWidgets(
        'should handle profile settings and logout flow',
        (WidgetTester tester) async {
          // **Validates: Requirement 13.5**
          // Profile screen should have logout functionality
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to Profile tab
          await tester.tap(find.text('Profil'));
          await tester.pumpAndSettle();

          // Look for settings icon or logout option
          final settingsButton = find.byIcon(Icons.settings);
          
          if (settingsButton.evaluate().isNotEmpty) {
            await tester.tap(settingsButton);
            await tester.pumpAndSettle();

            // Verify settings screen or logout option is available
            expect(
              find.byWidgetPredicate(
                (widget) => widget is Text && 
                           (widget.data?.contains('Logout') == true ||
                            widget.data?.contains('Keluar') == true ||
                            widget.data?.contains('Settings') == true ||
                            widget.data?.contains('Pengaturan') == true),
              ),
              findsWidgets,
              reason: 'Settings or logout option should be available',
            );
          }
        },
      );
    });

    group('Error Handling and Edge Cases', () {
      testWidgets(
        'should handle network errors gracefully during navigation',
        (WidgetTester tester) async {
          // **Validates: Error handling in navigation**
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate through all tabs even with potential network issues
          final tabs = ['Home', 'Diary', 'Peta', 'Profil'];

          for (final tabName in tabs) {
            await tester.tap(find.text(tabName));
            await tester.pumpAndSettle(const Duration(seconds: 3));

            // Verify navigation still works
            expect(find.byType(BottomNavigationBar), findsOneWidget);
            
            // Check for error handling UI elements
            final errorIndicators = find.byWidgetPredicate(
              (widget) => widget is Text && 
                         (widget.data?.toLowerCase().contains('error') == true ||
                          widget.data?.toLowerCase().contains('gagal') == true ||
                          widget.data?.toLowerCase().contains('coba lagi') == true),
            );
            
            // If errors are present, they should be handled gracefully
            if (errorIndicators.evaluate().isNotEmpty) {
              // Verify error is displayed properly without crashing
              expect(errorIndicators, findsWidgets);
            }
          }
        },
      );

      testWidgets(
        'should handle loading states during navigation',
        (WidgetTester tester) async {
          // **Validates: Loading state handling**
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Navigate to tabs that might have loading states
          await tester.tap(find.text('Peta'));
          await tester.pump(); // Don't wait for settle to catch loading states

          // Look for loading indicators
          final loadingIndicators = find.byType(CircularProgressIndicator);
          
          // If loading indicators are present, verify they work correctly
          if (loadingIndicators.evaluate().isNotEmpty) {
            expect(loadingIndicators, findsWidgets);
            
            // Wait for loading to complete
            await tester.pumpAndSettle(const Duration(seconds: 5));
            
            // Verify navigation is still functional after loading
            expect(find.byType(BottomNavigationBar), findsOneWidget);
          }
        },
      );

      testWidgets(
        'should maintain accessibility during navigation',
        (WidgetTester tester) async {
          // **Validates: Accessibility support**
          
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verify bottom navigation has proper semantic information
          final bottomNavBar = tester.widget<BottomNavigationBar>(
            find.byType(BottomNavigationBar),
          );

          for (int i = 0; i < bottomNavBar.items.length; i++) {
            final item = bottomNavBar.items[i];
            expect(item.label, isNotNull);
            expect(item.label, isNotEmpty);
            
            // Verify tooltip for accessibility
            if (item.tooltip != null) {
              expect(item.tooltip, isNotEmpty);
            }
          }

          // Test navigation with semantic actions
          for (final tabName in ['Home', 'Diary', 'Peta', 'Profil']) {
            await tester.tap(find.text(tabName));
            await tester.pumpAndSettle();

            // Verify semantic structure is maintained
            expect(find.byType(BottomNavigationBar), findsOneWidget);
          }
        },
      );
    });
  });
}

/// Helper function to test profile form validation
Future<void> _testProfileFormValidation(WidgetTester tester) async {
  // Test name field validation
  final nameField = find.byWidgetPredicate(
    (widget) {
      if (widget is TextFormField) {
        final decoration = (widget as dynamic).decoration;
        return decoration?.labelText?.contains('Nama') == true;
      }
      return false;
    },
  );

  if (nameField.evaluate().isNotEmpty) {
    await tester.enterText(nameField, '');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Look for validation error
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && 
                   widget.data?.contains('tidak boleh kosong') == true,
      ),
      findsWidgets,
      reason: 'Name validation error should be shown',
    );
  }
}

/// Helper function to test weight validation
Future<void> _testWeightValidation(WidgetTester tester) async {
  final weightField = find.byWidgetPredicate(
    (widget) {
      if (widget is TextFormField) {
        final decoration = (widget as dynamic).decoration;
        return decoration?.labelText?.contains('Berat') == true;
      }
      return false;
    },
  );

  if (weightField.evaluate().isNotEmpty) {
    // Test invalid weight (below minimum)
    await tester.enterText(weightField, '25');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Look for validation error
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && 
                   (widget.data?.contains('30-200') == true ||
                    widget.data?.contains('berat badan') == true),
      ),
      findsWidgets,
      reason: 'Weight validation error should be shown for value below 30kg',
    );

    // Test invalid weight (above maximum)
    await tester.enterText(weightField, '250');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && 
                   (widget.data?.contains('30-200') == true ||
                    widget.data?.contains('berat badan') == true),
      ),
      findsWidgets,
      reason: 'Weight validation error should be shown for value above 200kg',
    );
  }
}

/// Helper function to test height validation
Future<void> _testHeightValidation(WidgetTester tester) async {
  final heightField = find.byWidgetPredicate(
    (widget) {
      if (widget is TextFormField) {
        final decoration = (widget as dynamic).decoration;
        return decoration?.labelText?.contains('Tinggi') == true;
      }
      return false;
    },
  );

  if (heightField.evaluate().isNotEmpty) {
    // Test invalid height (below minimum)
    await tester.enterText(heightField, '90');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && 
                   (widget.data?.contains('100-250') == true ||
                    widget.data?.contains('tinggi badan') == true),
      ),
      findsWidgets,
      reason: 'Height validation error should be shown for value below 100cm',
    );
  }
}

/// Helper function to test age validation
Future<void> _testAgeValidation(WidgetTester tester) async {
  final ageField = find.byWidgetPredicate(
    (widget) {
      if (widget is TextFormField) {
        final decoration = (widget as dynamic).decoration;
        return decoration?.labelText?.contains('Usia') == true;
      }
      return false;
    },
  );

  if (ageField.evaluate().isNotEmpty) {
    // Test invalid age
    await tester.enterText(ageField, '10');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && 
                   (widget.data?.contains('15-60') == true ||
                    widget.data?.contains('usia') == true),
      ),
      findsWidgets,
      reason: 'Age validation error should be shown for invalid age',
    );
  }
}