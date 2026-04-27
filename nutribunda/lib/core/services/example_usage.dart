// ignore_for_file: unused_local_variable, avoid_print

/// Example usage file untuk SecureStorageService dan HttpClientService
/// File ini hanya untuk dokumentasi dan tidak digunakan dalam aplikasi
/// 
/// JANGAN IMPORT FILE INI DI PRODUCTION CODE!

import 'package:nutribunda/core/services/secure_storage_service.dart';
import 'package:nutribunda/core/services/http_client_service.dart';
import 'package:nutribunda/core/errors/exceptions.dart';
import 'package:nutribunda/injection_container.dart';

/// Example 1: Login Flow dengan SecureStorageService dan HttpClientService
Future<void> exampleLoginFlow() async {
  // Get services dari dependency injection
  final httpClient = sl<HttpClientService>();
  final secureStorage = sl<SecureStorageService>();

  try {
    // 1. Kirim request login ke backend
    final response = await httpClient.post(
      '/auth/login',
      data: {
        'email': 'user@example.com',
        'password': 'password123',
      },
    );

    // 2. Extract token dari response
    final accessToken = response.data['token'] as String;
    final refreshToken = response.data['refresh_token'] as String?;
    final userId = response.data['user']['id'] as String;
    final userEmail = response.data['user']['email'] as String;

    // 3. Simpan token dan user data ke secure storage
    await secureStorage.saveAccessToken(accessToken);
    if (refreshToken != null) {
      await secureStorage.saveRefreshToken(refreshToken);
    }
    await secureStorage.saveUserId(userId);
    await secureStorage.saveUserEmail(userEmail);

    print('Login successful!');
  } on ValidationException catch (e) {
    // Handle validation errors (email/password salah)
    print('Login failed: ${e.message}');
  } on NetworkException catch (e) {
    // Handle network errors
    print('Network error: ${e.message}');
  } catch (e) {
    // Handle unexpected errors
    print('Unexpected error: $e');
  }
}

/// Example 2: Authenticated Request
Future<void> exampleAuthenticatedRequest() async {
  final httpClient = sl<HttpClientService>();

  try {
    // HttpClientService akan otomatis menambahkan JWT token ke header
    final response = await httpClient.get('/profile');

    final userName = response.data['full_name'];
    final userEmail = response.data['email'];

    print('User: $userName ($userEmail)');
  } on UnauthorizedException catch (e) {
    // Token expired atau invalid, redirect ke login
    print('Unauthorized: ${e.message}');
    // Navigate to login screen
  } on NetworkException catch (e) {
    print('Network error: ${e.message}');
  }
}

/// Example 3: Update Profile dengan File Upload
Future<void> exampleUpdateProfileWithImage() async {
  final httpClient = sl<HttpClientService>();

  try {
    // 1. Update profile data
    await httpClient.put(
      '/profile',
      data: {
        'full_name': 'Jane Doe',
        'weight': 65.5,
        'height': 165.0,
        'age': 28,
        'is_breastfeeding': true,
      },
    );

    // 2. Upload profile image
    final response = await httpClient.uploadFile(
      '/profile/upload-image',
      filePath: '/path/to/image.jpg',
      fieldName: 'image',
      onSendProgress: (sent, total) {
        final progress = (sent / total * 100).toStringAsFixed(0);
        print('Upload progress: $progress%');
      },
    );

    final imageUrl = response.data['profile_image_url'];
    print('Profile updated! Image URL: $imageUrl');
  } on ValidationException catch (e) {
    print('Validation error: ${e.message}');
  } on NetworkException catch (e) {
    print('Network error: ${e.message}');
  }
}

/// Example 4: Logout Flow
Future<void> exampleLogoutFlow() async {
  final httpClient = sl<HttpClientService>();
  final secureStorage = sl<SecureStorageService>();

  try {
    // 1. Kirim request logout ke backend (optional)
    await httpClient.post('/auth/logout');

    // 2. Hapus semua token dan data dari secure storage
    await secureStorage.clearAll();

    print('Logout successful!');
    // Navigate to login screen
  } catch (e) {
    // Even if logout request fails, still clear local data
    await secureStorage.clearAll();
    print('Logged out (with errors): $e');
  }
}

/// Example 5: Check Authentication Status
Future<bool> exampleCheckAuthStatus() async {
  final secureStorage = sl<SecureStorageService>();

  // Cek apakah user memiliki token yang valid
  final hasToken = await secureStorage.hasValidToken();

  if (hasToken) {
    print('User is authenticated');
    return true;
  } else {
    print('User is not authenticated');
    return false;
  }
}

/// Example 6: Biometric Authentication Setup
Future<void> exampleBiometricSetup() async {
  final secureStorage = sl<SecureStorageService>();

  // Enable biometric authentication
  await secureStorage.setBiometricEnabled(true);

  // Check if biometric is enabled
  final isEnabled = await secureStorage.isBiometricEnabled();
  print('Biometric enabled: $isEnabled');
}

