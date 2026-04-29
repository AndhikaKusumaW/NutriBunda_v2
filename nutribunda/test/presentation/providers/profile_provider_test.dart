import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:nutribunda/presentation/providers/profile_provider.dart';
import 'package:nutribunda/core/services/http_client_service.dart';
import 'package:nutribunda/data/models/user_model.dart';
import 'package:nutribunda/core/errors/exceptions.dart';

@GenerateMocks([HttpClientService])
import 'profile_provider_test.mocks.dart';

void main() {
  late ProfileProvider profileProvider;
  late MockHttpClientService mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClientService();
    profileProvider = ProfileProvider(httpClient: mockHttpClient);
  });

  group('ProfileProvider - fetchProfile', () {
    final testUser = UserModel(
      id: '1',
      email: 'test@example.com',
      fullName: 'Test User',
      weight: 60.0,
      height: 165.0,
      age: 30,
      isBreastfeeding: true,
      activityLevel: 'sedentary',
      timezone: 'WIB',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should fetch profile successfully', () async {
      // Arrange
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/profile'),
          statusCode: 200,
          data: {
            'user': testUser.toJson(),
          },
        ),
      );

      // Act
      final result = await profileProvider.fetchProfile();

      // Assert
      expect(result, true);
      expect(profileProvider.user, isNotNull);
      expect(profileProvider.user!.email, testUser.email);
      expect(profileProvider.errorMessage, isNull);
      expect(profileProvider.isLoading, false);
    });

    test('should handle network error when fetching profile', () async {
      // Arrange
      when(mockHttpClient.get(any)).thenThrow(
        NetworkException('No internet connection'),
      );

      // Act
      final result = await profileProvider.fetchProfile();

      // Assert
      expect(result, false);
      expect(profileProvider.user, isNull);
      expect(profileProvider.errorMessage, 'No internet connection');
      expect(profileProvider.isLoading, false);
    });

    test('should handle unauthorized error when fetching profile', () async {
      // Arrange
      when(mockHttpClient.get(any)).thenThrow(
        UnauthorizedException('Unauthorized'),
      );

      // Act
      final result = await profileProvider.fetchProfile();

      // Assert
      expect(result, false);
      expect(profileProvider.user, isNull);
      expect(profileProvider.errorMessage, 'Unauthorized');
      expect(profileProvider.isLoading, false);
    });
  });

  group('ProfileProvider - updateProfile', () {
    final updatedUser = UserModel(
      id: '1',
      email: 'test@example.com',
      fullName: 'Updated User',
      weight: 65.0,
      height: 170.0,
      age: 31,
      isBreastfeeding: false,
      activityLevel: 'lightly_active',
      timezone: 'WITA',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should update profile successfully', () async {
      // Arrange
      when(mockHttpClient.put(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/profile'),
          statusCode: 200,
          data: {
            'user': updatedUser.toJson(),
          },
        ),
      );

      // Act
      final result = await profileProvider.updateProfile(
        fullName: 'Updated User',
        weight: 65.0,
        height: 170.0,
        age: 31,
        isBreastfeeding: false,
        activityLevel: 'lightly_active',
        timezone: 'WITA',
      );

      // Assert
      expect(result, true);
      expect(profileProvider.user, isNotNull);
      expect(profileProvider.user!.fullName, 'Updated User');
      expect(profileProvider.user!.weight, 65.0);
      expect(profileProvider.errorMessage, isNull);
      expect(profileProvider.isLoading, false);
    });

    test('should validate weight range (30-200 kg)', () async {
      // Act - Test below minimum
      var result = await profileProvider.updateProfile(weight: 25.0);

      // Assert
      expect(result, false);
      expect(profileProvider.errorMessage, 'Berat badan harus antara 30-200 kg');

      // Act - Test above maximum
      result = await profileProvider.updateProfile(weight: 205.0);

      // Assert
      expect(result, false);
      expect(profileProvider.errorMessage, 'Berat badan harus antara 30-200 kg');

      // Act - Test valid weight
      when(mockHttpClient.put(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/profile'),
          statusCode: 200,
          data: {
            'user': {
              'id': '1',
              'email': 'test@example.com',
              'full_name': 'Test User',
              'weight': 60.0,
              'height': 165.0,
              'age': 30,
              'is_breastfeeding': false,
              'activity_level': 'sedentary',
              'timezone': 'WIB',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            },
          },
        ),
      );

      result = await profileProvider.updateProfile(weight: 60.0);

      // Assert
      expect(result, true);
      expect(profileProvider.errorMessage, isNull);
    });

    test('should validate height range (100-250 cm)', () async {
      // Act - Test below minimum
      var result = await profileProvider.updateProfile(height: 95.0);

      // Assert
      expect(result, false);
      expect(profileProvider.errorMessage, 'Tinggi badan harus antara 100-250 cm');

      // Act - Test above maximum
      result = await profileProvider.updateProfile(height: 255.0);

      // Assert
      expect(result, false);
      expect(profileProvider.errorMessage, 'Tinggi badan harus antara 100-250 cm');

      // Act - Test valid height
      when(mockHttpClient.put(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/profile'),
          statusCode: 200,
          data: {
            'user': {
              'id': '1',
              'email': 'test@example.com',
              'full_name': 'Test User',
              'weight': 60.0,
              'height': 165.0,
              'age': 30,
              'is_breastfeeding': false,
              'activity_level': 'sedentary',
              'timezone': 'WIB',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            },
          },
        ),
      );

      result = await profileProvider.updateProfile(height: 165.0);

      // Assert
      expect(result, true);
      expect(profileProvider.errorMessage, isNull);
    });

    test('should validate age range (15-60 years)', () async {
      // Act - Test below minimum
      var result = await profileProvider.updateProfile(age: 14);

      // Assert
      expect(result, false);
      expect(profileProvider.errorMessage, 'Usia harus antara 15-60 tahun');

      // Act - Test above maximum
      result = await profileProvider.updateProfile(age: 61);

      // Assert
      expect(result, false);
      expect(profileProvider.errorMessage, 'Usia harus antara 15-60 tahun');
    });

    test('should handle validation error from server', () async {
      // Arrange
      when(mockHttpClient.put(any, data: anyNamed('data'))).thenThrow(
        ValidationException('Invalid data'),
      );

      // Act
      final result = await profileProvider.updateProfile(fullName: 'Test');

      // Assert
      expect(result, false);
      expect(profileProvider.errorMessage, 'Invalid data');
      expect(profileProvider.isLoading, false);
    });

    test('should handle network error when updating profile', () async {
      // Arrange
      when(mockHttpClient.put(any, data: anyNamed('data'))).thenThrow(
        NetworkException('No internet connection'),
      );

      // Act
      final result = await profileProvider.updateProfile(fullName: 'Test');

      // Assert
      expect(result, false);
      expect(profileProvider.errorMessage, 'No internet connection');
      expect(profileProvider.isLoading, false);
    });
  });

  group('ProfileProvider - uploadProfileImage', () {
    test('should handle upload error', () async {
      // Arrange
      final testFile = File('test_image.jpg');
      when(mockHttpClient.uploadFile(
        any,
        filePath: anyNamed('filePath'),
        fieldName: anyNamed('fieldName'),
      )).thenThrow(
        NetworkException('Upload failed'),
      );

      // Act
      final result = await profileProvider.uploadProfileImage(testFile);

      // Assert
      expect(result, false);
      expect(profileProvider.errorMessage, 'Upload failed');
      expect(profileProvider.isLoading, false);
    });
  });

  group('ProfileProvider - utility methods', () {
    test('should clear error message', () {
      // Arrange
      profileProvider.updateProfile(weight: 25.0); // This will set error

      // Act
      profileProvider.clearError();

      // Assert
      expect(profileProvider.errorMessage, isNull);
    });

    test('should set user data', () {
      // Arrange
      final testUser = UserModel(
        id: '1',
        email: 'test@example.com',
        fullName: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      profileProvider.setUser(testUser);

      // Assert
      expect(profileProvider.user, testUser);
    });

    test('should clear user data', () {
      // Arrange
      final testUser = UserModel(
        id: '1',
        email: 'test@example.com',
        fullName: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      profileProvider.setUser(testUser);

      // Act
      profileProvider.clearUser();

      // Assert
      expect(profileProvider.user, isNull);
      expect(profileProvider.errorMessage, isNull);
    });
  });
}
