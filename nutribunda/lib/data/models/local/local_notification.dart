import 'package:equatable/equatable.dart';

/// Local Notification Model with sync tracking
class LocalNotification extends Equatable {
  final int? id; // Local SQLite ID
  final String? serverId; // Server UUID
  final int userId; // Local user ID
  final String type; // 'mpasi_meal', 'vitamin'
  final String title;
  final String message;
  final String scheduledTime; // HH:MM format
  final bool isActive;
  final DateTime createdAt;
  final String syncStatus; // 'synced', 'pending', 'failed'

  const LocalNotification({
    this.id,
    this.serverId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.scheduledTime,
    this.isActive = true,
    required this.createdAt,
    this.syncStatus = 'pending',
  });

  /// Create from SQLite map
  factory LocalNotification.fromMap(Map<String, dynamic> map) {
    return LocalNotification(
      id: map['id'] as int?,
      serverId: map['server_id'] as String?,
      userId: map['user_id'] as int,
      type: map['type'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      scheduledTime: map['scheduled_time'] as String,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'server_id': serverId,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'scheduled_time': scheduledTime,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  /// Get type display name in Indonesian
  String get typeDisplay {
    switch (type) {
      case 'mpasi_meal':
        return 'Jadwal Makan MPASI';
      case 'vitamin':
        return 'Pengingat Vitamin';
      default:
        return type;
    }
  }

  /// Copy with updated fields
  LocalNotification copyWith({
    int? id,
    String? serverId,
    int? userId,
    String? type,
    String? title,
    String? message,
    String? scheduledTime,
    bool? isActive,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return LocalNotification(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        serverId,
        userId,
        type,
        title,
        message,
        scheduledTime,
        isActive,
        createdAt,
        syncStatus,
      ];
}
