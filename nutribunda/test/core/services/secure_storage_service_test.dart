import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nutribunda/core/services/secure_storage_service.dart';

@GenerateMocks([FlutterSecureStorage])
import 'secure_storage_service_test.mocks.dart';

void main() {
  late SecureStorageService secureStorageService;
  late MockFlutterSecureStorage mockFlutterSecureStorage;

  setUp(() {
    mockFlutterSecureStorage = MockFlutterSecureStorage();
    secureStorageService = SecureStorageService(
      secureStorage: mockFlutterSecureStorage,
    );
  });

  group('Token Management', () {
    const testAccessToken = 'test_access_token_123';
    const testRefreshToken = 'test_refresh_token_456';

    test('saveAccessToken should save token to secure storage', () async {
      // Arrange
      when(mockFlutterSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      // Act
      await secureStorageService.saveAccessToken(testAccessToken);

      // Assert
      verify(mockFlutterSecureStorage.write(
        key: 'access_token',
        value: testAccessToken,
      )).called(1);
    });

    test('getAccessToken should return token from secure storage', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => testAccessToken);

      // Act
      final result = await secureStorageService.getAccessToken();

      // Assert
      expect(result, testAccessToken);
      verify(mockFlutterSecureStorage.read(key: 'access_token')).called(1);
    });

    test('getAccessToken should return null when no token exists', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);

      // Act
      final result = await secureStorageService.getAccessToken();

      // Assert
      expect(result, null);
    });

    test('saveRefreshToken should save refresh token to secure storage',
        () async {
      // Arrange
      when(mockFlutterSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      // Act
      await secureStorageService.saveRefreshToken(testRefreshToken);

      // Assert
      verify(mockFlutterSecureStorage.write(
        key: 'refresh_token',
        value: testRefreshToken,
      )).called(1);
    });

    test('getRefreshToken should return refresh token from secure storage',
        () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => testRefreshToken);

      // Act
      final result = await secureStorageService.getRefreshToken();

      // Assert
      expect(result, testRefreshToken);
      verify(mockFlutterSecureStorage.read(key: 'refresh_token')).called(1);
    });

    test('deleteTokens should delete both access and refresh tokens',
        () async {
      // Arrange
      when(mockFlutterSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      // Act
      await secureStorageService.deleteTokens();

      // Assert
      verify(mockFlutterSecureStorage.delete(key: 'access_token')).called(1);
      verify(mockFlutterSecureStorage.delete(key: 'refresh_token')).called(1);
    });

    test('hasValidToken should return true when token exists', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => testAccessToken);

      // Act
      final result = await secureStorageService.hasValidToken();

      // Assert
      expect(result, true);
    });

    test('hasValidToken should return false when token is null', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);

      // Act
      final result = await secureStorageService.hasValidToken();

      // Assert
      expect(result, false);
    });

    test('hasValidToken should return false when token is empty', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => '');

      // Act
      final result = await secureStorageService.hasValidToken();

      // Assert
      expect(result, false);
    });
  });

  group('User Data Management', () {
    const testUserId = 'user_123';
    const testUserEmail = 'test@example.com';

    test('saveUserId should save user ID to secure storage', () async {
      // Arrange
      when(mockFlutterSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      // Act
      await secureStorageService.saveUserId(testUserId);

      // Assert
      verify(mockFlutterSecureStorage.write(
        key: 'user_id',
        value: testUserId,
      )).called(1);
    });

    test('getUserId should return user ID from secure storage', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => testUserId);

      // Act
      final result = await secureStorageService.getUserId();

      // Assert
      expect(result, testUserId);
      verify(mockFlutterSecureStorage.read(key: 'user_id')).called(1);
    });

    test('saveUserEmail should save user email to secure storage', () async {
      // Arrange
      when(mockFlutterSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      // Act
      await secureStorageService.saveUserEmail(testUserEmail);

      // Assert
      verify(mockFlutterSecureStorage.write(
        key: 'user_email',
        value: testUserEmail,
      )).called(1);
    });

    test('getUserEmail should return user email from secure storage',
        () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => testUserEmail);

      // Act
      final result = await secureStorageService.getUserEmail();

      // Assert
      expect(result, testUserEmail);
      verify(mockFlutterSecureStorage.read(key: 'user_email')).called(1);
    });
  });

  group('Biometric Settings', () {
    test('setBiometricEnabled should save biometric setting as true',
        () async {
      // Arrange
      when(mockFlutterSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      // Act
      await secureStorageService.setBiometricEnabled(true);

      // Assert
      verify(mockFlutterSecureStorage.write(
        key: 'biometric_enabled',
        value: 'true',
      )).called(1);
    });

    test('setBiometricEnabled should save biometric setting as false',
        () async {
      // Arrange
      when(mockFlutterSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      // Act
      await secureStorageService.setBiometricEnabled(false);

      // Assert
      verify(mockFlutterSecureStorage.write(
        key: 'biometric_enabled',
        value: 'false',
      )).called(1);
    });

    test('isBiometricEnabled should return true when enabled', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'true');

      // Act
      final result = await secureStorageService.isBiometricEnabled();

      // Assert
      expect(result, true);
    });

    test('isBiometricEnabled should return false when disabled', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'false');

      // Act
      final result = await secureStorageService.isBiometricEnabled();

      // Assert
      expect(result, false);
    });

    test('isBiometricEnabled should return false when not set', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);

      // Act
      final result = await secureStorageService.isBiometricEnabled();

      // Assert
      expect(result, false);
    });
  });

  group('Clear All Data', () {
    test('clearAll should delete all data from secure storage', () async {
      // Arrange
      when(mockFlutterSecureStorage.deleteAll()).thenAnswer((_) async => {});

      // Act
      await secureStorageService.clearAll();

      // Assert
      verify(mockFlutterSecureStorage.deleteAll()).called(1);
    });
  });

  group('Utility Methods', () {
    const testKey = 'test_key';
    const testValue = 'test_value';

    test('write should save custom data to secure storage', () async {
      // Arrange
      when(mockFlutterSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      // Act
      await secureStorageService.write(testKey, testValue);

      // Assert
      verify(mockFlutterSecureStorage.write(
        key: testKey,
        value: testValue,
      )).called(1);
    });

    test('read should return custom data from secure storage', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => testValue);

      // Act
      final result = await secureStorageService.read(testKey);

      // Assert
      expect(result, testValue);
      verify(mockFlutterSecureStorage.read(key: testKey)).called(1);
    });

    test('delete should remove custom data from secure storage', () async {
      // Arrange
      when(mockFlutterSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      // Act
      await secureStorageService.delete(testKey);

      // Assert
      verify(mockFlutterSecureStorage.delete(key: testKey)).called(1);
    });

    test('containsKey should return true when key exists', () async {
      // Arrange
      when(mockFlutterSecureStorage.containsKey(key: anyNamed('key')))
          .thenAnswer((_) async => true);

      // Act
      final result = await secureStorageService.containsKey(testKey);

      // Assert
      expect(result, true);
      verify(mockFlutterSecureStorage.containsKey(key: testKey)).called(1);
    });

    test('containsKey should return false when key does not exist', () async {
      // Arrange
      when(mockFlutterSecureStorage.containsKey(key: anyNamed('key')))
          .thenAnswer((_) async => false);

      // Act
      final result = await secureStorageService.containsKey(testKey);

      // Assert
      expect(result, false);
    });

    test('readAll should return all data from secure storage', () async {
      // Arrange
      final testData = {
        'key1': 'value1',
        'key2': 'value2',
      };
      when(mockFlutterSecureStorage.readAll())
          .thenAnswer((_) async => testData);

      // Act
      final result = await secureStorageService.readAll();

      // Assert
      expect(result, testData);
      verify(mockFlutterSecureStorage.readAll()).called(1);
    });
  });

  group('Error Handling', () {
    test('saveAccessToken should throw exception on error', () async {
      // Arrange
      when(mockFlutterSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(
        () => secureStorageService.saveAccessToken('token'),
        throwsException,
      );
    });

    test('getAccessToken should throw exception on error', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(
        () => secureStorageService.getAccessToken(),
        throwsException,
      );
    });

    test('hasValidToken should return false on error', () async {
      // Arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenThrow(Exception('Storage error'));

      // Act
      final result = await secureStorageService.hasValidToken();

      // Assert
      expect(result, false);
    });
  });
}
