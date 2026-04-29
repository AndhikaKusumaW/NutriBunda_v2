import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutribunda/presentation/providers/notification_provider.dart';
import 'package:nutribunda/core/services/notification_service.dart';

import 'notification_provider_simple_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NotificationService>(), MockSpec<SharedPreferences>()])
void main() {
  group('NotificationProvider - Core Functionality', () {
    late NotificationProvider notificationProvider;
    late MockNotificationService mockNotificationService;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockNotificationService = MockNotificationService();
      mockPrefs = MockSharedPreferences();
      notificationProvider = NotificationProvider(
        notificationService: mockNotificationService,
        prefs: mockPrefs,
      );
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        // Assert
        expect(notificationProvider.mpasiEnabled, true);
        expect(notificationProvider.mpasiMeals, [true, true, true, true]);
        expect(notificationProvider.vitaminEnabled, false);
        expect(notificationProvider.vitaminTime, '08:00');
        expect(notificationProvider.timezone, 'WIB');
        expect(notificationProvider.permissionGranted, false);
        expect(notificationProvider.isInitialized, false);
      });

      test('should have correct meal names', () {
        // Assert
        expect(notificationProvider.mealNames, hasLength(4));
        expect(notificationProvider.mealNames[0], contains('Sarapan'));
        expect(notificationProvider.mealNames[1], contains('Makan Siang'));
        expect(notificationProvider.mealNames[2], contains('Makan Sore'));
        expect(notificationProvider.mealNames[3], contains('Makan Malam'));
      });

      test('should have correct timezone options', () {
        // Assert
        expect(notificationProvider.timezoneOptions, ['WIB', 'WITA', 'WIT']);
        
        final descriptions = notificationProvider.timezoneDescriptions;
        expect(descriptions['WIB'], contains('UTC+7'));
        expect(descriptions['WITA'], contains('UTC+8'));
        expect(descriptions['WIT'], contains('UTC+9'));
      });
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Arrange
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);

        // Act
        await notificationProvider.initialize();

        // Assert
        expect(notificationProvider.isInitialized, true);
        expect(notificationProvider.permissionGranted, true);
        expect(notificationProvider.isLoading, false);
        expect(notificationProvider.hasError, false);
      });

      test('should handle initialization failure', () async {
        // Arrange
        when(mockNotificationService.initialize()).thenAnswer((_) async => false);

        // Act
        await notificationProvider.initialize();

        // Assert
        expect(notificationProvider.isInitialized, false);
        expect(notificationProvider.hasError, true);
        expect(notificationProvider.errorMessage, contains('Gagal menginisialisasi'));
      });
    });

    group('Permission Management', () {
      test('should request permissions successfully', () async {
        // Arrange
        when(mockNotificationService.requestPermissions()).thenAnswer((_) async => true);

        // Act
        final result = await notificationProvider.requestPermissions();

        // Assert
        expect(result, true);
        expect(notificationProvider.permissionGranted, true);
      });

      test('should handle permission denial', () async {
        // Arrange
        when(mockNotificationService.requestPermissions()).thenAnswer((_) async => false);

        // Act
        final result = await notificationProvider.requestPermissions();

        // Assert
        expect(result, false);
        expect(notificationProvider.permissionGranted, false);
      });
    });

    group('Notification Summary', () {
      test('should return permission message when not granted', () {
        // Act
        final summary = notificationProvider.getNotificationSummary();

        // Assert
        expect(summary, 'Izin notifikasi belum diberikan');
      });

      test('should return summary with timezone', () async {
        // Arrange - Initialize with permission granted
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);

        await notificationProvider.initialize();

        // Act
        final summary = notificationProvider.getNotificationSummary();

        // Assert
        expect(summary, contains('WIB')); // Should contain timezone
      });
    });

    group('Utility Methods', () {
      test('should validate time format correctly', () {
        // Act & Assert
        expect(notificationProvider.isValidTimeFormat('08:30'), true);
        expect(notificationProvider.isValidTimeFormat('23:59'), true);
        expect(notificationProvider.isValidTimeFormat('00:00'), true);
        expect(notificationProvider.isValidTimeFormat('24:00'), false);
        expect(notificationProvider.isValidTimeFormat('08:60'), false);
        expect(notificationProvider.isValidTimeFormat('8:30'), true); // Single digit hour
        expect(notificationProvider.isValidTimeFormat('invalid'), false);
        expect(notificationProvider.isValidTimeFormat(''), false);
      });

      test('should format time for display correctly', () {
        // Act & Assert
        expect(notificationProvider.formatTimeForDisplay('8:5'), '08:05');
        expect(notificationProvider.formatTimeForDisplay('23:59'), '23:59');
        expect(notificationProvider.formatTimeForDisplay('invalid'), 'invalid');
      });

      test('should get pending notifications count', () async {
        // Arrange
        when(mockNotificationService.getPendingNotifications()).thenAnswer((_) async => []);

        // Act
        final count = await notificationProvider.getPendingNotificationsCount();

        // Assert
        expect(count, 0);
      });

      test('should handle pending notifications error', () async {
        // Arrange
        when(mockNotificationService.getPendingNotifications())
            .thenThrow(Exception('Failed'));

        // Act
        final count = await notificationProvider.getPendingNotificationsCount();

        // Assert
        expect(count, 0); // Should return 0 on error
      });
    });

    group('State Management', () {
      test('should toggle meal states correctly', () async {
        // Arrange - Initialize first
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);

        await notificationProvider.initialize();

        // Act - Toggle specific meal (index 1 = lunch)
        await notificationProvider.toggleMpasiMeal(1, false);

        // Assert
        expect(notificationProvider.mpasiMeals[1], false);
        expect(notificationProvider.mpasiMeals[0], true); // Others unchanged
        expect(notificationProvider.mpasiMeals[2], true);
        expect(notificationProvider.mpasiMeals[3], true);
      });

      test('should ignore invalid meal index', () async {
        // Arrange - Initialize first
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);

        await notificationProvider.initialize();

        // Act
        await notificationProvider.toggleMpasiMeal(5, false); // Invalid index

        // Assert - Should not change anything
        expect(notificationProvider.mpasiMeals, [true, true, true, true]);
      });

      test('should ignore invalid timezone', () async {
        // Arrange - Initialize first
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);

        await notificationProvider.initialize();

        // Act
        await notificationProvider.changeTimezone('INVALID');

        // Assert
        expect(notificationProvider.timezone, 'WIB'); // Should remain unchanged
      });
    });

    group('Error Handling', () {
      test('should handle service errors gracefully', () async {
        // Arrange
        when(mockNotificationService.initialize()).thenThrow(Exception('Service error'));

        // Act
        await notificationProvider.initialize();

        // Assert
        expect(notificationProvider.hasError, true);
        expect(notificationProvider.isInitialized, false);
      });
    });
  });
}