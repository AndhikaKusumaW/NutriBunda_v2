import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/notification_service.dart';
import 'base_provider.dart';

/// Provider untuk mengelola state notifikasi
/// Menangani pengaturan MPASI dan vitamin reminders sesuai Requirements 11.1-11.6
class NotificationProvider extends BaseProvider {
  final NotificationService _notificationService;
  final SharedPreferences _prefs;

  // Preference keys
  static const String _keyMpasiEnabled = 'mpasi_notifications_enabled';
  static const String _keyMpasiMorning = 'mpasi_morning_enabled';
  static const String _keyMpasiLunch = 'mpasi_lunch_enabled';
  static const String _keyMpasiAfternoon = 'mpasi_afternoon_enabled';
  static const String _keyMpasiEvening = 'mpasi_evening_enabled';
  static const String _keyVitaminEnabled = 'vitamin_notification_enabled';
  static const String _keyVitaminTime = 'vitamin_notification_time';
  static const String _keyTimezone = 'notification_timezone';
  static const String _keyPermissionGranted = 'notification_permission_granted';

  // State variables
  bool _mpasiEnabled = true;
  List<bool> _mpasiMeals = [true, true, true, true]; // [morning, lunch, afternoon, evening]
  bool _vitaminEnabled = false;
  String _vitaminTime = '08:00';
  String _timezone = 'WIB';
  bool _permissionGranted = false;
  bool _isInitialized = false;

  NotificationProvider({
    required NotificationService notificationService,
    required SharedPreferences prefs,
  })  : _notificationService = notificationService,
        _prefs = prefs;

  // Getters
  bool get mpasiEnabled => _mpasiEnabled;
  List<bool> get mpasiMeals => List.unmodifiable(_mpasiMeals);
  bool get vitaminEnabled => _vitaminEnabled;
  String get vitaminTime => _vitaminTime;
  String get timezone => _timezone;
  bool get permissionGranted => _permissionGranted;
  bool get isInitialized => _isInitialized;

  // Meal names for UI
  List<String> get mealNames => [
        'Sarapan (07:00)',
        'Makan Siang (12:00)',
        'Makan Sore (17:00)',
        'Makan Malam (19:00)',
      ];

  // Timezone options
  List<String> get timezoneOptions => ['WIB', 'WITA', 'WIT', 'London'];

  Map<String, String> get timezoneDescriptions => {
        'WIB': 'Waktu Indonesia Barat (UTC+7)',
        'WITA': 'Waktu Indonesia Tengah (UTC+8)',
        'WIT': 'Waktu Indonesia Timur (UTC+9)',
        'London': 'London, Inggris (UTC+0/UTC+1 BST)',
      };

  /// Initialize notification provider
  /// Requirements: 11.6 - Handle notification permissions properly
  Future<void> initialize() async {
    await executeWithLoading(() async {
      // Initialize notification service
      final initialized = await _notificationService.initialize();
      if (!initialized) {
        throw Exception('Gagal menginisialisasi layanan notifikasi');
      }

      // Load saved preferences
      await _loadPreferences();

      // Check permission status
      _permissionGranted = await _notificationService.areNotificationsEnabled();

      // If permission granted and notifications enabled, schedule them
      if (_permissionGranted) {
        await _scheduleActiveNotifications();
      }

      _isInitialized = true;
    });
  }

