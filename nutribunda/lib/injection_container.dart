import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core Services
import 'core/services/secure_storage_service.dart';
import 'core/services/http_client_service.dart';
import 'core/services/biometric_service.dart';

// Providers
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/food_diary_provider.dart';

/// Service Locator instance
/// Digunakan untuk dependency injection di seluruh aplikasi
final sl = GetIt.instance;

/// Initialize semua dependencies
/// Harus dipanggil di main() sebelum runApp()
Future<void> init() async {
  // ============================================================================
  // CORE - External Dependencies
  // ============================================================================
  
  // Secure Storage untuk JWT dan sensitive data
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    ),
  );
  
  // Shared Preferences untuk non-sensitive data
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  // ============================================================================
  // CORE SERVICES
  // ============================================================================
  
  // Secure Storage Service - untuk mengelola JWT dan data terenkripsi
  // Requirements: 1.4, 1.6, 1.7
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(secureStorage: sl()),
  );
  
  // HTTP Client Service - untuk komunikasi dengan backend API
  // Requirements: 1.4, 1.6
  sl.registerLazySingleton<HttpClientService>(
    () => HttpClientService(secureStorage: sl()),
  );
  
  // Biometric Service - untuk autentikasi biometrik
  // Requirements: 2.1, 2.2, 2.3, 2.4, 2.5
  sl.registerLazySingleton<BiometricService>(
    () => BiometricService(secureStorage: sl()),
  );
  
  // HTTP Client (Dio) - raw instance untuk custom usage
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors untuk logging dan error handling
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
    
    return dio;
  });
  
  // ============================================================================
  // PROVIDERS - State Management
  // ============================================================================
  
  // Providers akan didaftarkan di sini saat implementasi fitur
  // Menggunakan registerFactory untuk providers agar setiap kali diakses
  // akan membuat instance baru
  
  // Auth Provider - Requirements: 1.1, 1.5, 1.7, 2.1, 2.2, 2.3, 2.4, 2.5
  sl.registerFactory(() => AuthProvider(
    httpClient: sl(),
    secureStorage: sl(),
    biometricService: sl(),
  ));
  
  // Food Diary Provider - Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6
  sl.registerFactory(() => FoodDiaryProvider(
    httpClient: sl(),
  ));
  
  // ============================================================================
  // USE CASES - Business Logic
  // ============================================================================
  
  // Use cases akan didaftarkan di sini saat implementasi fitur
  // Menggunakan registerLazySingleton karena use cases stateless
  
  // Contoh:
  // sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  
  // ============================================================================
  // REPOSITORIES - Data Layer
  // ============================================================================
  
  // Repositories akan didaftarkan di sini saat implementasi fitur
  // Menggunakan registerLazySingleton untuk repositories
  
  // Contoh:
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     remoteDataSource: sl(),
  //     localDataSource: sl(),
  //     networkInfo: sl(),
  //   ),
  // );
  
  // ============================================================================
  // DATA SOURCES - Remote & Local
  // ============================================================================
  
  // Data sources akan didaftarkan di sini saat implementasi fitur
  
  // Contoh:
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(client: sl()),
  // );
  // 
  // sl.registerLazySingleton<AuthLocalDataSource>(
  //   () => AuthLocalDataSourceImpl(secureStorage: sl()),
  // );
  
  // ============================================================================
  // SERVICES - Platform & External Services
  // ============================================================================
  
  // Services akan didaftarkan di sini saat implementasi fitur
  
  // Contoh:
  // sl.registerLazySingleton(() => BiometricService());
  // sl.registerLazySingleton(() => PedometerService());
  // sl.registerLazySingleton(() => AccelerometerService());
  // sl.registerLazySingleton(() => LocationService());
  // sl.registerLazySingleton(() => NotificationService());
}

/// Reset semua dependencies (untuk testing)
Future<void> reset() async {
  await sl.reset();
}
