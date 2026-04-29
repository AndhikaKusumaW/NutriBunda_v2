/// Sync Request Model
/// Represents a request to sync diary entries with the server
/// Requirements: 3.5, 4.1, 7.4 - Bidirectional sync with conflict detection
class SyncRequest {
  final String? lastSyncTime; // RFC3339 format
  final List<SyncDiaryEntry> entries; // Entries to upload from client
  final List<String> deletedIds; // IDs deleted on client

  const SyncRequest({
    this.lastSyncTime,
    required this.entries,
    required this.deletedIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'last_sync_time': lastSyncTime ?? '',
      'entries': entries.map((e) => e.toJson()).toList(),
      'deleted_ids': deletedIds,
    };
  }
}

/// Sync Diary Entry Model
/// Represents a diary entry for sync operations
class SyncDiaryEntry {
  final String id;
  final String profileType;
  final String? foodId;
  final String? customFoodName;
  final double servingSize;
  final String mealTime;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String entryDate; // YYYY-MM-DD format
  final String updatedAt; // RFC3339 format

  const SyncDiaryEntry({
    required this.id,
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
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_type': profileType,
      'food_id': foodId,
      'custom_food_name': customFoodName,
      'serving_size': servingSize,
      'meal_time': mealTime,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'entry_date': entryDate,
      'updated_at': updatedAt,
    };
  }

  factory SyncDiaryEntry.fromJson(Map<String, dynamic> json) {
    return SyncDiaryEntry(
      id: json['id'] as String,
      profileType: json['profile_type'] as String,
      foodId: json['food_id'] as String?,
      customFoodName: json['custom_food_name'] as String?,
      servingSize: (json['serving_size'] as num).toDouble(),
      mealTime: json['meal_time'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      entryDate: json['entry_date'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}