/// Example 7: Food Diary - Add Entry
Future<void> exampleAddFoodDiaryEntry() async {
  final httpClient = sl<HttpClientService>();

  try {
    final response = await httpClient.post(
      '/diary',
      data: {
        'profile_type': 'baby',
        'food_id': 'food-uuid-123',
        'serving_size': 100.0,
        'meal_time': 'breakfast',
        'entry_date': '2024-01-15',
      },
    );

    print('Diary entry added: ${response.data['id']}');
  } on ValidationException catch (e) {
    print('Validation error: ${e.message}');
  } on NetworkException catch (e) {
    print('Network error: ${e.message}');
  }
}

/// Example 8: Search Foods
Future<void> exampleSearchFoods() async {
  final httpClient = sl<HttpClientService>();

  try {
    final response = await httpClient.get(
      '/foods',
      queryParameters: {
        'search': 'pisang',
        'category': 'mpasi',
        'limit': 10,
      },
    );

    final foods = response.data['foods'] as List;
    print('Found ${foods.length} foods');

    for (var food in foods) {
      print('- ${food['name']}: ${food['calories_per_100g']} kkal');
    }
  } on NetworkException catch (e) {
    print('Network error: ${e.message}');
  }
}

/// Example 9: Get Random Recipe (Shake-to-Recipe)
Future<void> exampleGetRandomRecipe() async {
  final httpClient = sl<HttpClientService>();

  try {
    final response = await httpClient.get('/recipes/random');

    final recipe = response.data['recipe'];
    print('Random recipe: ${recipe['name']}');
    print('Ingredients: ${recipe['ingredients']}');
    print('Instructions: ${recipe['instructions']}');
  } on NetworkException catch (e) {
    print('Network error: ${e.message}');
  }
}

/// Example 10: Error Handling Best Practices
Future<void> exampleErrorHandling() async {
  final httpClient = sl<HttpClientService>();

  try {
    final response = await httpClient.get('/some-endpoint');
    // Handle success
    print('Success: ${response.data}');
  } on UnauthorizedException catch (e) {
    // Token expired atau invalid
    // Action: Redirect to login screen
    print('Unauthorized: ${e.message}');
  } on ValidationException catch (e) {
    // Validation error (bad request)
    // Action: Show error message to user
    print('Validation error: ${e.message}');
  } on ServerException catch (e) {
    // Server error (404, 500, etc)
    // Action: Show generic error message
    print('Server error: ${e.message}');
  } on NetworkException catch (e) {
    // Network error (no internet, timeout, etc)
    // Action: Show network error message
    print('Network error: ${e.message}');
  } catch (e) {
    // Unexpected error
    // Action: Log error and show generic message
    print('Unexpected error: $e');
  }
}

/// Example 11: Custom Headers
Future<void> exampleCustomHeaders() async {
  final httpClient = sl<HttpClientService>();

  // Add custom header
  httpClient.addHeader('X-App-Version', '1.0.0');
  httpClient.addHeader('X-Device-ID', 'device-123');

  try {
    final response = await httpClient.get('/some-endpoint');
    print('Response: ${response.data}');
  } finally {
    // Remove custom headers after use
    httpClient.removeHeader('X-App-Version');
    httpClient.removeHeader('X-Device-ID');
  }
}

/// Example 12: Download File
Future<void> exampleDownloadFile() async {
  final httpClient = sl<HttpClientService>();

  try {
    await httpClient.downloadFile(
      '/files/nutrition-guide.pdf',
      '/path/to/save/nutrition-guide.pdf',
      onReceiveProgress: (received, total) {
        final progress = (received / total * 100).toStringAsFixed(0);
        print('Download progress: $progress%');
      },
    );

    print('File downloaded successfully!');
  } on NetworkException catch (e) {
    print('Download failed: ${e.message}');
  }
}

/// Example 13: Pagination
Future<void> examplePagination() async {
  final httpClient = sl<HttpClientService>();

  int page = 1;
  const limit = 20;

  try {
    final response = await httpClient.get(
      '/diary',
      queryParameters: {
        'profile': 'baby',
        'page': page,
        'limit': limit,
      },
    );

    final entries = response.data['entries'] as List;
    final total = response.data['total'] as int;
    final hasMore = (page * limit) < total;

    print('Loaded ${entries.length} entries (page $page)');
    print('Has more: $hasMore');
  } on NetworkException catch (e) {
    print('Network error: ${e.message}');
  }
}

/// Example 14: Batch Operations
Future<void> exampleBatchOperations() async {
  final httpClient = sl<HttpClientService>();

  try {
    // Delete multiple diary entries
    final entriesToDelete = ['entry-1', 'entry-2', 'entry-3'];

    for (var entryId in entriesToDelete) {
      await httpClient.delete('/diary/$entryId');
    }

    print('Deleted ${entriesToDelete.length} entries');
  } on NetworkException catch (e) {
    print('Network error: ${e.message}');
  }
}

/// Example 15: Conditional Requests
Future<void> exampleConditionalRequests() async {
  final httpClient = sl<HttpClientService>();
  final secureStorage = sl<SecureStorageService>();

  // Check if user is authenticated before making request
  final hasToken = await secureStorage.hasValidToken();

  if (!hasToken) {
    print('User not authenticated, redirecting to login...');
    return;
  }

  try {
    final response = await httpClient.get('/profile');
    print('Profile: ${response.data}');
  } on UnauthorizedException catch (e) {
    print('Token expired: ${e.message}');
    // Redirect to login
  }
}
