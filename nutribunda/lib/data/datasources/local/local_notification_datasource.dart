import 'package:sqflite/sqflite.dart';
import '../../models/local/local_notification.dart';
import 'database_helper.dart';

/// Local Notification Data Source
/// Handles CRUD operations for notifications in SQLite
/// Requirements: 11.1, 11.2, 11.5 - Notification settings management
class LocalNotificationDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert notification
  Future<int> insertNotification(LocalNotification notification) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get notification by local ID
  Future<LocalNotification?> getNotificationById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalNotification.fromMap(maps.first);
  }

  /// Get all notifications for a user
  Future<List<LocalNotification>> getNotificationsByUser(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'scheduled_time ASC',
    );

    return maps.map((map) => LocalNotification.fromMap(map)).toList();
  }

  /// Get active notifications for a user
  /// Requirements: 11.1 - Active notification management
  Future<List<LocalNotification>> getActiveNotifications(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notifications',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'scheduled_time ASC',
    );

    return maps.map((map) => LocalNotification.fromMap(map)).toList();
  }

  /// Get notifications by type
  /// Requirements: 11.1, 11.2 - MPASI meal and vitamin reminders
  Future<List<LocalNotification>> getNotificationsByType({
    required int userId,
    required String type,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notifications',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'scheduled_time ASC',
    );

    return maps.map((map) => LocalNotification.fromMap(map)).toList();
  }

  /// Update notification
  Future<int> updateNotification(LocalNotification notification) async {
    final db = await _dbHelper.database;
    return await db.update(
      'notifications',
      notification.toMap(),
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }

  /// Toggle notification active status
  /// Requirements: 11.5 - Enable/disable notifications
  Future<int> toggleNotificationStatus(int id, bool isActive) async {
    final db = await _dbHelper.database;
    return await db.update(
      'notifications',
      {
        'is_active': isActive ? 1 : 0,
        'sync_status': 'pending',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete notification
  Future<int> deleteNotification(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get pending sync notifications
  Future<List<LocalNotification>> getPendingSyncNotifications() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notifications',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );

    return maps.map((map) => LocalNotification.fromMap(map)).toList();
  }

  /// Clear all notifications for a user
  Future<void> clearAllNotifications(int userId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Get count of active notifications
  Future<int> getActiveNotificationsCount(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM notifications 
      WHERE user_id = ? AND is_active = 1
    ''', [userId]);
    
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
