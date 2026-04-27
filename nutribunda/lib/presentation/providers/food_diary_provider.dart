import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/http_client_service.dart';
import '../../data/models/diary_entry.dart';
import '../../data/models/nutrition_summary.dart';
import '../../data/models/food_model.dart';

/// Provider untuk mengelola state Food Diary
/// Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6
class FoodDiaryProvider extends ChangeNotifier {
  final HttpClientService _httpClient;

  // State untuk diary entries
  List<DiaryEntry> _entries = [];
  NutritionSummary _nutritionSummary = const NutritionSummary();
  
  // State untuk profile dan date selection
  String _selectedProfile = 'baby'; // 'baby' or 'mother'
  DateTime _selectedDate = DateTime.now();
  
  // Loading dan error states
  bool _isLoading = false;
  bool _isLoadingFoods = false;
  String? _errorMessage;
  
  // Food search results
  List<FoodModel> _searchResults = [];

  FoodDiaryProvider({
    required HttpClientService httpClient,
  }) : _httpClient = httpClient;

  // Getters
  List<DiaryEntry> get entries => _entries;
  NutritionSummary get nutritionSummary => _nutritionSummary;
  String get selectedProfile => _selectedProfile;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  bool get isLoadingFoods => _isLoadingFoods;
  String? get errorMessage => _errorMessage;
  List<FoodModel> get searchResults => _searchResults;

  /// Get entries grouped by meal time
  /// Requirements: 4.4 - Mengkategorikan entri ke dalam slot waktu
  Map<String, List<DiaryEntry>> get entriesByMealTime {
    final Map<String, List<DiaryEntry>> grouped = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };

    for (final entry in _entries) {
      if (grouped.containsKey(entry.mealTime)) {
        grouped[entry.mealTime]!.add(entry);
      }
    }