  /// Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    _mpasiEnabled = _prefs.getBool(_keyMpasiEnabled) ?? true;
    _mpasiMeals = [
      _prefs.getBool(_keyMpasiMorning) ?? true,
      _prefs.getBool(_keyMpasiLunch) ?? true,
      _prefs.getBool(_keyMpasiAfternoon) ?? true,
      _prefs.getBool(_keyMpasiEvening) ?? true,
    ];
    _vitaminEnabled = _prefs.getBool(_keyVitaminEnabled) ?? false;
    _vitaminTime = _prefs.getString(_keyVitaminTime) ?? '08:00';
    _timezone = _prefs.getString(_keyTimezone) ?? 'WIB';
    _permissionGranted = _prefs.getBool(_keyPermissionGranted) ?? false;
  }

  /// Save preferences to SharedPreferences
  Future<void> _savePreferences() async {
    await _prefs.setBool(_keyMpasiEnabled, _mpasiEnabled);
    await _prefs.setBool(_keyMpasiMorning, _mpasiMeals[0]);
    await _prefs.setBool(_keyMpasiLunch, _mpasiMeals[1]);
    await _prefs.setBool(_keyMpasiAfternoon, _mpasiMeals[2]);
    await _prefs.setBool(_keyMpasiEvening, _mpasiMeals[3]);
    await _prefs.setBool(_keyVitaminEnabled, _vitaminEnabled);
    await _prefs.setString(_keyVitaminTime, _vitaminTime);
    await _prefs.setString(_keyTimezone, _timezone);
    await _prefs.setBool(_keyPermissionGranted, _permissionGranted);
  }

  /// Request notification permissions
  /// Requirements: 11.6 - Handle notification permissions properly
  Future<bool> requestPermissions() async {
    final result = await executeWithLoading(() async {
      final granted = await _notificationService.requestPermissions();
      _permissionGranted = granted;
      await _savePreferences();

      if (granted) {
        await _scheduleActiveNotifications();
      }

      return granted;
    });

    return result ?? false;
  }

  /// Toggle MPASI notifications
  /// Requirements: 11.5 - Allow users to enable/disable specific notifications
  Future<void> toggleMpasiNotifications(bool enabled) async {
    await executeWithLoading(() async {
      _mpasiEnabled = enabled;
      await _savePreferences();

      if (_permissionGranted) {
        if (enabled) {
          await _notificationService.scheduleMpasiReminders(
            timezone: _timezone,
            enabledMeals: _mpasiMeals,
          );
        } else {
          await _notificationService.cancelMpasiReminders();
        }
      }
    });
  }

  /// Toggle specific MPASI meal
  /// Requirements: 11.5 - Allow users to enable/disable specific notifications
  Future<void> toggleMpasiMeal(int mealIndex, bool enabled) async {
    if (mealIndex < 0 || mealIndex >= _mpasiMeals.length) return;

    await executeWithLoading(() async {
      _mpasiMeals[mealIndex] = enabled;
      await _savePreferences();

      if (_permissionGranted && _mpasiEnabled) {
        await _notificationService.scheduleMpasiReminders(
          timezone: _timezone,
          enabledMeals: _mpasiMeals,
        );
      }
    });
  }

  /// Toggle vitamin notifications
  /// Requirements: 11.5 - Allow users to enable/disable specific notifications
  Future<void> toggleVitaminNotifications(bool enabled) async {
    await executeWithLoading(() async {
      _vitaminEnabled = enabled;
      await _savePreferences();

      if (_permissionGranted) {
        await _notificationService.scheduleVitaminReminder(
          time: _vitaminTime,
          timezone: _timezone,
          enabled: enabled,
        );
      }
    });
  }

  /// Set vitamin reminder time
  /// Requirements: 11.2 - Send local notifications for vitamin reminders at user-configurable times
  Future<void> setVitaminTime(String time) async {
    await executeWithLoading(() async {
      _vitaminTime = time;
      await _savePreferences();

      if (_permissionGranted && _vitaminEnabled) {
        await _notificationService.scheduleVitaminReminder(
          time: _vitaminTime,
          timezone: _timezone,
          enabled: true,
        );
      }
    });
  }

  /// Change timezone
  /// Requirements: 11.3 - Allow users to select timezone (WIB, WITA, WIT)
  /// Requirements: 11.4 - Adjust all notification times when timezone is changed
  Future<void> changeTimezone(String newTimezone) async {
    if (!timezoneOptions.contains(newTimezone)) return;

    await executeWithLoading(() async {
      _timezone = newTimezone;
      await _savePreferences();

      if (_permissionGranted) {
        await _notificationService.updateTimezone(
          newTimezone: newTimezone,
          enabledMpasiMeals: _mpasiMeals,
          vitaminEnabled: _vitaminEnabled,
          vitaminTime: _vitaminTime,
        );
      }
    });
  }

  /// Schedule all active notifications
  Future<void> _scheduleActiveNotifications() async {
    try {
      // Schedule MPASI reminders if enabled
      if (_mpasiEnabled) {
        await _notificationService.scheduleMpasiReminders(
          timezone: _timezone,
          enabledMeals: _mpasiMeals,
        );
      }

      // Schedule vitamin reminder if enabled
      if (_vitaminEnabled) {
        await _notificationService.scheduleVitaminReminder(
          time: _vitaminTime,
          timezone: _timezone,
          enabled: true,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling active notifications: $e');
    }
  }

  /// Get notification summary for display
  String getNotificationSummary() {
    if (!_permissionGranted) {
      return 'Izin notifikasi belum diberikan';
    }

    List<String> active = [];

    if (_mpasiEnabled) {
      final enabledMealCount = _mpasiMeals.where((meal) => meal).length;
      active.add('MPASI ($enabledMealCount jadwal)');
    }

    if (_vitaminEnabled) {
      active.add('Vitamin ($_vitaminTime)');
    }

    if (active.isEmpty) {
      return 'Tidak ada notifikasi aktif';
    }

    return 'Aktif: ${active.join(', ')} - $_timezone';
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await executeWithLoading(() async {
      await _notificationService.cancelAllNotifications();
      
      _mpasiEnabled = false;
      _vitaminEnabled = false;
      _mpasiMeals = [false, false, false, false];
      
      await _savePreferences();
    });
  }

  /// Get pending notifications count (for debugging)
  Future<int> getPendingNotificationsCount() async {
    try {
      final pending = await _notificationService.getPendingNotifications();
      return pending.length;
    } catch (e) {
      debugPrint('Error getting pending notifications count: $e');
      return 0;
    }
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    await executeWithLoading(() async {
      _mpasiEnabled = true;
      _mpasiMeals = [true, true, true, true];
      _vitaminEnabled = false;
      _vitaminTime = '08:00';
      _timezone = 'WIB';

      await _savePreferences();

      if (_permissionGranted) {
        await _scheduleActiveNotifications();
      }
    });
  }

  /// Validate time format (HH:mm)
  bool isValidTimeFormat(String time) {
    final RegExp timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }

  /// Format time for display
  String formatTimeForDisplay(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }
}