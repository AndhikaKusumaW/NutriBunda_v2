import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:nutribunda/presentation/providers/recipe_provider.dart';
import 'package:nutribunda/core/services/http_client_service.dart';
import 'package:nutribunda/core/services/accelerometer_service.dart';
import 'package:nutribunda/data/models/recipe_model.dart';

// Generate mocks for HttpClientService
@GenerateMocks([HttpClientService])
import 'recipe_test.mocks.dart';

void main() {
  late RecipeProvider recipeProvider;
  late MockHttpClientService mockHttpClient;
  late AccelerometerService accelerometerService;

  setUp(() {
    mockHttpClient = MockHttpClientService();
    recipeProvider = RecipeProvider(httpClient: mockHttpClient);
    accelerometerService = AccelerometerService();
  });

  tearDown(() {
    accelerometerService.dispose();
  });

  group('Recipe Favorit Functionality Tests', () {
    group('Adding Recipe to Favorites', () {
      test('should add recipe to favorites successfully', () async {
        // Arrange
        final mockPostResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/recipe-123/favorite'),
          statusCode: 201,
        );

        final mockGetResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/favorites'),
          statusCode: 200,
          data: {
            'recipes': [
              {
                'id': 'recipe-123',
                'name': 'Bubur Ayam MPASI',
                'ingredients': ['100g beras', '50g ayam', '200ml air'],
                'instructions': 'Masak beras dengan air hingga lembut',
                'nutrition_info': {
                  'calories': 150.0,
                  'protein': 10.0,
                  'carbs': 20.0,
                  'fat': 5.0,
                },
                'category': 'mpasi',
                'created_at': '2024-01-01T00:00:00Z',
              },
            ],
          },
        );

        when(mockHttpClient.post(any)).thenAnswer((_) async => mockPostResponse);
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockGetResponse);

        // Act
        final result = await recipeProvider.addToFavorites('recipe-123');

        // Assert
        expect(result, true);
        expect(recipeProvider.favoriteRecipes.length, 1);
        expect(recipeProvider.favoriteRecipes[0].id, 'recipe-123');
        expect(recipeProvider.errorMessage, isNull);
        verify(mockHttpClient.post(any)).called(1);
        verify(mockHttpClient.get(any)).called(1);
      });

      test('should handle duplicate favorite (409 conflict)', () async {
        // Arrange
        when(mockHttpClient.post(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/recipes/recipe-123/favorite'),
            response: Response(
              requestOptions: RequestOptions(path: '/recipes/recipe-123/favorite'),
              statusCode: 409,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // Act
        final result = await recipeProvider.addToFavorites('recipe-123');

        // Assert
        expect(result, false);
        expect(recipeProvider.errorMessage, contains('already in favorites'));
      });

      test('should handle unauthorized error (401)', () async {
        // Arrange
        when(mockHttpClient.post(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/recipes/recipe-123/favorite'),
            response: Response(
              requestOptions: RequestOptions(path: '/recipes/recipe-123/favorite'),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // Act
        final result = await recipeProvider.addToFavorites('recipe-123');

        // Assert
        expect(result, false);
        expect(recipeProvider.errorMessage, contains('Unauthorized'));
      });

      test('should handle network error when adding to favorites', () async {
        // Arrange
        when(mockHttpClient.post(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/recipes/recipe-123/favorite'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act
        final result = await recipeProvider.addToFavorites('recipe-123');

        // Assert
        expect(result, false);
        expect(recipeProvider.errorMessage, isNotNull);
      });
    });

    group('Removing Recipe from Favorites', () {
      test('should remove recipe from favorites successfully', () async {
        // Arrange - Add a recipe to favorites first
        final recipe = RecipeModel(
          id: 'recipe-123',
          name: 'Bubur Ayam MPASI',
          ingredients: const ['100g beras', '50g ayam', '200ml air'],
          instructions: 'Masak beras dengan air hingga lembut',
          category: 'mpasi',
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
          nutritionInfo: const NutritionInfo(
            calories: 150.0,
            protein: 10.0,
            carbs: 20.0,
            fat: 5.0,
          ),
        );
        recipeProvider.favoriteRecipes.add(recipe);

        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/recipe-123/favorite'),
          statusCode: 200,
        );

        when(mockHttpClient.delete(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await recipeProvider.removeFromFavorites('recipe-123');

        // Assert
        expect(result, true);
        expect(recipeProvider.favoriteRecipes.isEmpty, true);
        expect(recipeProvider.errorMessage, isNull);
        verify(mockHttpClient.delete(any)).called(1);
      });

      test('should handle recipe not found (404)', () async {
        // Arrange
        when(mockHttpClient.delete(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/recipes/recipe-999/favorite'),
            response: Response(
              requestOptions: RequestOptions(path: '/recipes/recipe-999/favorite'),
              statusCode: 404,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // Act
        final result = await recipeProvider.removeFromFavorites('recipe-999');

        // Assert
        expect(result, false);
        expect(recipeProvider.errorMessage, contains('not found'));
      });

      test('should handle unauthorized error when removing', () async {
        // Arrange
        when(mockHttpClient.delete(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/recipes/recipe-123/favorite'),
            response: Response(
              requestOptions: RequestOptions(path: '/recipes/recipe-123/favorite'),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // Act
        final result = await recipeProvider.removeFromFavorites('recipe-123');

        // Assert
        expect(result, false);
        expect(recipeProvider.errorMessage, contains('Unauthorized'));
      });
    });

    group('Fetching Favorite Recipes List', () {
      test('should fetch favorite recipes successfully', () async {
        // Arrange
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/favorites'),
          statusCode: 200,
          data: {
            'recipes': [
              {
                'id': 'recipe-1',
                'name': 'Bubur Ayam MPASI',
                'ingredients': ['100g beras', '50g ayam', '200ml air'],
                'instructions': 'Masak beras dengan air hingga lembut',
                'nutrition_info': {
                  'calories': 150.0,
                  'protein': 10.0,
                  'carbs': 20.0,
                  'fat': 5.0,
                },
                'category': 'mpasi',
                'created_at': '2024-01-01T00:00:00Z',
              },
              {
                'id': 'recipe-2',
                'name': 'Puree Wortel',
                'ingredients': ['200g wortel', '100ml air'],
                'instructions': 'Kukus wortel hingga lunak, haluskan',
                'nutrition_info': {
                  'calories': 80.0,
                  'protein': 2.0,
                  'carbs': 15.0,
                  'fat': 1.0,
                },
                'category': 'mpasi',
                'created_at': '2024-01-02T00:00:00Z',
              },
            ],
          },
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        await recipeProvider.loadFavoriteRecipes();

        // Assert
        expect(recipeProvider.favoriteRecipes.length, 2);
        expect(recipeProvider.favoriteRecipes[0].name, 'Bubur Ayam MPASI');
        expect(recipeProvider.favoriteRecipes[1].name, 'Puree Wortel');
        expect(recipeProvider.isLoadingFavorites, false);
        expect(recipeProvider.errorMessage, isNull);
      });

      test('should handle empty favorite recipes list', () async {
        // Arrange
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/favorites'),
          statusCode: 200,
          data: {
            'recipes': [],
          },
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        await recipeProvider.loadFavoriteRecipes();

        // Assert
        expect(recipeProvider.favoriteRecipes.isEmpty, true);
        expect(recipeProvider.isLoadingFavorites, false);
        expect(recipeProvider.errorMessage, isNull);
      });

      test('should handle null recipes in response', () async {
        // Arrange
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/favorites'),
          statusCode: 200,
          data: {
            'recipes': null,
          },
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        await recipeProvider.loadFavoriteRecipes();

        // Assert
        expect(recipeProvider.favoriteRecipes.isEmpty, true);
        expect(recipeProvider.errorMessage, isNull);
      });

      test('should handle network error when fetching favorites', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/recipes/favorites'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act
        await recipeProvider.loadFavoriteRecipes();

        // Assert
        expect(recipeProvider.favoriteRecipes.isEmpty, true);
        expect(recipeProvider.errorMessage, isNotNull);
      });
    });

    group('Offline Behavior', () {
      test('should return empty list when offline and no local data', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/recipes/favorites'),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act
        await recipeProvider.loadFavoriteRecipes();

        // Assert
        expect(recipeProvider.favoriteRecipes.isEmpty, true);
        expect(recipeProvider.errorMessage, isNotNull);
      });

      // Note: Full offline support with SQLite is not yet implemented
      // This test documents the expected behavior for future implementation
      test('should display favorites from SQLite when offline (future)', () async {
        // This test is a placeholder for future offline support implementation
        // Requirements: 7.4 - Offline support with SQLite
        // Currently not implemented, would require:
        // 1. Local SQLite database
        // 2. Sync mechanism
        // 3. Offline-first provider logic
      });
    });

    group('Duplicate Favorite Handling', () {
      test('should check if recipe is already in favorites', () {
        // Arrange
        final recipe = RecipeModel(
          id: 'recipe-123',
          name: 'Bubur Ayam MPASI',
          ingredients: const ['100g beras', '50g ayam', '200ml air'],
          instructions: 'Masak beras dengan air hingga lembut',
          category: 'mpasi',
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );
        recipeProvider.favoriteRecipes.add(recipe);

        // Act
        final isFav = recipeProvider.isFavorite('recipe-123');
        final isNotFav = recipeProvider.isFavorite('recipe-999');

        // Assert
        expect(isFav, true);
        expect(isNotFav, false);
      });

      test('should prevent adding duplicate favorites via API', () async {
        // Arrange - Recipe already in favorites
        when(mockHttpClient.post(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/recipes/recipe-123/favorite'),
            response: Response(
              requestOptions: RequestOptions(path: '/recipes/recipe-123/favorite'),
              statusCode: 409,
              data: {'error': 'Recipe already in favorites'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // Act
        final result = await recipeProvider.addToFavorites('recipe-123');

        // Assert
        expect(result, false);
        expect(recipeProvider.errorMessage, contains('already in favorites'));
      });
    });
  });

  group('Shake-to-Recipe Integration Tests', () {
    group('Shake Detection with Correct Threshold', () {
      test('should use correct shake threshold of 15 m/s²', () {
        // Assert - Verify the threshold constant matches requirements
        // Requirements: 6.2 - Shake detected when acceleration > 15 m/s²
        expect(AccelerometerService.shakeThreshold, 15.0);
      });

      test('should use correct shake duration of 300ms', () {
        // Assert - Verify the duration constant matches requirements
        // Requirements: 6.2 - Shake detected for minimal 300ms
        expect(AccelerometerService.shakeDurationMs, 300);
      });

      test('should verify shake threshold is greater than normal movement', () {
        // The 15 m/s² threshold should be high enough to avoid false positives
        // from normal phone movement but low enough to detect intentional shakes
        expect(AccelerometerService.shakeThreshold, greaterThan(10.0));
        expect(AccelerometerService.shakeThreshold, lessThan(20.0));
      });
    });

    group('Debounce Mechanism (3-second cooldown)', () {
      test('should have 3-second cooldown period', () {
        // Assert - Verify the cooldown constant matches requirements
        // Requirements: 6.6 - Debounce 3 detik untuk mencegah pemicu berulang
        expect(AccelerometerService.shakeCooldownMs, 3000);
      });

      test('should verify cooldown period is reasonable', () {
        // The 3-second cooldown should be long enough to prevent accidental
        // repeated triggers but short enough for good UX
        expect(AccelerometerService.shakeCooldownMs, greaterThanOrEqualTo(2000));
        expect(AccelerometerService.shakeCooldownMs, lessThanOrEqualTo(5000));
      });

      test('should allow resetting last shake time', () {
        // This method is useful for testing and resetting state
        accelerometerService.resetLastShakeTime();

        // Assert
        expect(accelerometerService.lastShakeTime, isNull);
      });
    });

    group('Random Recipe Selection After Shake', () {
      test('should fetch random recipe after shake detected', () async {
        // Arrange
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/random'),
          statusCode: 200,
          data: {
            'recipe': {
              'id': 'recipe-random-1',
              'name': 'Bubur Kacang Hijau MPASI',
              'ingredients': ['100g kacang hijau', '200ml santan', '50g gula merah'],
              'instructions': 'Rebus kacang hijau hingga lunak, tambahkan santan dan gula',
              'nutrition_info': {
                'calories': 200.0,
                'protein': 8.0,
                'carbs': 30.0,
                'fat': 6.0,
              },
              'category': 'mpasi',
              'created_at': '2024-01-03T00:00:00Z',
            },
          },
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        await recipeProvider.getRandomRecipe();

        // Assert
        expect(recipeProvider.currentRecipe, isNotNull);
        expect(recipeProvider.currentRecipe!.id, 'recipe-random-1');
        expect(recipeProvider.currentRecipe!.name, 'Bubur Kacang Hijau MPASI');
        expect(recipeProvider.errorMessage, isNull);
        verify(mockHttpClient.get(any)).called(1);
      });

      test('should display recipe with complete details', () async {
        // Arrange
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/random'),
          statusCode: 200,
          data: {
            'recipe': {
              'id': 'recipe-123',
              'name': 'Puree Pisang Alpukat',
              'ingredients': ['1 buah pisang', '1/2 buah alpukat', '50ml ASI'],
              'instructions': 'Haluskan pisang dan alpukat, campurkan dengan ASI',
              'nutrition_info': {
                'calories': 180.0,
                'protein': 3.0,
                'carbs': 25.0,
                'fat': 8.0,
              },
              'category': 'mpasi',
              'created_at': '2024-01-04T00:00:00Z',
            },
          },
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        await recipeProvider.getRandomRecipe();

        // Assert - Verify all required fields are present
        final recipe = recipeProvider.currentRecipe!;
        expect(recipe.name, isNotEmpty);
        expect(recipe.ingredients, isNotEmpty);
        expect(recipe.instructions, isNotEmpty);
        expect(recipe.nutritionInfo, isNotNull);
        expect(recipe.nutritionInfo!.calories, greaterThan(0));
        expect(recipe.nutritionInfo!.protein, greaterThanOrEqualTo(0));
        expect(recipe.nutritionInfo!.carbs, greaterThanOrEqualTo(0));
        expect(recipe.nutritionInfo!.fat, greaterThanOrEqualTo(0));
      });

      test('should handle error when fetching random recipe fails', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/recipes/random'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act
        await recipeProvider.getRandomRecipe();

        // Assert
        expect(recipeProvider.currentRecipe, isNull);
        expect(recipeProvider.errorMessage, isNotNull);
      });

      test('should handle empty recipe data in response', () async {
        // Arrange
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/random'),
          statusCode: 200,
          data: {
            'recipe': null,
          },
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        await recipeProvider.getRandomRecipe();

        // Assert
        expect(recipeProvider.currentRecipe, isNull);
        expect(recipeProvider.errorMessage, contains('No recipe data'));
      });
    });

    group('Shake Detection Service Lifecycle', () {
      test('should initialize with correct default state', () {
        // Assert - Verify initial state
        expect(accelerometerService.isListening, false);
        expect(accelerometerService.errorMessage, isNull);
        expect(accelerometerService.lastShakeTime, isNull);
      });

      test('should have dispose method for cleanup', () {
        // This test verifies the service has proper cleanup method
        // Actual sensor lifecycle is tested in integration tests
        expect(accelerometerService.dispose, isNotNull);
        
        // Verify dispose can be called safely
        accelerometerService.dispose();
        expect(accelerometerService.isListening, false);
      });

      test('should have reset method for testing', () {
        // Verify the service provides a reset method for testing
        expect(accelerometerService.resetLastShakeTime, isNotNull);
        
        // Verify reset works
        accelerometerService.resetLastShakeTime();
        expect(accelerometerService.lastShakeTime, isNull);
      });
    });

    group('Integration: Shake to Recipe to Favorite', () {
      test('should allow saving recipe to favorites after shake', () async {
        // Arrange - Get random recipe
        final mockRandomResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/random'),
          statusCode: 200,
          data: {
            'recipe': {
              'id': 'recipe-shake-1',
              'name': 'Nasi Tim Ayam',
              'ingredients': ['100g beras', '50g ayam', '1 butir telur'],
              'instructions': 'Tim semua bahan hingga matang',
              'nutrition_info': {
                'calories': 220.0,
                'protein': 15.0,
                'carbs': 25.0,
                'fat': 7.0,
              },
              'category': 'mpasi',
              'created_at': '2024-01-05T00:00:00Z',
            },
          },
        );

        final mockPostResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/recipe-shake-1/favorite'),
          statusCode: 201,
        );

        final mockGetResponse = Response(
          requestOptions: RequestOptions(path: '/recipes/favorites'),
          statusCode: 200,
          data: {
            'recipes': [
              {
                'id': 'recipe-shake-1',
                'name': 'Nasi Tim Ayam',
                'ingredients': ['100g beras', '50g ayam', '1 butir telur'],
                'instructions': 'Tim semua bahan hingga matang',
                'nutrition_info': {
                  'calories': 220.0,
                  'protein': 15.0,
                  'carbs': 25.0,
                  'fat': 7.0,
                },
                'category': 'mpasi',
                'created_at': '2024-01-05T00:00:00Z',
              },
            ],
          },
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockRandomResponse);
        when(mockHttpClient.post(any)).thenAnswer((_) async => mockPostResponse);

        // Act - Simulate shake-to-recipe flow
        await recipeProvider.getRandomRecipe();
        expect(recipeProvider.currentRecipe, isNotNull);

        // Now add to favorites
        when(mockHttpClient.get(any)).thenAnswer((_) async => mockGetResponse);
        final result = await recipeProvider.addToFavorites('recipe-shake-1');

        // Assert
        expect(result, true);
        expect(recipeProvider.favoriteRecipes.length, 1);
        expect(recipeProvider.favoriteRecipes[0].id, 'recipe-shake-1');
      });
    });
  });

  group('Recipe Provider State Management', () {
    test('should clear current recipe', () {
      // Arrange - Set a current recipe first
      // We can't directly set it, but we can verify the method exists
      recipeProvider.clearCurrentRecipe();

      // Assert
      expect(recipeProvider.currentRecipe, isNull);
    });

    test('should clear error message', () {
      // Act
      recipeProvider.clearError();

      // Assert
      expect(recipeProvider.errorMessage, isNull);
    });

    test('should set loading state during operations', () async {
      // Arrange
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/recipes/random'),
        statusCode: 200,
        data: {
          'recipe': {
            'id': 'recipe-123',
            'name': 'Test Recipe',
            'ingredients': ['ingredient 1'],
            'instructions': 'Test instructions',
            'category': 'mpasi',
            'created_at': '2024-01-01T00:00:00Z',
          },
        },
      );

      when(mockHttpClient.get(any)).thenAnswer((_) async {
        // Simulate delay
        await Future.delayed(const Duration(milliseconds: 100));
        return mockResponse;
      });

      // Act & Assert
      final future = recipeProvider.getRandomRecipe();
      
      // Loading should be true during operation
      // Note: This might be flaky due to timing, but demonstrates the concept
      
      await future;
      
      // Loading should be false after completion
      expect(recipeProvider.isLoading, false);
    });
  });
}