    return grouped;
  }

  /// Set selected profile
  /// Requirements: 4.1 - Dual profile support (baby and mother)
  void setSelectedProfile(String profile) {
    if (profile != 'baby' && profile != 'mother') {
      _errorMessage = 'Invalid profile type';
      notifyListeners();
      return;
    }

    if (_selectedProfile != profile) {
      _selectedProfile = profile;
      notifyListeners();
      // Reload entries for new profile
      loadEntries();
    }
  }

  /// Set selected date
  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      notifyListeners();
      // Reload entries for new date
      loadEntries();
    }
  }

  /// Load diary entries for selected profile and date
  /// Requirements: 4.1 - Mencatat makanan untuk dua profil terpisah
  Future<void> loadEntries() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Format date as YYYY-MM-DD
      final dateStr = _formatDate(_selectedDate);

      // Call API
      final response = await _httpClient.get(
        ApiConstants.diary,
        queryParameters: {
          'profile': _selectedProfile,
          'date': dateStr,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Parse entries
        final entriesJson = data['entries'] as List<dynamic>?;
        if (entriesJson != null) {
          _entries = entriesJson
              .map((json) => DiaryEntry.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          _entries = [];
        }

        // Parse nutrition summary
        final summaryJson = data['nutrition_summary'] as Map<String, dynamic>?;
        if (summaryJson != null) {
          _nutritionSummary = NutritionSummary.fromJson(summaryJson);
        } else {
          _nutritionSummary = const NutritionSummary();
        }

        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load diary entries';
        _entries = [];
        _nutritionSummary = const NutritionSummary();
      }
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _entries = [];
      _nutritionSummary = const NutritionSummary();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _errorMessage = 'Unauthorized. Please login again.';
      } else {
        _errorMessage = 'Failed to load diary entries: ${e.message}';
      }
      _entries = [];
      _nutritionSummary = const NutritionSummary();
    } catch (e) {
      _errorMessage = 'Unexpected error: ${e.toString()}';
      _entries = [];
      _nutritionSummary = const NutritionSummary();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new diary entry
  /// Requirements: 4.2 - Memilih makanan dari database atau manual entry
  /// Requirements: 4.3 - Menghitung dan memperbarui total nutrisi
  Future<bool> addEntry({
    required String profileType,
    String? foodId,
    String? customFoodName,
    required double servingSize,
    required String mealTime,
    required DateTime entryDate,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Validate inputs
      if (profileType != 'baby' && profileType != 'mother') {
        _errorMessage = 'Invalid profile type';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (foodId == null && customFoodName == null) {
        _errorMessage = 'Either food or custom food name must be provided';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (customFoodName != null && (calories == null || protein == null || carbs == null || fat == null)) {
        _errorMessage = 'Nutrition values are required for manual entry';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Prepare request data
      final Map<String, dynamic> requestData = {
        'profile_type': profileType,
        'serving_size': servingSize,
        'meal_time': mealTime,
        'entry_date': _formatDate(entryDate),
      };

      if (foodId != null) {
        requestData['food_id'] = foodId;
      } else {
        requestData['custom_food_name'] = customFoodName;
        requestData['calories'] = calories;
        requestData['protein'] = protein;
        requestData['carbs'] = carbs;
        requestData['fat'] = fat;
      }

      // Call API
      final response = await _httpClient.post(
        ApiConstants.diary,
        data: requestData,
      );

      if (response.statusCode == 201 && response.data != null) {
        final newEntry = DiaryEntry.fromJson(response.data as Map<String, dynamic>);

        // If the new entry is for the currently selected profile and date, add it to the list
        if (newEntry.profileType == _selectedProfile &&
            _isSameDate(newEntry.entryDate, _selectedDate)) {
          _entries.add(newEntry);

          // Update nutrition summary
          // Requirements: 4.3 - Menghitung dan memperbarui total nutrisi
          _nutritionSummary = _nutritionSummary.add(
            newEntry.calories,
            newEntry.protein,
            newEntry.carbs,
            newEntry.fat,
          );
        }

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to add diary entry';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['error'] as String?;
        _errorMessage = message ?? 'Invalid data';
      } else {
        _errorMessage = 'Failed to add diary entry: ${e.message}';
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

  /// Delete diary entry
  /// Requirements: 4.5 - Mengurangi total nutrisi saat entry dihapus
  Future<bool> deleteEntry(String entryId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Find the entry to get its nutrition values before deletion
      final entryToDelete = _entries.firstWhere(
        (entry) => entry.id == entryId,
        orElse: () => throw Exception('Entry not found'),
      );

      // Call API
      final response = await _httpClient.delete('${ApiConstants.diary}/$entryId');

      if (response.statusCode == 200) {
        // Remove from local list
        _entries.removeWhere((entry) => entry.id == entryId);

        // Update nutrition summary
        // Requirements: 4.5 - Mengurangi total nutrisi
        _nutritionSummary = _nutritionSummary.remove(
          entryToDelete.calories,
          entryToDelete.protein,
          entryToDelete.carbs,
          entryToDelete.fat,
        );

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete diary entry';
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
      if (e.response?.statusCode == 404) {
        _errorMessage = 'Entry not found';
      } else if (e.response?.statusCode == 403) {
        _errorMessage = 'You don\'t have permission to delete this entry';
      } else {
        _errorMessage = 'Failed to delete diary entry: ${e.message}';
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

  /// Search foods from database
  /// Requirements: 4.2 - Memilih makanan dari Food_Database
  Future<void> searchFoods(String query, {String? category}) async {
    try {
      _isLoadingFoods = true;
      _errorMessage = null;
      notifyListeners();

      if (query.isEmpty) {
        _searchResults = [];
        _isLoadingFoods = false;
        notifyListeners();
        return;
      }

      // Determine category based on selected profile if not provided
      final searchCategory = category ?? (_selectedProfile == 'baby' ? 'mpasi' : 'ibu');

      // Call API
      final response = await _httpClient.get(
        ApiConstants.foods,
        queryParameters: {
          'search': query,
          'category': searchCategory,
          'limit': 20,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final foodsJson = data['foods'] as List<dynamic>?;

        if (foodsJson != null) {
          _searchResults = foodsJson
              .map((json) => FoodModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          _searchResults = [];
        }

        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to search foods';
        _searchResults = [];
      }
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _searchResults = [];
    } on DioException catch (e) {
      _errorMessage = 'Failed to search foods: ${e.message}';
      _searchResults = [];
    } catch (e) {
      _errorMessage = 'Unexpected error: ${e.toString()}';
      _searchResults = [];
    } finally {
      _isLoadingFoods = false;
      notifyListeners();
    }
  }

  /// Clear search results
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== Helper Methods ====================

  /// Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if two dates are the same day
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
