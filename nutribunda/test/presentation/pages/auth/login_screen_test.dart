import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:nutribunda/presentation/pages/auth/login_screen.dart';
import 'package:nutribunda/presentation/providers/auth_provider.dart';
import 'package:nutribunda/core/services/http_client_service.dart';
import 'package:nutribunda/core/services/secure_storage_service.dart';
import 'package:nutribunda/core/services/biometric_service.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([HttpClientService, SecureStorageService, BiometricService])
void main() {
  late MockHttpClientService mockHttpClient;
  late MockSecureStorageService mockSecureStorage;
  late MockBiometricService mockBiometricService;
  late AuthProvider authProvider;

  setUp(() {
    mockHttpClient = MockHttpClientService();
    mockSecureStorage = MockSecureStorageService();
    mockBiometricService = MockBiometricService();
    authProvider = AuthProvider(
      httpClient: mockHttpClient,
      secureStorage: mockSecureStorage,
      biometricService: mockBiometricService,
    );
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('should display all UI elements', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify UI elements
      expect(find.byIcon(Icons.child_care), findsOneWidget);
      expect(find.text('NutriBunda'), findsOneWidget);
      expect(find.text('Asisten Gizi MPASI & Diet Ibu'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.text('Belum punya akun? '), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);
    });

    testWidgets('should show error when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap the login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify error message
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should show error when password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter email only
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify error message
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should show error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');

      // Enter password
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'Test1234');

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify error message
      expect(find.text('Format email tidak valid'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the visibility toggle button (initially should show visibility icon)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap the visibility toggle button
      final visibilityButton = find.byIcon(Icons.visibility_outlined);
      await tester.tap(visibilityButton);
      await tester.pump();

      // Now should show visibility_off icon
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap again to hide
      final visibilityOffButton = find.byIcon(Icons.visibility_off_outlined);
      await tester.tap(visibilityOffButton);
      await tester.pump();

      // Should show visibility icon again
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('should navigate to register screen when Daftar is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap the Daftar button
      final daftarButton = find.widgetWithText(TextButton, 'Daftar');
      await tester.tap(daftarButton);
      await tester.pumpAndSettle();

      // Verify navigation to register screen
      expect(find.text('Daftar Akun'), findsOneWidget);
      expect(find.text('Buat Akun Baru'), findsOneWidget);
    });

    testWidgets('should show loading indicator during login',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid credentials
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'Test1234');

      // Mock a delayed response
      when(mockHttpClient.post(any, data: anyNamed('data')))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        throw Exception('Test error');
      });

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');
      await tester.tap(loginButton);
      await tester.pump(const Duration(milliseconds: 50));

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for the async operation to complete
      await tester.pumpAndSettle();
    });
  });
}
