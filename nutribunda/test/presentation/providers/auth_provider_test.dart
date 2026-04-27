import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:nutribunda/presentation/providers/auth_provider.dart';
import 'package:nutribunda/core/services/http_client_service.dart';
import 'package:nutribunda/core/services/secure_storage_service.dart';
import 'package:nutribunda/core/services/biometric_service.dart';
import 'package:nutribunda/core/errors/exceptions.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([HttpClientService, SecureStorageService, BiometricService])
void main() {
  late AuthProvider authProvider;
  late MockHttpClientService mockHttpClient;
  late MockSecureStorageService mockSecureStorage;
  late MockBiometricService mockBiometricService;

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

  group('AuthProvider - Login', () {
    const testEmail = 'test@example.com';
    const testPassword = 'Test1234';
    const testToken = 'test_jwt_token';
    final testUserData = {
      'id': '123',
      'email': testEmail,
      'full_name': 'Test User',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    test('should successfully login with valid credentials', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        statusCode: 200,
        data: {
          'token': testToken,
          'user': testUserData,
        },
      );

      when(mockHttpClient.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => response);
      when(mockSecureStorage.saveAccessToken(any))
          .thenAnswer((_) async => Future.value());
      when(mockSecureStorage.saveUserEmail(any))
          .thenAnswer((_) async => Future.value());
      when(mockSecureStorage.saveUserId(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await authProvider.login(testEmail, testPassword);

      // Assert
      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.token, testToken);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.email, testEmail);
      expect(authProvider.errorMessage, isNull);

      verify(mockSecureStorage.saveAccessToken(testToken)).called(1);
      verify(mockSecureStorage.saveUserEmail(testEmail)).called(1);
    });

    test('should fail login with empty email', () async {
      // Act
      final result = await authProvider.login('', testPassword);

      // Assert
      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, 'Email dan password tidak boleh kosong');
      verifyNever(mockHttpClient.post(any, data: anyNamed('data')));
    });

    test('should fail login with invalid email format', () async {
      // Act
      final result = await authProvider.login('invalid-email', testPassword);

      // Assert
      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, 'Format email tidak valid');
      verifyNever(mockHttpClient.post(any, data: anyNamed('data')));
    });

    test('should fail login with wrong credentials (401)', () async {
      // Arrange
      when(mockHttpClient.post(any, data: anyNamed('data')))
          .thenThrow(UnauthorizedException('Invalid credentials'));

      // Act
      final result = await authProvider.login(testEmail, testPassword);

      // Assert
      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, 'Email atau password salah');
    });

    test('should fail login with network error', () async {
      // Arrange
      when(mockHttpClient.post(any, data: anyNamed('data')))
          .thenThrow(NetworkException('No internet connection'));

      // Act
      final result = await authProvider.login(testEmail, testPassword);

      // Assert
      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, contains('koneksi internet'));
    });
  });

  group('AuthProvider - Register', () {
    const testFullName = 'Test User';
    const testEmail = 'test@example.com';
    const testPassword = 'Test1234';
    const testToken = 'test_jwt_token';
    final testUserData = {
      'id': '123',
      'email': testEmail,
      'full_name': testFullName,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    test('should successfully register with valid data', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/auth/register'),
        statusCode: 201,
        data: {
          'token': testToken,
          'user': testUserData,
        },
      );

      when(mockHttpClient.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => response);
      when(mockSecureStorage.saveAccessToken(any))
          .thenAnswer((_) async => Future.value());
      when(mockSecureStorage.saveUserEmail(any))
          .thenAnswer((_) async => Future.value());
      when(mockSecureStorage.saveUserId(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await authProvider.register(
        testFullName,
        testEmail,
        testPassword,
      );

      // Assert
      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.token, testToken);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.fullName, testFullName);
      expect(authProvider.errorMessage, isNull);
    });

    test('should fail register with empty fields', () async {
      // Act
      final result = await authProvider.register('', '', '');

      // Assert
      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, 'Semua field harus diisi');
      verifyNever(mockHttpClient.post(any, data: anyNamed('data')));
    });

    test('should fail register with weak password (no uppercase)', () async {
      // Act
      final result = await authProvider.register(
        testFullName,
        testEmail,
        'test1234', // No uppercase
      );

      // Assert
      expect(result, false);
      expect(authProvider.errorMessage, contains('huruf besar'));
      verifyNever(mockHttpClient.post(any, data: anyNamed('data')));
    });

    test('should fail register with weak password (no number)', () async {
      // Act
      final result = await authProvider.register(
        testFullName,
        testEmail,
        'TestTest', // No number
      );

      // Assert
      expect(result, false);
      expect(authProvider.errorMessage, contains('angka'));
      verifyNever(mockHttpClient.post(any, data: anyNamed('data')));
    });

    test('should fail register with short password', () async {
      // Act
      final result = await authProvider.register(
        testFullName,
        testEmail,
        'Test12', // Too short
      );

      // Assert
      expect(result, false);
      expect(authProvider.errorMessage, contains('minimal 8 karakter'));
      verifyNever(mockHttpClient.post(any, data: anyNamed('data')));
    });

    test('should fail register with existing email (409)', () async {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/register'),
          statusCode: 409,
          data: {'message': 'Email already exists'},
        ),
      );

      when(mockHttpClient.post(any, data: anyNamed('data')))
          .thenThrow(dioError);

      // Act
      final result = await authProvider.register(
        testFullName,
        testEmail,
        testPassword,
      );

      // Assert
      expect(result, false);
      expect(authProvider.errorMessage, 'Email sudah terdaftar');
    });
  });

  group('AuthProvider - Logout', () {
    test('should successfully logout and clear storage', () async {
      // Arrange
      when(mockHttpClient.post(any)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/logout'),
          statusCode: 200,
        ),
      );
      when(mockSecureStorage.deleteTokens())
          .thenAnswer((_) async => Future.value());
      when(mockSecureStorage.clearAll())
          .thenAnswer((_) async => Future.value());

      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, isNull);
      expect(authProvider.token, isNull);
      verify(mockSecureStorage.deleteTokens()).called(1);
      verify(mockSecureStorage.clearAll()).called(1);
    });

    test('should logout even if API call fails', () async {
      // Arrange
      when(mockHttpClient.post(any))
          .thenThrow(NetworkException('Network error'));
      when(mockSecureStorage.deleteTokens())
          .thenAnswer((_) async => Future.value());
      when(mockSecureStorage.clearAll())
          .thenAnswer((_) async => Future.value());

      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, isNull);
      expect(authProvider.token, isNull);
      verify(mockSecureStorage.deleteTokens()).called(1);
      verify(mockSecureStorage.clearAll()).called(1);
    });
  });

  group('AuthProvider - Error Handling', () {
    test('should clear error message', () {
      // Arrange
      authProvider.login('', ''); // This will set an error

      // Act
      authProvider.clearError();

      // Assert
      expect(authProvider.errorMessage, isNull);
    });
  });
}
