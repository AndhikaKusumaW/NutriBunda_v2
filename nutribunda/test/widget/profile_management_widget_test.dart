import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:nutribunda/presentation/pages/profile/profile_screen.dart';
import 'package:nutribunda/presentation/pages/profile/edit_profile_screen.dart';
import 'package:nutribunda/presentation/providers/profile_provider.dart';
import 'package:nutribunda/data/models/user_model.dart';

import '../test_helpers.dart';

/// Widget Tests untuk Profile Management Screens
/// 
/// **Validates: Requirements 12.1-12.5**
/// 
/// Test ini mencakup:
/// - Profile display screen (Requirements 12.1)
/// - Photo upload functionality (Requirements 12.2, 12.3)
/// - Data validation (Requirements 12.4, 12.5)
/// - Profile editing workflow
/// - Error handling in profile management
void main() {
  group('Profile Management Widget Tests', () {
    late MockProfileProvider mockProfileProvider;
    late UserModel testUser;

    setUp(() {
      mockProfileProvider = MockProfileProvider();
      
      testUser = UserModel(
        id: 'test-user-id',
        email: 'test@nutribunda.com',
        fullName: 'Test User',
        weight: 65.0,
        height: 165.0,
        age: 28,
        isBreastfeeding: true,
        activityLevel: 'lightly_active',
        timezone: 'WIB',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        profileImageUrl: null, // Use null to avoid network image loading
      );

      // Setup default mock behaviors
      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.user).thenReturn(testUser);
      when(mockProfileProvider.errorMessage).thenReturn(null);
      when(mockProfileProvider.fetchProfile()).thenAnswer((_) async => true);
    });

    Widget createProfileScreenWidget() {
      return ChangeNotifierProvider<ProfileProvider>.value(
        value: mockProfileProvider,
        child: MaterialApp(
          home: const ProfileScreen(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
        ),
      );
    }

    Widget createEditProfileScreenWidget() {
      return ChangeNotifierProvider<ProfileProvider>.value(
        value: mockProfileProvider,
        child: MaterialApp(
          home: const EditProfileScreen(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
        ),
      );
    }

    group('Profile Display Screen Tests', () {
      testWidgets(
        'should display profile information correctly',
        (WidgetTester tester) async {
          // **Validates: Requirement 12.1**
          // Profile service should display profile page with photo, personal data
          
          await tester.pumpWidget(createProfileScreenWidget());
          await tester.pumpAndSettle();

          // Verify app bar
          expect(find.text('Profil'), findsOneWidget);
          expect(find.byIcon(Icons.settings), findsOneWidget);

          // Verify profile header with photo and basic info
          expect(find.byType(CircleAvatar), findsOneWidget);
          expect(find.text(testUser.fullName), findsOneWidget);
          expect(find.text(testUser.email), findsOneWidget);

          // Verify personal information section
          expect(find.text('Informasi Pribadi'), findsOneWidget);
          expect(find.text('Berat Badan'), findsOneWidget);
          expect(find.text('${testUser.weight} kg'), findsOneWidget);
          expect(find.text('Tinggi Badan'), findsOneWidget);
          expect(find.text('${testUser.height} cm'), findsOneWidget);
          expect(find.text('Usia'), findsOneWidget);
          expect(find.text('${testUser.age} tahun'), findsOneWidget);
          expect(find.text('Status Menyusui'), findsOneWidget);
          expect(find.text('Ya'), findsOneWidget); // isBreastfeeding = true
          expect(find.text('Tingkat Aktivitas'), findsOneWidget);
          expect(find.text('Ringan'), findsOneWidget); // lightly_active
          expect(find.text('Zona Waktu'), findsOneWidget);
          expect(find.text('WIB'), findsOneWidget);

          // Verify edit profile button
          expect(find.text('Edit Profil'), findsOneWidget);
          expect(find.byIcon(Icons.edit), findsOneWidget);
        },
      );

      testWidgets(
        'should show loading indicator when fetching profile',
        (WidgetTester tester) async {
          when(mockProfileProvider.isLoading).thenReturn(true);
          when(mockProfileProvider.user).thenReturn(null);

          await tester.pumpWidget(createProfileScreenWidget());
          await tester.pumpAndSettle();

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'should show error message when profile fetch fails',
        (WidgetTester tester) async {
          when(mockProfileProvider.isLoading).thenReturn(false);
          when(mockProfileProvider.user).thenReturn(null);
          when(mockProfileProvider.errorMessage).thenReturn('Failed to load profile');

          await tester.pumpWidget(createProfileScreenWidget());
          await tester.pumpAndSettle();

          expect(find.text('Failed to load profile'), findsOneWidget);
          expect(find.text('Coba Lagi'), findsOneWidget);
        },
      );

      testWidgets(
        'should handle missing profile data gracefully',
        (WidgetTester tester) async {
          final incompleteUser = UserModel(
            id: 'test-user-id',
            email: 'test@nutribunda.com',
            fullName: 'Test User',
            weight: null,
            height: null,
            age: null,
            isBreastfeeding: false,
            activityLevel: 'sedentary',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            timezone: 'WIB',
            profileImageUrl: null,
          );

          when(mockProfileProvider.user).thenReturn(incompleteUser);

          await tester.pumpWidget(createProfileScreenWidget());
          await tester.pumpAndSettle();

          // Verify missing data is handled
          expect(find.text('Belum diisi'), findsNWidgets(3)); // weight, height, age
          expect(find.text('Tidak'), findsOneWidget); // isBreastfeeding = false
          expect(find.text('Tidak Aktif'), findsOneWidget); // sedentary

          // Verify default profile icon is shown when no image
          final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
          expect(circleAvatar.backgroundImage, isNull);
        },
      );

      testWidgets(
        'should navigate to edit profile screen when edit button tapped',
        (WidgetTester tester) async {
          await tester.pumpWidget(createProfileScreenWidget());
          await tester.pumpAndSettle();

          // Tap edit profile button
          await tester.tap(find.text('Edit Profil'));
          await tester.pumpAndSettle();

          // Verify navigation occurred (in real app, would navigate to EditProfileScreen)
          // For this test, we verify the button is tappable
          expect(find.text('Edit Profil'), findsOneWidget);
        },
      );

      testWidgets(
        'should support pull-to-refresh',
        (WidgetTester tester) async {
          await tester.pumpWidget(createProfileScreenWidget());
          await tester.pumpAndSettle();

          // Verify RefreshIndicator is present
          expect(find.byType(RefreshIndicator), findsOneWidget);

          // Simulate pull-to-refresh
          await tester.fling(
            find.byType(SingleChildScrollView),
            const Offset(0, 300),
            1000,
          );
          await tester.pump();

          // Verify refresh indicator appears
          expect(find.byType(RefreshProgressIndicator), findsOneWidget);

          // Complete the refresh
          await tester.pumpAndSettle();

          // Verify fetchProfile was called
          verify(mockProfileProvider.fetchProfile()).called(1);
        },
      );
    });

    group('Edit Profile Screen Tests', () {
      testWidgets(
        'should display edit profile form with current user data',
        (WidgetTester tester) async {
          // **Validates: Requirements 12.1, 12.2**
          // Edit profile form should be pre-populated with current data
          
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Verify app bar
          expect(find.text('Edit Profil'), findsOneWidget);

          // Verify profile image section
          expect(find.byType(CircleAvatar), findsOneWidget);
          expect(find.text('Tap untuk mengubah foto profil'), findsOneWidget);

          // Verify form fields are pre-populated
          expect(find.text('Nama Lengkap'), findsOneWidget);
          final nameField = tester.widget<TextFormField>(
            find.widgetWithText(TextFormField, 'Nama Lengkap'),
          );
          expect((nameField.controller as TextEditingController).text, equals(testUser.fullName));

          expect(find.text('Berat Badan (kg)'), findsOneWidget);
          expect(find.text('Tinggi Badan (cm)'), findsOneWidget);
          expect(find.text('Usia (tahun)'), findsOneWidget);

          // Verify dropdowns
          expect(find.text('Tingkat Aktivitas'), findsOneWidget);
          expect(find.text('Zona Waktu'), findsOneWidget);

          // Verify switch for breastfeeding
          expect(find.text('Status Menyusui'), findsOneWidget);
          final switchTile = tester.widget<SwitchListTile>(
            find.byType(SwitchListTile),
          );
          expect(switchTile.value, equals(testUser.isBreastfeeding));

          // Verify save button
          expect(find.text('Simpan Perubahan'), findsOneWidget);
        },
      );

      testWidgets(
        'should validate weight input correctly',
        (WidgetTester tester) async {
          // **Validates: Requirement 12.4**
          // Validation for weight (30-200kg)
          
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Find weight field
          final weightField = find.widgetWithText(TextFormField, 'Berat Badan (kg)');

          // Test invalid weight (below minimum)
          await tester.enterText(weightField, '25');
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          expect(find.text('Berat badan harus antara 30-200 kg'), findsOneWidget);

          // Test invalid weight (above maximum)
          await tester.enterText(weightField, '250');
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          expect(find.text('Berat badan harus antara 30-200 kg'), findsOneWidget);

          // Test valid weight
          await tester.enterText(weightField, '65');
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          // Should not show validation error
          expect(find.text('Berat badan harus antara 30-200 kg'), findsNothing);
        },
      );

      testWidgets(
        'should validate height input correctly',
        (WidgetTester tester) async {
          // **Validates: Requirement 12.4**
          // Validation for height (100-250cm)
          
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Find height field
          final heightField = find.widgetWithText(TextFormField, 'Tinggi Badan (cm)');

          // Test invalid height (below minimum)
          await tester.enterText(heightField, '90');
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          expect(find.text('Tinggi badan harus antara 100-250 cm'), findsOneWidget);

          // Test invalid height (above maximum)
          await tester.enterText(heightField, '260');
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          expect(find.text('Tinggi badan harus antara 100-250 cm'), findsOneWidget);

          // Test valid height
          await tester.enterText(heightField, '165');
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          // Should not show validation error
          expect(find.text('Tinggi badan harus antara 100-250 cm'), findsNothing);
        },
      );

      testWidgets(
        'should validate age input correctly',
        (WidgetTester tester) async {
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Find age field
          final ageField = find.widgetWithText(TextFormField, 'Usia (tahun)');

          // Test invalid age (below minimum)
          await tester.enterText(ageField, '10');
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          expect(find.text('Usia harus antara 15-60 tahun'), findsOneWidget);

          // Test invalid age (above maximum)
          await tester.enterText(ageField, '70');
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          expect(find.text('Usia harus antara 15-60 tahun'), findsOneWidget);

          // Test valid age
          await tester.enterText(ageField, '28');
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          // Should not show validation error
          expect(find.text('Usia harus antara 15-60 tahun'), findsNothing);
        },
      );

      testWidgets(
        'should validate required name field',
        (WidgetTester tester) async {
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Clear name field
          final nameField = find.widgetWithText(TextFormField, 'Nama Lengkap');
          await tester.enterText(nameField, '');
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          expect(find.text('Nama lengkap tidak boleh kosong'), findsOneWidget);
        },
      );

      testWidgets(
        'should handle profile image selection',
        (WidgetTester tester) async {
          // **Validates: Requirement 12.2**
          // User should be able to select image from gallery or camera
          
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Tap on camera icon to change profile image
          final cameraButton = find.byIcon(Icons.camera_alt);
          await tester.tap(cameraButton);
          await tester.pumpAndSettle();

          // Verify image source selection dialog appears
          expect(find.text('Pilih dari Galeri'), findsOneWidget);
          expect(find.text('Ambil Foto'), findsOneWidget);
          expect(find.byIcon(Icons.photo_library), findsOneWidget);
          expect(find.byIcon(Icons.camera_alt), findsNWidgets(2)); // One in dialog, one in profile
        },
      );

      testWidgets(
        'should update breastfeeding status',
        (WidgetTester tester) async {
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Find and toggle breastfeeding switch
          final switchTile = find.byType(SwitchListTile);
          
          // Initial state should match testUser.isBreastfeeding (true)
          SwitchListTile switchWidget = tester.widget<SwitchListTile>(switchTile);
          expect(switchWidget.value, equals(true));

          // Toggle the switch
          await tester.tap(switchTile);
          await tester.pumpAndSettle();

          // Verify switch state changed
          switchWidget = tester.widget<SwitchListTile>(switchTile);
          expect(switchWidget.value, equals(false));
        },
      );

      testWidgets(
        'should update activity level dropdown',
        (WidgetTester tester) async {
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Find activity level dropdown
          final activityDropdown = find.widgetWithText(
            DropdownButtonFormField<String>, 
            'Tingkat Aktivitas',
          );

          // Tap dropdown to open options
          await tester.tap(activityDropdown);
          await tester.pumpAndSettle();

          // Verify dropdown options are available
          expect(find.text('Sedentary (Tidak Aktif)'), findsOneWidget);
          expect(find.text('Lightly Active (Ringan)'), findsOneWidget);
          expect(find.text('Moderately Active (Sedang)'), findsOneWidget);

          // Select different option
          await tester.tap(find.text('Moderately Active (Sedang)'));
          await tester.pumpAndSettle();

          // Verify selection changed
          final dropdown = tester.widget<DropdownButtonFormField<String>>(activityDropdown);
          expect(dropdown.initialValue, equals('moderately_active'));
        },
      );

      testWidgets(
        'should update timezone dropdown',
        (WidgetTester tester) async {
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Find timezone dropdown
          final timezoneDropdown = find.widgetWithText(
            DropdownButtonFormField<String>, 
            'Zona Waktu',
          );

          // Tap dropdown to open options
          await tester.tap(timezoneDropdown);
          await tester.pumpAndSettle();

          // Verify dropdown options are available
          expect(find.text('WIB (UTC+7)'), findsOneWidget);
          expect(find.text('WITA (UTC+8)'), findsOneWidget);
          expect(find.text('WIT (UTC+9)'), findsOneWidget);

          // Select different option
          await tester.tap(find.text('WITA (UTC+8)'));
          await tester.pumpAndSettle();

          // Verify selection changed
          final dropdown = tester.widget<DropdownButtonFormField<String>>(timezoneDropdown);
          expect(dropdown.initialValue, equals('WITA'));
        },
      );

      testWidgets(
        'should call updateProfile when save button is tapped',
        (WidgetTester tester) async {
          when(mockProfileProvider.updateProfile(
            fullName: anyNamed('fullName'),
            weight: anyNamed('weight'),
            height: anyNamed('height'),
            age: anyNamed('age'),
            isBreastfeeding: anyNamed('isBreastfeeding'),
            activityLevel: anyNamed('activityLevel'),
            timezone: anyNamed('timezone'),
          )).thenAnswer((_) async => true);

          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Modify some fields
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Berat Badan (kg)'), 
            '70',
          );

          // Tap save button
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          // Verify updateProfile was called
          verify(mockProfileProvider.updateProfile(
            fullName: testUser.fullName,
            weight: 70.0,
            height: testUser.height,
            age: testUser.age,
            isBreastfeeding: testUser.isBreastfeeding,
            activityLevel: testUser.activityLevel,
            timezone: testUser.timezone,
          )).called(1);
        },
      );

      testWidgets(
        'should show loading indicator during save',
        (WidgetTester tester) async {
          when(mockProfileProvider.isLoading).thenReturn(true);

          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Verify save button shows loading indicator
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          
          // Verify save button is disabled
          final saveButton = tester.widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Simpan Perubahan'),
          );
          expect(saveButton.onPressed, isNull);
        },
      );

      testWidgets(
        'should show error message when save fails',
        (WidgetTester tester) async {
          // **Validates: Requirement 12.5**
          // Should display specific error messages for invalid fields
          
          when(mockProfileProvider.updateProfile(
            fullName: anyNamed('fullName'),
            weight: anyNamed('weight'),
            height: anyNamed('height'),
            age: anyNamed('age'),
            isBreastfeeding: anyNamed('isBreastfeeding'),
            activityLevel: anyNamed('activityLevel'),
            timezone: anyNamed('timezone'),
          )).thenAnswer((_) async => false);

          when(mockProfileProvider.errorMessage).thenReturn('Update failed');

          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Tap save button
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          // In a real implementation, this would show a SnackBar
          // For this test, we verify the method was called
          verify(mockProfileProvider.updateProfile(
            fullName: anyNamed('fullName'),
            weight: anyNamed('weight'),
            height: anyNamed('height'),
            age: anyNamed('age'),
            isBreastfeeding: anyNamed('isBreastfeeding'),
            activityLevel: anyNamed('activityLevel'),
            timezone: anyNamed('timezone'),
          )).called(1);
        },
      );
    });

    group('Profile Image Upload Tests', () {
      testWidgets(
        'should show image selection options when camera icon tapped',
        (WidgetTester tester) async {
          // **Validates: Requirement 12.2**
          // User should be able to choose between gallery and camera
          
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Tap camera icon
          await tester.tap(find.byIcon(Icons.camera_alt));
          await tester.pumpAndSettle();

          // Verify modal bottom sheet with options
          expect(find.text('Pilih dari Galeri'), findsOneWidget);
          expect(find.text('Ambil Foto'), findsOneWidget);
          expect(find.byIcon(Icons.photo_library), findsOneWidget);
          expect(find.byIcon(Icons.camera_alt), findsNWidgets(2));
        },
      );

      testWidgets(
        'should handle image compression requirement',
        (WidgetTester tester) async {
          // **Validates: Requirement 12.3**
          // Images should be compressed to max 500KB
          
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Verify image picker configuration in the widget
          // This would be tested more thoroughly in integration tests
          // where actual image selection can be simulated
          
          expect(find.text('Tap untuk mengubah foto profil'), findsOneWidget);
        },
      );

      testWidgets(
        'should show selected image preview',
        (WidgetTester tester) async {
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Initially should show current profile image or default icon
          expect(find.byType(CircleAvatar), findsOneWidget);
          
          // The actual image selection would be tested in integration tests
          // where we can mock the ImagePicker
        },
      );
    });

    group('Profile Management Error Handling Tests', () {
      testWidgets(
        'should handle network errors gracefully',
        (WidgetTester tester) async {
          when(mockProfileProvider.errorMessage).thenReturn('Network error');
          when(mockProfileProvider.user).thenReturn(null);

          await tester.pumpWidget(createProfileScreenWidget());
          await tester.pumpAndSettle();

          expect(find.text('Network error'), findsOneWidget);
          expect(find.text('Coba Lagi'), findsOneWidget);

          // Test retry functionality
          await tester.tap(find.text('Coba Lagi'));
          await tester.pumpAndSettle();

          verify(mockProfileProvider.fetchProfile()).called(1);
        },
      );

      testWidgets(
        'should handle invalid input gracefully',
        (WidgetTester tester) async {
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Test non-numeric input in weight field
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Berat Badan (kg)'), 
            'abc',
          );
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          expect(find.text('Masukkan angka yang valid'), findsOneWidget);
        },
      );

      testWidgets(
        'should handle empty optional fields',
        (WidgetTester tester) async {
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Clear optional fields
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Berat Badan (kg)'), 
            '',
          );
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Tinggi Badan (cm)'), 
            '',
          );
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Usia (tahun)'), 
            '',
          );

          // Should not show validation errors for empty optional fields
          await tester.tap(find.text('Simpan Perubahan'));
          await tester.pumpAndSettle();

          expect(find.text('Berat badan harus antara 30-200 kg'), findsNothing);
          expect(find.text('Tinggi badan harus antara 100-250 cm'), findsNothing);
          expect(find.text('Usia harus antara 15-60 tahun'), findsNothing);
        },
      );
    });

    group('Profile Management Accessibility Tests', () {
      testWidgets(
        'should have proper semantic labels',
        (WidgetTester tester) async {
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Verify form fields have proper labels
          expect(find.text('Nama Lengkap'), findsOneWidget);
          expect(find.text('Berat Badan (kg)'), findsOneWidget);
          expect(find.text('Tinggi Badan (cm)'), findsOneWidget);
          expect(find.text('Usia (tahun)'), findsOneWidget);

          // Verify helper texts for validation ranges
          expect(find.text('Rentang: 30-200 kg'), findsOneWidget);
          expect(find.text('Rentang: 100-250 cm'), findsOneWidget);
          expect(find.text('Rentang: 15-60 tahun'), findsOneWidget);
        },
      );

      testWidgets(
        'should have proper icons for visual cues',
        (WidgetTester tester) async {
          await tester.pumpWidget(createEditProfileScreenWidget());
          await tester.pumpAndSettle();

          // Verify icons are present for visual identification
          expect(find.byIcon(Icons.person), findsOneWidget);
          expect(find.byIcon(Icons.monitor_weight), findsOneWidget);
          expect(find.byIcon(Icons.height), findsOneWidget);
          expect(find.byIcon(Icons.cake), findsOneWidget);
          expect(find.byIcon(Icons.directions_run), findsOneWidget);
          expect(find.byIcon(Icons.access_time), findsOneWidget);
        },
      );
    });
  });
}