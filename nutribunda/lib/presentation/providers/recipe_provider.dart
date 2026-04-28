import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/http_client_service.dart';
import '../../data/models/recipe_model.dart';

/// Provider untuk mengelola state Recipe dan Favorit
/// Requirements: 6.3, 6.4, 6.5, 7.1, 7.2, 7.3
class RecipeProvider extends ChangeNotifier {
  final HttpClientService _httpClient;

  // State untuk recipes
  RecipeModel? _currentRecipe;
  List<RecipeModel> _favoriteRecipes = [];
  
  // Loading dan error states
  bool _isLoading = false;
  bool _isLoadingFavorites = false;
  String? _errorMessage;

  RecipeProvider({
    required HttpClientService httpClient,
  }) : _httpClient = httpClient;

  // Getters
  RecipeModel? get currentRecipe => _currentRecipe;
  List<RecipeModel> get favoriteRecipes => _favoriteRecipes;
  bool get isLoading => _isLoading;
  bool get isLoadingFavorites => _isLoadingFavorites;
  String? get errorMessage => _errorMessage;

  /// Get random recipe for shake-to-recipe feature
  /// Requirements: 6.3 - Menampilkan resep MPASI yang dipilih secara acak
  Future<void> getRandomRecipe() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call API
      final response = await _httpClient.get(ApiConstants.recipesRandom);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final recipeJson = data['recipe'] as Map<String, dynamic>?;

        if (recipeJson != null) {
          _currentRecipe = RecipeModel.fromJson(recipeJson);
          _errorMessage = null;
        } else {
          _errorMessage = 'No recipe data received';
          _currentRecipe = null;
        }
      } else {
        _errorMessage = 'Failed to get random recipe';
        _currentRecipe = null;
      }
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _currentRecipe = null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _errorMessage = 'Unauthorized. Please login again.';
      } else {
        _errorMessage = 'Failed to get random recipe: ${e.message}';
      }
      _currentRecipe = null;
    } catch (e) {
      _errorMessage = 'Unexpected error: ${e.toString()}';
      _currentRecipe = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load favorite recipes
  /// Requirements: 7.2 - Menampilkan daftar resep favorit
  Future<void> loadFavoriteRecipes() async {
    try {
      _isLoadingFavorites = true;
      _errorMessage = null;
      notifyListeners();

      // Call API
      final response = await _httpClient.get(ApiConstants.recipesFavorites);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final recipesJson = data['recipes'] as List<dynamic>?;

        if (recipesJson != null) {
          _favoriteRecipes = recipesJson
              .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          _favoriteRecipes = [];
        }

        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load favorite recipes';
        _favoriteRecipes = [];
      }
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _favoriteRecipes = [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _errorMessage = 'Unauthorized. Please login again.';
      } else {
        _errorMessage = 'Failed to load favorite recipes: ${e.message}';
      }
      _favoriteRecipes = [];
    } catch (e) {
      _errorMessage = 'Unexpected error: ${e.toString()}';
      _favoriteRecipes = [];
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  /// Add recipe to favorites
  /// Requirements: 6.5, 7.1 - Menyimpan resep ke daftar favorit
  Future<bool> addToFavorites(String recipeId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call API
      final response = await _httpClient.post(
        '${ApiConstants.recipes}/$recipeId/favorite',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Reload favorites to get updated list
        await loadFavoriteRecipes();
        
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to add recipe to favorites';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _errorMessage = 'Unauthorized. Please login again.';
      } else if (e.response?.statusCode == 409) {
        _errorMessage = 'Recipe already in favorites';
      } else {
        _errorMessage = 'Failed to add recipe to favorites: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove recipe from favorites
  /// Requirements: 7.3 - Menghapus resep dari daftar favorit
  Future<bool> removeFromFavorites(String recipeId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call API
      final response = await _httpClient.delete(
        '${ApiConstants.recipes}/$recipeId/favorite',
      );

      if (response.statusCode == 200) {
        // Remove from local list
        _favoriteRecipes.removeWhere((recipe) => recipe.id == recipeId);
        
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to remove recipe from favorites';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _errorMessage = 'Unauthorized. Please login again.';
      } else if (e.response?.statusCode == 404) {
        _errorMessage = 'Recipe not found in favorites';
      } else {
        _errorMessage = 'Failed to remove recipe from favorites: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check if a recipe is in favorites
  bool isFavorite(String recipeId) {
    return _favoriteRecipes.any((recipe) => recipe.id == recipeId);
  }

  /// Clear current recipe
  void clearCurrentRecipe() {
    _currentRecipe = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
