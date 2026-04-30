import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServiceRef {
  static final NotificationServiceRef _instance = NotificationServiceRef._internal();
  factory NotificationServiceRef() => _instance;
  NotificationServiceRef._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'nutribunda_channel',
      'NutriBunda',
      channelDescription: 'Pengingat makan dan vitamin dari NutriBunda',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await cancelNotification(id);
    // Simple show notification immediately for demonstration
    await showNotification(id: id, title: title, body: body);
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
