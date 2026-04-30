import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import 'dart:io';

/// Service untuk mengelola notifikasi lokal dengan dukungan timezone
/// Menangani pengingat MPASI dan vitamin sesuai Requirements 11.1-11.6
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int _mpasiMorningId = 1;
  static const int _mpasiLunchId = 2;
  static const int _mpasiAfternoonId = 3;
  static const int _mpasiEveningId = 4;
  static const int _vitaminReminderId = 5;

  // Channel IDs
  static const String _mpasiChannelId = 'mpasi_reminders';
  static const String _vitaminChannelId = 'vitamin_reminders';

  // Default MPASI times (Requirements 11.1)
  static const List<String> _defaultMpasiTimes = [
    '07:00', // Pagi
    '12:00', // Siang
    '17:00', // Sore
    '19:00', // Malam
  ];

  /// Initialize notification service
  /// Requirements: 11.6 - Handle notification permissions properly
  Future<bool> initialize() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final bool? initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        await _createNotificationChannels();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
      return false;
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // MPASI channel
    const AndroidNotificationChannel mpasiChannel = AndroidNotificationChannel(
      _mpasiChannelId,
      'Pengingat MPASI',
      description: 'Notifikasi pengingat jadwal makan MPASI bayi',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Vitamin channel
    const AndroidNotificationChannel vitaminChannel = AndroidNotificationChannel(
      _vitaminChannelId,
      'Pengingat Vitamin',
      description: 'Notifikasi pengingat minum vitamin ibu',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(mpasiChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(vitaminChannel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on notification type
  }

  /// Request notification permissions
  /// Requirements: 11.6 - Handle notification permissions properly
  Future<bool> requestPermissions() async {
    try {
      // Request Android exact alarm permission
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final bool? granted =
            await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      // Request iOS permission
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final bool? granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Schedule MPASI meal reminders
  /// Requirements: 11.1 - Send local notifications for MPASI meal reminders at default times
  /// Requirements: 11.3 - Allow users to select timezone (WIB, WITA, WIT)
  /// Requirements: 11.4 - Adjust all notification times when timezone is changed
  Future<void> scheduleMpasiReminders({
    required String timezone,
    List<bool>? enabledMeals, // [morning, lunch, afternoon, evening]
  }) async {
    try {
      // Cancel existing MPASI notifications
      await cancelMpasiReminders();

      final List<bool> mealsEnabled = enabledMeals ?? [true, true, true, true];
      final List<int> notificationIds = [
        _mpasiMorningId,
        _mpasiLunchId,
        _mpasiAfternoonId,
        _mpasiEveningId,
      ];

      final List<String> mealNames = [
        'Sarapan MPASI',
        'Makan Siang MPASI',
        'Makan Sore MPASI',
        'Makan Malam MPASI',
      ];

      for (int i = 0; i < _defaultMpasiTimes.length; i++) {
        if (mealsEnabled[i]) {
          await _scheduleRepeatingNotification(
            id: notificationIds[i],
            title: 'Waktu ${mealNames[i]}! 🍼',
            body: 'Saatnya memberikan makan untuk si kecil',
            time: _defaultMpasiTimes[i],
            timezone: timezone,
            channelId: _mpasiChannelId,
            payload: 'mpasi_${i}',
          );
        }
      }

      debugPrint('MPASI reminders scheduled for timezone: $timezone');
    } catch (e) {
      debugPrint('Error scheduling MPASI reminders: $e');
      throw Exception('Gagal mengatur pengingat MPASI: $e');
    }
  }

  /// Schedule vitamin reminder
  /// Requirements: 11.2 - Send local notifications for vitamin reminders at user-configurable times
  /// Requirements: 11.3 - Allow users to select timezone (WIB, WITA, WIT)
  Future<void> scheduleVitaminReminder({
    required String time, // Format: "HH:mm"
    required String timezone,
    bool enabled = true,
  }) async {
    try {
      // Cancel existing vitamin notification
      await _notifications.cancel(_vitaminReminderId);

      if (enabled) {
        await _scheduleRepeatingNotification(
          id: _vitaminReminderId,
          title: 'Waktu Minum Vitamin! 💊',
          body: 'Jangan lupa minum vitamin untuk kesehatan Anda',
          time: time,
          timezone: timezone,
          channelId: _vitaminChannelId,
          payload: 'vitamin',
        );

        debugPrint('Vitamin reminder scheduled at $time for timezone: $timezone');
      }
    } catch (e) {
      debugPrint('Error scheduling vitamin reminder: $e');
      throw Exception('Gagal mengatur pengingat vitamin: $e');
    }
  }

  /// Schedule a repeating notification
  Future<void> _scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required String time, // Format: "HH:mm"
    required String timezone,
    required String channelId,
    String? payload,
  }) async {
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Get timezone location
      final tz.Location location = _getTimezoneLocation(timezone);

      // Calculate next occurrence
      final tz.TZDateTime scheduledDate = _nextInstanceOfTime(
        hour,
        minute,
        location,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _mpasiChannelId,
          'Pengingat MPASI',
          channelDescription: 'Notifikasi pengingat jadwal makan MPASI bayi',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint('Scheduled notification $id at $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  /// Get timezone location
  /// Requirements: 11.3 - Support timezone selection: WIB (UTC+7), WITA (UTC+8), WIT (UTC+9), London (UTC+0/+1)
  tz.Location _getTimezoneLocation(String timezone) {
    switch (timezone.toUpperCase()) {
      case 'WIB':
        return tz.getLocation('Asia/Jakarta'); // UTC+7
      case 'WITA':
        return tz.getLocation('Asia/Makassar'); // UTC+8
      case 'WIT':
        return tz.getLocation('Asia/Jayapura'); // UTC+9
      case 'LONDON':
        return tz.getLocation('Europe/London'); // UTC+0 / UTC+1 (BST)
      default:
        return tz.getLocation('Asia/Jakarta'); // Default to WIB
    }
  }

  /// Calculate next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, tz.Location location) {
    final tz.TZDateTime now = tz.TZDateTime.now(location);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Cancel MPASI reminders
  /// Requirements: 11.5 - Allow users to enable/disable specific notifications
  Future<void> cancelMpasiReminders() async {
    try {
      await _notifications.cancel(_mpasiMorningId);
      await _notifications.cancel(_mpasiLunchId);
      await _notifications.cancel(_mpasiAfternoonId);
      await _notifications.cancel(_mpasiEveningId);
      debugPrint('MPASI reminders cancelled');
    } catch (e) {
      debugPrint('Error cancelling MPASI reminders: $e');
    }
  }

  /// Cancel vitamin reminder
  /// Requirements: 11.5 - Allow users to enable/disable specific notifications
  Future<void> cancelVitaminReminder() async {
    try {
      await _notifications.cancel(_vitaminReminderId);
      debugPrint('Vitamin reminder cancelled');
    } catch (e) {
      debugPrint('Error cancelling vitamin reminder: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          final granted = await androidPlugin.areNotificationsEnabled();
          return granted ?? false;
        }
      } else if (Platform.isIOS) {
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        // Unfortunately iOS doesn't provide a direct synchronous check in this plugin easily
        // without requesting, but we can assume it's handled by requestPermissions
        return true; 
      }
      return true;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }

  /// Update timezone for all active notifications
  /// Requirements: 11.4 - Adjust all notification times when timezone is changed
  Future<void> updateTimezone({
    required String newTimezone,
    required List<bool> enabledMpasiMeals,
    required bool vitaminEnabled,
    required String vitaminTime,
  }) async {
    try {
      // Reschedule MPASI reminders with new timezone
      await scheduleMpasiReminders(
        timezone: newTimezone,
        enabledMeals: enabledMpasiMeals,
      );

      // Reschedule vitamin reminder with new timezone
      if (vitaminEnabled) {
        await scheduleVitaminReminder(
          time: vitaminTime,
          timezone: newTimezone,
          enabled: true,
        );
      }

      debugPrint('All notifications updated to timezone: $newTimezone');
    } catch (e) {
      debugPrint('Error updating timezone: $e');
      throw Exception('Gagal memperbarui zona waktu notifikasi: $e');
    }
  }
}