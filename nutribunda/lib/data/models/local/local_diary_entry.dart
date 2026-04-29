import 'package:equatable/equatable.dart';
import '../diary_entry.dart';

/// Local Diary Entry Model with sync tracking
/// Extends DiaryEntry with local database fields
class LocalDiaryEntry extends Equatable {
  final int? id; // Local SQLite ID
  final String? serverId; // Server UUID
  final int userId; // Local user ID
  final String profileType;
  final int? foodId; // Local food ID
  final String? customFoodName;
  final double servingSize;
  final String mealTime;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime entryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus; // 'synced', 'pending', 'failed'

  const LocalDiaryEntry({
    this.id,
    this.serverId,
    required this.userId,
    required this.profileType,
    this.foodId,
    this.customFoodName,
    required this.servingSize,
    required this.mealTime,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = 'pending',
  });

  /// Create from DiaryEntry (from server)
  factory LocalDiaryEntry.fromDiaryEntry(DiaryEntry entry, int localUserId, int? localFoodId) {
    return LocalDiaryEntry(
      serverId: entry.id,
      userId: localUserId,
      profileType: entry.profileType,
      foodId: localFoodId,
      customFoodName: entry.customFoodName,
      servingSize: entry.servingSize,
      mealTime: entry.mealTime,
      calories: entry.calories,
      protein: entry.protein,
      carbs: entry.carbs,
      fat: entry.fat,
      entryDate: entry.entryDate,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      syncStatus: 'synced',
    );
  }

  /// Create from SQLite map
  factory LocalDiaryEntry.fromMap(Map<String, dynamic> map) {
    return LocalDiaryEntry(
      id: map['id'] as int?,
      serverId: map['server_id'] as String?,
      userId: map['user_id'] as int,
      profileType: map['profile_type'] as String,
      foodId: map['food_id'] as int?,
      customFoodName: map['custom_food_name'] as String?,
      servingSize: (map['serving_size'] as num).toDouble(),
      mealTime: map['meal_time'] as String,
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      entryDate: DateTime.parse(map['entry_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
      syncStatus: map['sync_status'] as String? ?? 'pending',
    );
  }

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'server_id': serverId,
      'user_id': userId,
      'profile_type': profileType,
      'food_id': foodId,
      'custom_food_name': customFoodName,
      'serving_size': servingSize,
      'meal_time': mealTime,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'entry_date': _formatDate(entryDate),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  /// Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Get meal time display name in Indonesian
  String get mealTimeDisplay {
    switch (mealTime) {
      case 'breakfast':
        return 'Makan Pagi';
      case 'lunch':
        return 'Makan Siang';
      case 'dinner':
        return 'Makan Malam';
      case 'snack':
        return 'Makanan Selingan';
      default:
        return mealTime;
    }
  }

  /// Get profile type display name in Indonesian
  String get profileTypeDisplay {
    switch (profileType) {
      case 'baby':
        return 'Bayi';
      case 'mother':
        return 'Ibu';
      default:
        return profileType;
    }
  }

  /// Copy with updated fields
  LocalDiaryEntry copyWith({
    int? id,
    String? serverId,
    int? userId,
    String? profileType,
    int? foodId,
    String? customFoodName,
    double? servingSize,
    String? mealTime,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? entryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? syncStatus,
  }) {
    return LocalDiaryEntry(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      profileType: profileType ?? this.profileType,
      foodId: foodId ?? this.foodId,
      customFoodName: customFoodName ?? this.customFoodName,
      servingSize: servingSize ?? this.servingSize,
      mealTime: mealTime ?? this.mealTime,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        serverId,
        userId,
        profileType,
        foodId,
        customFoodName,
        servingSize,
        mealTime,
        calories,
        protein,
        carbs,
        fat,
        entryDate,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus,
      ];
}
