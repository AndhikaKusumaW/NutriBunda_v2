import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:nutribunda/core/services/http_client_service.dart';
import 'package:nutribunda/presentation/providers/food_diary_provider.dart';
import 'package:nutribunda/data/models/diary_entry.dart';
import 'package:nutribunda/data/models/nutrition_summary.dart';

import 'food_diary_provider_test.mocks.dart';

@GenerateMocks([HttpClientService])
void main() {
  late FoodDiaryProvider provider;
  late MockHttpClientService mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClientService();
    provider = FoodDiaryProvider(httpClient: mockHttpClient);
  });

  group('FoodDiaryProvider', () {
    test('initial state should be correct', () {
      expect(provider.entries, isEmpty);
      expect(provider.nutritionSummary, const NutritionSummary());
      expect(provider.selectedProfile, 'baby');
      expect(provider.isLoading, false);
      expect(provider.errorMessage, null);
    });

    test('setSelectedProfile should update profile and trigger loadEntries', () {
      // Arrange
      when(mockHttpClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: {
              'entries': [],
              'nutrition_summary': {
                'calories': 0.0,
                'protein': 0.0,
                'carbs': 0.0,
                'fat': 0.0,
              },
            },
          ));

      // Act
      provider.setSelectedProfile('mother');

      // Assert
      expect(provider.selectedProfile, 'mother');
    });

    test('setSelectedProfile should not update with invalid profile', () {
      // Act
      provider.setSelectedProfile('invalid');

      // Assert
      expect(provider.selectedProfile, 'baby'); // Should remain unchanged
      expect(provider.errorMessage, 'Invalid profile type');
    });

    test('loadEntries should update entries and nutrition summary on success', () async {
      // Arrange
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'entries': [
            {
              'id': '1',
              'user_id': 'user1',
              'profile_type': 'baby',
              'food_id': 'food1',
              'serving_size': 100.0,
              'meal_time': 'breakfast',
              'calories': 150.0,
              'protein': 5.0,
              'carbs': 20.0,
              'fat': 3.0,
              'entry_date': '2024-01-01',
              'created_at': '2024-01-01T10:00:00Z',
              'updated_at': '2024-01-01T10:00:00Z',
            },
          ],
          'nutrition_summary': {
            'calories': 150.0,
            'protein': 5.0,
            'carbs': 20.0,
            'fat': 3.0,
          },
        },
      );

      when(mockHttpClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      await provider.loadEntries();

      // Assert
      expect(provider.entries.length, 1);
      expect(provider.entries[0].id, '1');
      expect(provider.nutritionSummary.calories, 150.0);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, null);
    });

    test('entriesByMealTime should group entries correctly', () async {
      // Arrange
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'entries': [
            {
              'id': '1',
              'user_id': 'user1',
              'profile_type': 'baby',
              'serving_size': 100.0,
              'meal_time': 'breakfast',
              'calories': 150.0,
              'protein': 5.0,
              'carbs': 20.0,
              'fat': 3.0,
              'entry_date': '2024-01-01',
              'created_at': '2024-01-01T10:00:00Z',
              'updated_at': '2024-01-01T10:00:00Z',
            },
            {
              'id': '2',
              'user_id': 'user1',
              'profile_type': 'baby',
              'serving_size': 100.0,
              'meal_time': 'lunch',
              'calories': 200.0,
              'protein': 8.0,
              'carbs': 25.0,
              'fat': 5.0,
              'entry_date': '2024-01-01',
              'created_at': '2024-01-01T12:00:00Z',
              'updated_at': '2024-01-01T12:00:00Z',
            },
          ],
          'nutrition_summary': {
            'calories': 350.0,
            'protein': 13.0,
            'carbs': 45.0,
            'fat': 8.0,
          },
        },
      );

      when(mockHttpClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      await provider.loadEntries();
      final grouped = provider.entriesByMealTime;

      // Assert
      expect(grouped['breakfast']!.length, 1);
      expect(grouped['lunch']!.length, 1);
      expect(grouped['dinner']!.length, 0);
      expect(grouped['snack']!.length, 0);
    });

    test('clearError should clear error message', () {
      // Arrange
      provider.setSelectedProfile('invalid'); // This sets an error

      // Act
      provider.clearError();

      // Assert
      expect(provider.errorMessage, null);
    });
  });
}
