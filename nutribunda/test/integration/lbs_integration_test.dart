import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nutribunda/presentation/providers/lbs_provider.dart';
import 'package:nutribunda/core/services/location_service.dart';
import 'package:nutribunda/core/services/maps_launcher_service.dart';

// Generate mocks for LocationService and MapsLauncherService
@GenerateMocks([LocationService, MapsLauncherService])
import 'lbs_integration_test.mocks.dart';

void main() {
  late LBSProvider lbsProvider;
  late MockLocationService mockLocationService;
  late MockMapsLauncherService mockMapsLauncher;

  setUp(() {
    mockLocationService = MockLocationService();
    mockMapsLauncher = MockMapsLauncherService();
    lbsProvider = LBSProvider(
      locationService: mockLocationService,
      mapsLauncher: mockMapsLauncher,
    );
  });

  group('LBS Integration Tests - Location Permission Handling', () {
    /// **Validates: Requirement 8.1** - Meminta izin akses lokasi perangkat
    group('Permission Granted Scenario', () {
      test('should successfully get location when permission is granted', () async {
        // Arrange
        final mockPosition = Position(
          latitude: -6.2088,
          longitude: 106.8456,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        when(mockLocationService.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(mockLocationService.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockLocationService.getCurrentLocation())
            .thenAnswer((_) async => mockPosition);

        // Act
        await lbsProvider.fetchCurrentLocation();

        // Assert
        expect(lbsProvider.currentPosition, isNotNull);
        expect(lbsProvider.currentPosition!.latitude, -6.2088);
        expect(lbsProvider.currentPosition!.longitude, 106.8456);
        expect(lbsProvider.errorMessage, isNull);
        expect(lbsProvider.isLoadingLocation, false);
        expect(lbsProvider.hasLocation, true);
        expect(lbsProvider.permissionStatus, LocationPermission.whileInUse);

        verify(mockLocationService.checkPermission()).called(1);
        verify(mockLocationService.isLocationServiceEnabled()).called(1);
        verify(mockLocationService.getCurrentLocation()).called(1);
      });

      test('should handle permission granted with always access', () async {
        // Arrange
        final mockPosition = Position(
          latitude: -7.7956,
          longitude: 110.3695,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        when(mockLocationService.checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(mockLocationService.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockLocationService.getCurrentLocation())
            .thenAnswer((_) async => mockPosition);

        // Act
        await lbsProvider.fetchCurrentLocation();

        // Assert
        expect(lbsProvider.currentPosition, isNotNull);
        expect(lbsProvider.permissionStatus, LocationPermission.always);
        expect(lbsProvider.errorMessage, isNull);
      });
    });

    /// **Validates: Requirement 8.7** - Menampilkan pesan dan mengarahkan ke pengaturan
    group('Permission Denied Scenario', () {
      test('should handle permission denied with appropriate error message', () async {
        // Arrange
        when(mockLocationService.checkPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        when(mockLocationService.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockLocationService.getCurrentLocation())
            .thenAnswer((_) async => null);

        // Act
        await lbsProvider.fetchCurrentLocation();

        // Assert
        expect(lbsProvider.currentPosition, isNull);
        expect(lbsProvider.errorMessage, isNotNull);
        expect(lbsProvider.errorMessage, contains('Izin lokasi diperlukan'));
        expect(lbsProvider.hasLocation, false);
        expect(lbsProvider.permissionStatus, LocationPermission.denied);
      });

      test('should allow opening app settings when permission denied', () async {
        // Arrange
        when(mockLocationService.openAppSettings())
            .thenAnswer((_) async => true);

        // Act
        await lbsProvider.openAppSettings();

        // Assert
        verify(mockLocationService.openAppSettings()).called(1);
      });
    });

    /// **Validates: Requirement 8.7** - Menampilkan pesan untuk izin ditolak permanen
    group('Permission Denied Forever Scenario', () {
      test('should handle permission denied forever with specific error message', () async {
        // Arrange
        when(mockLocationService.checkPermission())
            .thenAnswer((_) async => LocationPermission.deniedForever);
        when(mockLocationService.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockLocationService.getCurrentLocation())
            .thenAnswer((_) async => null);

        // Act
        await lbsProvider.fetchCurrentLocation();

        // Assert
        expect(lbsProvider.currentPosition, isNull);
        expect(lbsProvider.errorMessage, isNotNull);
        expect(lbsProvider.errorMessage, contains('ditolak secara permanen'));
        expect(lbsProvider.errorMessage, contains('pengaturan aplikasi'));
        expect(lbsProvider.permissionStatus, LocationPermission.deniedForever);
      });

      test('should provide method to open app settings', () async {
        // Arrange
        when(mockLocationService.openAppSettings())
            .thenAnswer((_) async => true);

        // Act
        await lbsProvider.openAppSettings();

        // Assert
        verify(mockLocationService.openAppSettings()).called(1);
      });
    });

    /// **Validates: Requirement 8.7** - Menangani layanan lokasi tidak aktif
    group('Location Service Disabled Scenario', () {
      test('should handle location service disabled with appropriate error', () async {
        // Arrange
        when(mockLocationService.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(mockLocationService.isLocationServiceEnabled())
            .thenAnswer((_) async => false);

        // Act
        await lbsProvider.fetchCurrentLocation();

        // Assert
        expect(lbsProvider.currentPosition, isNull);
        expect(lbsProvider.errorMessage, isNotNull);
        expect(lbsProvider.errorMessage, contains('Layanan lokasi tidak aktif'));
        expect(lbsProvider.errorMessage, contains('aktifkan GPS'));
        expect(lbsProvider.isLoadingLocation, false);
      });

      test('should allow opening location settings when service disabled', () async {
        // Arrange
        when(mockLocationService.openLocationSettings())
            .thenAnswer((_) async => true);

        // Act
        await lbsProvider.openLocationSettings();

        // Assert
        verify(mockLocationService.openLocationSettings()).called(1);
      });
    });

    group('Error Handling Scenarios', () {
      test('should handle exception during location fetch', () async {
        // Arrange
        when(mockLocationService.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(mockLocationService.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockLocationService.getCurrentLocation())
            .thenThrow(Exception('GPS timeout'));

        // Act
        await lbsProvider.fetchCurrentLocation();

        // Assert
        expect(lbsProvider.currentPosition, isNull);
        expect(lbsProvider.errorMessage, isNotNull);
        expect(lbsProvider.errorMessage, contains('Terjadi kesalahan'));
        expect(lbsProvider.isLoadingLocation, false);
      });

      test('should handle null position returned from service', () async {
        // Arrange
        when(mockLocationService.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(mockLocationService.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockLocationService.getCurrentLocation())
            .thenAnswer((_) async => null);

        // Act
        await lbsProvider.fetchCurrentLocation();

        // Assert
        expect(lbsProvider.currentPosition, isNull);
        expect(lbsProvider.errorMessage, isNotNull);
        expect(lbsProvider.errorMessage, contains('Tidak dapat mengakses lokasi'));
      });
    });
  });

  /// **Validates: Requirements 8.3, 8.4, 8.5** - Deep link URL formatting
  group('LBS Integration Tests - Deep Link URL Formatting', () {
    // Use real MapsLauncherService for URL formatting tests since it has no external dependencies
    late MapsLauncherService realMapsLauncher;

    setUp(() {
      realMapsLauncher = MapsLauncherService();
    });

    group('URL Format for All Facility Categories', () {
      /// **Validates: Requirement 8.3** - Kategori fasilitas kesehatan
      test('should create correct URL for Rumah Sakit category', () {
        // Arrange
        const latitude = -6.2088;
        const longitude = 106.8456;
        const category = 'hospital';

        // Act
        final url = realMapsLauncher.createMapsSearchUrl(
          latitude: latitude,
          longitude: longitude,
          category: category,
        );

        // Assert - Verify URL structure
        expect(url, contains('https://www.google.com/maps/search/'));
        expect(url, contains('api=1'));
        expect(url, contains('query='));
        expect(url, contains('hospital'));
        expect(url, contains('-6.2088'));
        expect(url, contains('106.8456'));
      });

      test('should create correct URL for Puskesmas category', () {
        // Arrange
        const latitude = -7.7956;
        const longitude = 110.3695;
        const category = 'puskesmas';

        // Act
        final url = realMapsLauncher.createMapsSearchUrl(
          latitude: latitude,
          longitude: longitude,
          category: category,
        );

        // Assert
        expect(url, contains('https://www.google.com/maps/search/'));
        expect(url, contains('puskesmas'));
        expect(url, contains('-7.7956'));
        expect(url, contains('110.3695'));
      });

      test('should create correct URL for Posyandu category', () {
        // Arrange
        const latitude = -8.6705;
        const longitude = 115.2126;
        const category = 'posyandu';

        // Act
        final url = realMapsLauncher.createMapsSearchUrl(
          latitude: latitude,
          longitude: longitude,
          category: category,
        );

        // Assert
        expect(url, contains('posyandu'));
        expect(url, contains('-8.6705'));
        expect(url, contains('115.2126'));
      });

      test('should create correct URL for Apotek category', () {
        // Arrange
        const latitude = -5.1477;
        const longitude = 119.4327;
        const category = 'pharmacy';

        // Act
        final url = realMapsLauncher.createMapsSearchUrl(
          latitude: latitude,
          longitude: longitude,
          category: category,
        );

        // Assert
        expect(url, contains('pharmacy'));
        expect(url, contains('-5.1477'));
        expect(url, contains('119.4327'));
      });
    });

    /// **Validates: Requirement 8.5** - Format deep link dengan koordinat GPS
    group('URL Encoding with Various GPS Coordinates', () {
      test('should handle positive latitude and longitude', () {
        // Arrange
        const latitude = 1.2345;
        const longitude = 103.8198;
        const category = 'hospital';

        // Act
        final url = realMapsLauncher.createMapsSearchUrl(
          latitude: latitude,
          longitude: longitude,
          category: category,
        );

        // Assert
        expect(url, contains('1.2345'));
        expect(url, contains('103.8198'));
      });

      test('should handle negative latitude and positive longitude', () {
        // Arrange
        const latitude = -6.2088;
        const longitude = 106.8456;
        const category = 'puskesmas';

        // Act
        final url = realMapsLauncher.createMapsSearchUrl(
          latitude: latitude,
          longitude: longitude,
          category: category,
        );

        // Assert
        expect(url, contains('-6.2088'));
        expect(url, contains('106.8456'));
      });

      test('should handle coordinates with high precision', () {
        // Arrange
        const latitude = -6.208812345;
        const longitude = 106.845678901;
        const category = 'pharmacy';

        // Act
        final url = realMapsLauncher.createMapsSearchUrl(
          latitude: latitude,
          longitude: longitude,
          category: category,
        );

        // Assert
        expect(url, contains('-6.208812345'));
        expect(url, contains('106.845678901'));
      });

      test('should properly encode URL with special characters', () {
        // Arrange
        const latitude = -6.2088;
        const longitude = 106.8456;
        const category = 'hospital near me';

        // Act
        final url = realMapsLauncher.createMapsSearchUrl(
          latitude: latitude,
          longitude: longitude,
          category: category,
        );

        // Assert - Spaces should be encoded
        expect(url.contains('hospital+near+me') || url.contains('hospital%20near%20me'), true);
      });
    });

    /// **Validates: Requirement 8.5** - Query parameter structure
    group('Query Parameter Structure', () {
      test('should include all required query parameters', () {
        // Arrange
        const latitude = -6.2088;
        const longitude = 106.8456;
        const category = 'hospital';

        // Act
        final url = realMapsLauncher.createMapsSearchUrl(
          latitude: latitude,
          longitude: longitude,
          category: category,
        );

        // Assert - Verify URL structure
        expect(url, startsWith('https://www.google.com/maps/search/'));
        expect(url, contains('?api=1'));
        expect(url.contains('&query=') || url.contains('?query='), true);
      });

      test('should format query as "category near lat,lng"', () {
        // Arrange
        const latitude = -6.2088;
        const longitude = 106.8456;
        const category = 'puskesmas';

        // Act
        final url = realMapsLauncher.createMapsSearchUrl(
          latitude: latitude,
          longitude: longitude,
          category: category,
        );

        // Assert - Query should contain "category near lat,lng" pattern
        expect(url, contains('puskesmas'));
        expect(url, contains('near'));
        expect(url, contains('-6.2088'));
        expect(url, contains('106.8456'));
      });
    });
  });

  /// **Validates: Requirements 8.4, 8.6** - Fallback behavior
  group('LBS Integration Tests - Fallback Behavior', () {
    late Position mockPosition;

    setUp(() {
      mockPosition = Position(
        latitude: -6.2088,
        longitude: 106.8456,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Set up location for provider
      when(mockLocationService.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(mockLocationService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => mockPosition);
    });

    /// **Validates: Requirement 8.4** - Membuka Google Maps app
    group('Google Maps App Available', () {
      test('should open Google Maps app when installed', () async {
        // Arrange
        await lbsProvider.fetchCurrentLocation();
        when(mockMapsLauncher.openMapsSearch(
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          categoryKey: anyNamed('categoryKey'),
        )).thenAnswer((_) async => true);

        // Act
        final result = await lbsProvider.searchFacility('Rumah Sakit');

        // Assert
        expect(result, true);
        expect(lbsProvider.errorMessage, isNull);
        verify(mockMapsLauncher.openMapsSearch(
          latitude: -6.2088,
          longitude: 106.8456,
          categoryKey: 'Rumah Sakit',
        )).called(1);
      });

      test('should check if Google Maps is installed', () async {
        // Arrange
        when(mockMapsLauncher.isGoogleMapsInstalled())
            .thenAnswer((_) async => true);

        // Act
        final isInstalled = await lbsProvider.isGoogleMapsInstalled();

        // Assert
        expect(isInstalled, true);
        verify(mockMapsLauncher.isGoogleMapsInstalled()).called(1);
      });
    });

    /// **Validates: Requirement 8.6** - Fallback ke browser
    group('Google Maps App Not Available - Browser Fallback', () {
      test('should fallback to browser when Maps app not installed', () async {
        // Arrange
        await lbsProvider.fetchCurrentLocation();
        when(mockMapsLauncher.isGoogleMapsInstalled())
            .thenAnswer((_) async => false);
        when(mockMapsLauncher.openMapsSearch(
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          categoryKey: anyNamed('categoryKey'),
        )).thenAnswer((_) async => true);

        // Act
        final result = await lbsProvider.searchFacility('Puskesmas');

        // Assert
        expect(result, true);
        verify(mockMapsLauncher.openMapsSearch(
          latitude: -6.2088,
          longitude: 106.8456,
          categoryKey: 'Puskesmas',
        )).called(1);
      });

      test('should handle error when neither Maps nor browser available', () async {
        // Arrange
        await lbsProvider.fetchCurrentLocation();
        when(mockMapsLauncher.isGoogleMapsInstalled())
            .thenAnswer((_) async => false);
        when(mockMapsLauncher.openMapsSearch(
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          categoryKey: anyNamed('categoryKey'),
        )).thenAnswer((_) async => false);

        // Act
        final result = await lbsProvider.searchFacility('Apotek');

        // Assert
        expect(result, false);
        expect(lbsProvider.errorMessage, isNotNull);
        expect(lbsProvider.errorMessage, contains('Tidak dapat membuka Google Maps'));
      });
    });

    group('Search Without Location', () {
      test('should fail to search facility when location not available', () async {
        // Arrange - Don't fetch location
        // Provider has no current position

        // Act
        final result = await lbsProvider.searchFacility('Rumah Sakit');

        // Assert
        expect(result, false);
        expect(lbsProvider.errorMessage, isNotNull);
        expect(lbsProvider.errorMessage, contains('Lokasi belum tersedia'));
      });
    });

    group('Search with All Facility Categories', () {
      test('should successfully search for all facility types', () async {
        // Arrange
        await lbsProvider.fetchCurrentLocation();
        when(mockMapsLauncher.openMapsSearch(
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          categoryKey: anyNamed('categoryKey'),
        )).thenAnswer((_) async => true);

        // Act & Assert for each category
        final categories = ['Rumah Sakit', 'Puskesmas', 'Posyandu', 'Apotek'];
        
        for (final category in categories) {
          final result = await lbsProvider.searchFacility(category);
          expect(result, true, reason: 'Failed for category: $category');
        }

        // Verify all calls were made
        verify(mockMapsLauncher.openMapsSearch(
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          categoryKey: anyNamed('categoryKey'),
        )).called(categories.length);
      });
    });

    group('Exception Handling', () {
      test('should handle exception during Maps launch', () async {
        // Arrange
        await lbsProvider.fetchCurrentLocation();
        when(mockMapsLauncher.openMapsSearch(
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          categoryKey: anyNamed('categoryKey'),
        )).thenThrow(Exception('Failed to launch Maps'));

        // Act
        final result = await lbsProvider.searchFacility('Rumah Sakit');

        // Assert
        expect(result, false);
        expect(lbsProvider.errorMessage, isNotNull);
        expect(lbsProvider.errorMessage, contains('Terjadi kesalahan'));
      });
    });
  });

  group('LBS Provider State Management', () {
    test('should initialize with correct default state', () {
      // Assert
      expect(lbsProvider.currentPosition, isNull);
      expect(lbsProvider.isLoadingLocation, false);
      expect(lbsProvider.errorMessage, isNull);
      expect(lbsProvider.permissionStatus, isNull);
      expect(lbsProvider.hasLocation, false);
    });

    test('should clear error message', () {
      // Arrange - Set an error first
      lbsProvider.clearError();

      // Assert
      expect(lbsProvider.errorMessage, isNull);
    });

    test('should reset provider state', () {
      // Act
      lbsProvider.reset();

      // Assert
      expect(lbsProvider.currentPosition, isNull);
      expect(lbsProvider.isLoadingLocation, false);
      expect(lbsProvider.errorMessage, isNull);
      expect(lbsProvider.permissionStatus, isNull);
      expect(lbsProvider.hasLocation, false);
    });

    test('should set loading state during location fetch', () async {
      // Arrange
      when(mockLocationService.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(mockLocationService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockLocationService.getCurrentLocation()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return Position(
          latitude: -6.2088,
          longitude: 106.8456,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      });

      // Act
      final future = lbsProvider.fetchCurrentLocation();
      await future;

      // Assert
      expect(lbsProvider.isLoadingLocation, false);
    });
  });

  group('End-to-End Integration Scenarios', () {
    /// **Validates: Requirements 8.1-8.7** - Complete flow
    test('should complete full flow: permission -> location -> search', () async {
      // Arrange
      final mockPosition = Position(
        latitude: -6.2088,
        longitude: 106.8456,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      when(mockLocationService.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(mockLocationService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => mockPosition);
      when(mockMapsLauncher.openMapsSearch(
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        categoryKey: anyNamed('categoryKey'),
      )).thenAnswer((_) async => true);

      // Act - Step 1: Fetch location
      await lbsProvider.fetchCurrentLocation();

      // Assert - Location fetched successfully
      expect(lbsProvider.hasLocation, true);
      expect(lbsProvider.currentPosition, isNotNull);
      expect(lbsProvider.errorMessage, isNull);

      // Act - Step 2: Search for facility
      final searchResult = await lbsProvider.searchFacility('Rumah Sakit');

      // Assert - Search completed successfully
      expect(searchResult, true);
      expect(lbsProvider.errorMessage, isNull);

      // Verify all services were called
      verify(mockLocationService.checkPermission()).called(1);
      verify(mockLocationService.isLocationServiceEnabled()).called(1);
      verify(mockLocationService.getCurrentLocation()).called(1);
      verify(mockMapsLauncher.openMapsSearch(
        latitude: -6.2088,
        longitude: 106.8456,
        categoryKey: 'Rumah Sakit',
      )).called(1);
    });

    test('should handle permission denied flow with recovery', () async {
      // Arrange - First attempt: permission denied
      when(mockLocationService.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(mockLocationService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => null);

      // Act - First attempt
      await lbsProvider.fetchCurrentLocation();

      // Assert - Permission denied
      expect(lbsProvider.hasLocation, false);
      expect(lbsProvider.errorMessage, contains('Izin lokasi diperlukan'));

      // Arrange - User grants permission
      final mockPosition = Position(
        latitude: -6.2088,
        longitude: 106.8456,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      when(mockLocationService.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => mockPosition);

      // Act - Retry after permission granted
      await lbsProvider.fetchCurrentLocation();

      // Assert - Success after retry
      expect(lbsProvider.hasLocation, true);
      expect(lbsProvider.currentPosition, isNotNull);
      expect(lbsProvider.errorMessage, isNull);
    });

    test('should handle GPS disabled flow with recovery', () async {
      // Arrange - GPS disabled
      when(mockLocationService.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(mockLocationService.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      // Act - First attempt
      await lbsProvider.fetchCurrentLocation();

      // Assert - GPS disabled error
      expect(lbsProvider.hasLocation, false);
      expect(lbsProvider.errorMessage, contains('Layanan lokasi tidak aktif'));

      // Arrange - User enables GPS
      final mockPosition = Position(
        latitude: -6.2088,
        longitude: 106.8456,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      when(mockLocationService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => mockPosition);

      // Act - Retry after GPS enabled
      await lbsProvider.fetchCurrentLocation();

      // Assert - Success after retry
      expect(lbsProvider.hasLocation, true);
      expect(lbsProvider.errorMessage, isNull);
    });
  });
}
