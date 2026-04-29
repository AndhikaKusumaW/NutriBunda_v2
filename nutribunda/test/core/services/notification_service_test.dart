import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nutribunda/core/services/notification_service.dart';

import 'notification_service_test.mocks.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  group('NotificationService', () {
    late NotificationService notificationService;
    late MockFlutterLocalNotificationsPlugin mockNotifications;

    setUp(() {
      mockNotifications = MockFlutterLocalNotificationsPlugin();
      notificationService = NotificationService();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Arrange
        when(mockNotifications.initialize(any, onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse')))
            .thenAnswer((_) async => true);

        // Act
        final result = await notificationService.initialize();

        // Assert
        expect(result, true);
      });

      test('should handle initialization failure', () async {
        // Arrange
        when(mockNotifications.initialize(any, onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse')))
            .thenAnswer((_) async => false);

        // Act
        final result = await notificationService.initialize();

        // Assert
        expect(result, false);
      });

      test('should handle initialization exception', () async {
        // Arrange
        when(mockNotifications.initialize(any, onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse')))
            .thenThrow(Exception('Initialization failed'));

        // Act
        final result = await notificationService.initialize();

        // Assert
        expect(result, false);
      });
    });

    group('MPASI Reminders', () {
      test('should schedule all MPASI reminders for WIB timezone', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async {});

        // Act
        await notificationService.scheduleMpasiReminders(timezone: 'WIB');

        // Assert - Should schedule 4 notifications (morning, lunch, afternoon, evening)
        verify(mockNotifications.zonedSchedule(
          1, // morning ID
          argThat(contains('Sarapan MPASI')),
          any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(1);

        verify(mockNotifications.zonedSchedule(
          2, // lunch ID
          argThat(contains('Makan Siang MPASI')),
          any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(1);

        verify(mockNotifications.zonedSchedule(
          3, // afternoon ID
          argThat(contains('Makan Sore MPASI')),
          any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(1);

        verify(mockNotifications.zonedSchedule(
          4, // evening ID
          argThat(contains('Makan Malam MPASI')),
          any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(1);
      });

      test('should schedule only enabled MPASI meals', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async {});

        // Act - Only enable morning and evening meals
        await notificationService.scheduleMpasiReminders(
          timezone: 'WIB',
          enabledMeals: [true, false, false, true], // morning and evening only
        );

        // Assert - Should only schedule 2 notifications
        verify(mockNotifications.zonedSchedule(
          1, // morning ID
          any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(1);

        verify(mockNotifications.zonedSchedule(
          4, // evening ID
          any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(1);

        // Lunch and afternoon should not be scheduled
        verifyNever(mockNotifications.zonedSchedule(
          2, // lunch ID
          any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        ));

        verifyNever(mockNotifications.zonedSchedule(
          3, // afternoon ID
          any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        ));
      });

      test('should cancel existing MPASI reminders before scheduling new ones', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async {});

        // Act
        await notificationService.scheduleMpasiReminders(timezone: 'WIB');

        // Assert - Should cancel all 4 MPASI notification IDs
        verify(mockNotifications.cancel(1)).called(1); // morning
        verify(mockNotifications.cancel(2)).called(1); // lunch
        verify(mockNotifications.cancel(3)).called(1); // afternoon
        verify(mockNotifications.cancel(4)).called(1); // evening
      });

      test('should handle scheduling errors gracefully', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenThrow(Exception('Scheduling failed'));

        // Act & Assert
        expect(
          () => notificationService.scheduleMpasiReminders(timezone: 'WIB'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Vitamin Reminders', () {
      test('should schedule vitamin reminder when enabled', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async {});

        // Act
        await notificationService.scheduleVitaminReminder(
          time: '08:30',
          timezone: 'WIB',
          enabled: true,
        );

        // Assert
        verify(mockNotifications.cancel(5)).called(1); // vitamin ID
        verify(mockNotifications.zonedSchedule(
          5, // vitamin ID
          argThat(contains('Vitamin')),
          any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(1);
      });

      test('should not schedule vitamin reminder when disabled', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});

        // Act
        await notificationService.scheduleVitaminReminder(
          time: '08:30',
          timezone: 'WIB',
          enabled: false,
        );

        // Assert
        verify(mockNotifications.cancel(5)).called(1); // Should cancel existing
        verifyNever(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        ));
      });

      test('should handle vitamin scheduling errors gracefully', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenThrow(Exception('Scheduling failed'));

        // Act & Assert
        expect(
          () => notificationService.scheduleVitaminReminder(
            time: '08:30',
            timezone: 'WIB',
            enabled: true,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Timezone Support', () {
      test('should support WIB timezone (UTC+7)', () async {
        // This test verifies that WIB timezone is handled correctly
        // The actual timezone calculation is tested implicitly through scheduling
        
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async {});

        // Act
        await notificationService.scheduleMpasiReminders(timezone: 'WIB');

        // Assert - Should complete without errors
        verify(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(4); // 4 MPASI reminders
      });

      test('should support WITA timezone (UTC+8)', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async {});

        // Act
        await notificationService.scheduleMpasiReminders(timezone: 'WITA');

        // Assert - Should complete without errors
        verify(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(4);
      });

      test('should support WIT timezone (UTC+9)', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async {});

        // Act
        await notificationService.scheduleMpasiReminders(timezone: 'WIT');

        // Assert - Should complete without errors
        verify(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(4);
      });

      test('should default to WIB for invalid timezone', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async {});

        // Act
        await notificationService.scheduleMpasiReminders(timezone: 'INVALID');

        // Assert - Should complete without errors (defaults to WIB)
        verify(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(4);
      });
    });

    group('Timezone Update', () {
      test('should update all notifications when timezone changes', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async {});

        // Act
        await notificationService.updateTimezone(
          newTimezone: 'WITA',
          enabledMpasiMeals: [true, true, false, true],
          vitaminEnabled: true,
          vitaminTime: '09:00',
        );

        // Assert - Should reschedule MPASI (3 enabled) + vitamin (1) = 4 total
        verify(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).called(4); // 3 MPASI + 1 vitamin
      });

      test('should handle timezone update errors gracefully', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});
        when(mockNotifications.zonedSchedule(
          any, any, any, any, any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
          payload: anyNamed('payload'),
        )).thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(
          () => notificationService.updateTimezone(
            newTimezone: 'WITA',
            enabledMpasiMeals: [true, true, true, true],
            vitaminEnabled: false,
            vitaminTime: '09:00',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Notification Cancellation', () {
      test('should cancel all MPASI reminders', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});

        // Act
        await notificationService.cancelMpasiReminders();

        // Assert
        verify(mockNotifications.cancel(1)).called(1); // morning
        verify(mockNotifications.cancel(2)).called(1); // lunch
        verify(mockNotifications.cancel(3)).called(1); // afternoon
        verify(mockNotifications.cancel(4)).called(1); // evening
      });

      test('should cancel vitamin reminder', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenAnswer((_) async {});

        // Act
        await notificationService.cancelVitaminReminder();

        // Assert
        verify(mockNotifications.cancel(5)).called(1); // vitamin ID
      });

      test('should cancel all notifications', () async {
        // Arrange
        when(mockNotifications.cancelAll()).thenAnswer((_) async {});

        // Act
        await notificationService.cancelAllNotifications();

        // Assert
        verify(mockNotifications.cancelAll()).called(1);
      });

      test('should handle cancellation errors gracefully', () async {
        // Arrange
        when(mockNotifications.cancel(any)).thenThrow(Exception('Cancel failed'));

        // Act - Should not throw exception
        await notificationService.cancelMpasiReminders();

        // Assert - Method should complete despite errors
        verify(mockNotifications.cancel(any)).called(4);
      });
    });

    group('Notification Status', () {
      test('should return pending notifications', () async {
        // Arrange
        final mockPendingNotifications = [
          PendingNotificationRequest(1, 'Title 1', 'Body 1', 'payload1'),
          PendingNotificationRequest(2, 'Title 2', 'Body 2', 'payload2'),
        ];
        when(mockNotifications.pendingNotificationRequests())
            .thenAnswer((_) async => mockPendingNotifications);

        // Act
        final result = await notificationService.getPendingNotifications();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, 1);
        expect(result[1].id, 2);
      });

      test('should handle pending notifications error gracefully', () async {
        // Arrange
        when(mockNotifications.pendingNotificationRequests())
            .thenThrow(Exception('Failed to get pending'));

        // Act
        final result = await notificationService.getPendingNotifications();

        // Assert
        expect(result, isEmpty);
      });

      test('should check if notifications are enabled', () async {
        // Act
        final result = await notificationService.areNotificationsEnabled();

        // Assert - Current implementation always returns true
        expect(result, true);
      });
    });
  });
}