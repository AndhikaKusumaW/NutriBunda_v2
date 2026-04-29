import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutribunda/presentation/providers/notification_provider.dart';
import 'package:nutribunda/core/services/notification_service.dart';

import 'notification_provider_test.mocks.dart';

@GenerateMocks([NotificationService, SharedPreferences])
void main() {
  group('NotificationProvider', () {
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
        expect(notificationProvider.mealNames, hasLength(4));
        expect(notificationProvider.timezoneOptions, ['WIB', 'WITA', 'WIT']);
      });

      test('should have correct meal names', () {
        // Assert
        expect(notificationProvider.mealNames[0], contains('Sarapan'));
        expect(notificationProvider.mealNames[1], contains('Makan Siang'));
        expect(notificationProvider.mealNames[2], contains('Makan Sore'));
        expect(notificationProvider.mealNames[3], contains('Makan Malam'));
      });

      test('should have correct timezone descriptions', () {
        // Assert
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
        when(mockPrefs.getBool(any)).thenReturn(null);
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});

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

      test('should load saved preferences during initialization', () async {
        // Arrange
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
        when(mockPrefs.getBool('mpasi_notifications_enabled')).thenReturn(false);
        when(mockPrefs.getBool('mpasi_morning_enabled')).thenReturn(false);
        when(mockPrefs.getBool('mpasi_lunch_enabled')).thenReturn(true);
        when(mockPrefs.getBool('mpasi_afternoon_enabled')).thenReturn(false);
        when(mockPrefs.getBool('mpasi_evening_enabled')).thenReturn(true);
        when(mockPrefs.getBool('vitamin_notification_enabled')).thenReturn(true);
        when(mockPrefs.getString('vitamin_notification_time')).thenReturn('09:30');
        when(mockPrefs.getString('notification_timezone')).thenReturn('WITA');
        when(mockPrefs.getBool('notification_permission_granted')).thenReturn(true);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});
        when(mockNotificationService.scheduleVitaminReminder(
          time: anyNamed('time'),
          timezone: anyNamed('timezone'),
          enabled: anyNamed('enabled'),
        )).thenAnswer((_) async {});

        // Act
        await notificationProvider.initialize();

        // Assert
        expect(notificationProvider.mpasiEnabled, false);
        expect(notificationProvider.mpasiMeals, [false, true, false, true]);
        expect(notificationProvider.vitaminEnabled, true);
        expect(notificationProvider.vitaminTime, '09:30');
        expect(notificationProvider.timezone, 'WITA');
        expect(notificationProvider.permissionGranted, true);
      });

      test('should schedule active notifications when permission granted', () async {
        // Arrange
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
        when(mockPrefs.getBool(any)).thenReturn(null);
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});

        // Act
        await notificationProvider.initialize();

        // Assert
        verify(mockNotificationService.scheduleMpasiReminders(
          timezone: 'WIB',
          enabledMeals: [true, true, true, true],
        )).called(1);
      });
    });

    group('Permission Management', () {
      test('should request permissions successfully', () async {
        // Arrange
        when(mockNotificationService.requestPermissions()).thenAnswer((_) async => true);
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});

        // Act
        final result = await notificationProvider.requestPermissions();

        // Assert
        expect(result, true);
        expect(notificationProvider.permissionGranted, true);
        verify(mockPrefs.setBool('notification_permission_granted', true)).called(1);
        verify(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).called(1);
      });

      test('should handle permission denial', () async {
        // Arrange
        when(mockNotificationService.requestPermissions()).thenAnswer((_) async => false);
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);

        // Act
        final result = await notificationProvider.requestPermissions();

        // Assert
        expect(result, false);
        expect(notificationProvider.permissionGranted, false);
        verify(mockPrefs.setBool('notification_permission_granted', false)).called(1);
      });
    });

    group('MPASI Notifications', () {
      setUp(() async {
        // Initialize provider first
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
        when(mockPrefs.getBool(any)).thenReturn(null);
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});

        await notificationProvider.initialize();
      });

      test('should toggle MPASI notifications on', () async {
        // Arrange
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});

        // Act
        await notificationProvider.toggleMpasiNotifications(true);

        // Assert
        expect(notificationProvider.mpasiEnabled, true);
        verify(mockPrefs.setBool('mpasi_notifications_enabled', true)).called(1);
        verify(mockNotificationService.scheduleMpasiReminders(
          timezone: 'WIB',
          enabledMeals: [true, true, true, true],
        )).called(1);
      });

      test('should toggle MPASI notifications off', () async {
        // Arrange
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
        when(mockNotificationService.cancelMpasiReminders()).thenAnswer((_) async {});

        // Act
        await notificationProvider.toggleMpasiNotifications(false);

        // Assert
        expect(notificationProvider.mpasiEnabled, false);
        verify(mockPrefs.setBool('mpasi_notifications_enabled', false)).called(1);
        verify(mockNotificationService.cancelMpasiReminders()).called(1);
      });

      test('should toggle specific MPASI meal', () async {
        // Arrange
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});

        // Act - Disable lunch (index 1)
        await notificationProvider.toggleMpasiMeal(1, false);

        // Assert
        expect(notificationProvider.mpasiMeals[1], false);
        expect(notificationProvider.mpasiMeals[0], true); // Others unchanged
        expect(notificationProvider.mpasiMeals[2], true);
        expect(notificationProvider.mpasiMeals[3], true);
        verify(mockPrefs.setBool('mpasi_lunch_enabled', false)).called(1);
        verify(mockNotificationService.scheduleMpasiReminders(
          timezone: 'WIB',
          enabledMeals: [true, false, true, true],
        )).called(1);
      });

      test('should ignore invalid meal index', () async {
        // Act
        await notificationProvider.toggleMpasiMeal(5, false); // Invalid index

        // Assert - Should not change anything
        expect(notificationProvider.mpasiMeals, [true, true, true, true]);
        verifyNever(mockPrefs.setBool(any, any));
      });

      test('should not schedule when permission not granted', () async {
        // Arrange - Set permission to false
        notificationProvider.requestPermissions(); // This will set permission based on mock
        when(mockNotificationService.requestPermissions()).thenAnswer((_) async => false);
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);

        await notificationProvider.requestPermissions(); // Set permission to false

        // Act
        await notificationProvider.toggleMpasiNotifications(true);

        // Assert
        expect(notificationProvider.mpasiEnabled, true);
        verifyNever(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        ));
      });
    });

    group('Vitamin Notifications', () {
      setUp(() async {
        // Initialize provider first
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
        when(mockPrefs.getBool(any)).thenReturn(null);
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});

        await notificationProvider.initialize();
      });

      test('should toggle vitamin notifications on', () async {
        // Arrange
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
        when(mockNotificationService.scheduleVitaminReminder(
          time: anyNamed('time'),
          timezone: anyNamed('timezone'),
          enabled: anyNamed('enabled'),
        )).thenAnswer((_) async {});

        // Act
        await notificationProvider.toggleVitaminNotifications(true);

        // Assert
        expect(notificationProvider.vitaminEnabled, true);
        verify(mockPrefs.setBool('vitamin_notification_enabled', true)).called(1);
        verify(mockNotificationService.scheduleVitaminReminder(
          time: '08:00',
          timezone: 'WIB',
          enabled: true,
        )).called(1);
      });

      test('should toggle vitamin notifications off', () async {
        // Arrange
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
        when(mockNotificationService.scheduleVitaminReminder(
          time: anyNamed('time'),
          timezone: anyNamed('timezone'),
          enabled: anyNamed('enabled'),
        )).thenAnswer((_) async {});

        // Act
        await notificationProvider.toggleVitaminNotifications(false);

        // Assert
        expect(notificationProvider.vitaminEnabled, false);
        verify(mockPrefs.setBool('vitamin_notification_enabled', false)).called(1);
        verify(mockNotificationService.scheduleVitaminReminder(
          time: '08:00',
          timezone: 'WIB',
          enabled: false,
        )).called(1);
      });

      test('should set vitamin time', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockNotificationService.scheduleVitaminReminder(
          time: anyNamed('time'),
          timezone: anyNamed('timezone'),
          enabled: anyNamed('enabled'),
        )).thenAnswer((_) async {});

        // Enable vitamin notifications first
        await notificationProvider.toggleVitaminNotifications(true);

        // Act
        await notificationProvider.setVitaminTime('10:30');

        // Assert
        expect(notificationProvider.vitaminTime, '10:30');
        verify(mockPrefs.setString('vitamin_notification_time', '10:30')).called(1);
        verify(mockNotificationService.scheduleVitaminReminder(
          time: '10:30',
          timezone: 'WIB',
          enabled: true,
        )).called(1);
      });

      test('should not schedule vitamin when disabled', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

        // Act - Set time while vitamin notifications are disabled
        await notificationProvider.setVitaminTime('10:30');

        // Assert
        expect(notificationProvider.vitaminTime, '10:30');
        verifyNever(mockNotificationService.scheduleVitaminReminder(
          time: anyNamed('time'),
          timezone: anyNamed('timezone'),
          enabled: anyNamed('enabled'),
        ));
      });
    });

    group('Timezone Management', () {
      setUp(() async {
        // Initialize provider first
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
        when(mockPrefs.getBool(any)).thenReturn(null);
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});

        await notificationProvider.initialize();
      });

      test('should change timezone successfully', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockNotificationService.updateTimezone(
          newTimezone: anyNamed('newTimezone'),
          enabledMpasiMeals: anyNamed('enabledMpasiMeals'),
          vitaminEnabled: anyNamed('vitaminEnabled'),
          vitaminTime: anyNamed('vitaminTime'),
        )).thenAnswer((_) async {});

        // Act
        await notificationProvider.changeTimezone('WITA');

        // Assert
        expect(notificationProvider.timezone, 'WITA');
        verify(mockPrefs.setString('notification_timezone', 'WITA')).called(1);
        verify(mockNotificationService.updateTimezone(
          newTimezone: 'WITA',
          enabledMpasiMeals: [true, true, true, true],
          vitaminEnabled: false,
          vitaminTime: '08:00',
        )).called(1);
      });

      test('should ignore invalid timezone', () async {
        // Act
        await notificationProvider.changeTimezone('INVALID');

        // Assert
        expect(notificationProvider.timezone, 'WIB'); // Should remain unchanged
        verifyNever(mockPrefs.setString(any, any));
        verifyNever(mockNotificationService.updateTimezone(
          newTimezone: anyNamed('newTimezone'),
          enabledMpasiMeals: anyNamed('enabledMpasiMeals'),
          vitaminEnabled: anyNamed('vitaminEnabled'),
          vitaminTime: anyNamed('vitaminTime'),
        ));
      });

      test('should handle timezone update error', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockNotificationService.updateTimezone(
          newTimezone: anyNamed('newTimezone'),
          enabledMpasiMeals: anyNamed('enabledMpasiMeals'),
          vitaminEnabled: anyNamed('vitaminEnabled'),
          vitaminTime: anyNamed('vitaminTime'),
        )).thenThrow(Exception('Update failed'));

        // Act
        await notificationProvider.changeTimezone('WITA');

        // Assert
        expect(notificationProvider.hasError, true);
        expect(notificationProvider.errorMessage, contains('Update failed'));
      });
    });

    group('Notification Summary', () {
      test('should return permission message when not granted', () {
        // Act
        final summary = notificationProvider.getNotificationSummary();

        // Assert
        expect(summary, 'Izin notifikasi belum diberikan');
      });

      test('should return no active notifications message', () async {
        // Arrange - Initialize with permission but disable all notifications
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
        when(mockPrefs.getBool('mpasi_notifications_enabled')).thenReturn(false);
        when(mockPrefs.getBool('vitamin_notification_enabled')).thenReturn(false);
        when(mockPrefs.getBool(any)).thenReturn(null);
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});

        await notificationProvider.initialize();

        // Act
        final summary = notificationProvider.getNotificationSummary();

        // Assert
        expect(summary, 'Tidak ada notifikasi aktif');
      });

      test('should return active notifications summary', () async {
        // Arrange - Initialize with some active notifications
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
        when(mockPrefs.getBool('mpasi_notifications_enabled')).thenReturn(true);
        when(mockPrefs.getBool('mpasi_morning_enabled')).thenReturn(true);
        when(mockPrefs.getBool('mpasi_lunch_enabled')).thenReturn(false);
        when(mockPrefs.getBool('mpasi_afternoon_enabled')).thenReturn(true);
        when(mockPrefs.getBool('mpasi_evening_enabled')).thenReturn(false);
        when(mockPrefs.getBool('vitamin_notification_enabled')).thenReturn(true);
        when(mockPrefs.getString('vitamin_notification_time')).thenReturn('09:00');
        when(mockPrefs.getString('notification_timezone')).thenReturn('WITA');
        when(mockPrefs.getBool(any)).thenReturn(null);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});
        when(mockNotificationService.scheduleVitaminReminder(
          time: anyNamed('time'),
          timezone: anyNamed('timezone'),
          enabled: anyNamed('enabled'),
        )).thenAnswer((_) async {});

        await notificationProvider.initialize();

        // Act
        final summary = notificationProvider.getNotificationSummary();

        // Assert
        expect(summary, contains('MPASI (2 jadwal)'));
        expect(summary, contains('Vitamin (09:00)'));
        expect(summary, contains('WITA'));
      });
    });

    group('Utility Methods', () {
      test('should cancel all notifications', () async {
        // Arrange
        when(mockNotificationService.cancelAllNotifications()).thenAnswer((_) async {});
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);

        // Act
        await notificationProvider.cancelAllNotifications();

        // Assert
        expect(notificationProvider.mpasiEnabled, false);
        expect(notificationProvider.vitaminEnabled, false);
        expect(notificationProvider.mpasiMeals, [false, false, false, false]);
        verify(mockNotificationService.cancelAllNotifications()).called(1);
      });

      test('should get pending notifications count', () async {
        // Arrange
        when(mockNotificationService.getPendingNotifications()).thenAnswer((_) async => [
          // Mock pending notifications would go here
        ]);

        // Act
        final count = await notificationProvider.getPendingNotificationsCount();

        // Assert
        expect(count, 0); // Empty list
        verify(mockNotificationService.getPendingNotifications()).called(1);
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

      test('should reset to defaults', () async {
        // Arrange
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockNotificationService.scheduleMpasiReminders(
          timezone: anyNamed('timezone'),
          enabledMeals: anyNamed('enabledMeals'),
        )).thenAnswer((_) async {});

        // Initialize with permission granted
        when(mockNotificationService.initialize()).thenAnswer((_) async => true);
        when(mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
        when(mockPrefs.getBool(any)).thenReturn(null);
        when(mockPrefs.getString(any)).thenReturn(null);

        await notificationProvider.initialize();

        // Act
        await notificationProvider.resetToDefaults();

        // Assert
        expect(notificationProvider.mpasiEnabled, true);
        expect(notificationProvider.mpasiMeals, [true, true, true, true]);
        expect(notificationProvider.vitaminEnabled, false);
        expect(notificationProvider.vitaminTime, '08:00');
        expect(notificationProvider.timezone, 'WIB');
      });

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
    });
  });
}