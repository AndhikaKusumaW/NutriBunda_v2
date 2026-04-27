import 'package:equatable/equatable.dart';
import 'food_model.dart';

/// Model untuk Diary Entry
/// Merepresentasikan entri makanan harian untuk bayi atau ibu
/// Requirements: 4.1, 4.2, 4.4 - Food_Diary dengan dual profile dan meal time slots
class DiaryEntry extends Equatable {
  final String id;
  final String userId;
  final String profileType; // 'baby' or 'mother'
  final String? foodId;
  final String? customFoodName;
  final double servingSize; // in grams
  final String mealTime; // 'breakfast', 'lunch', 'dinner', 'snack'
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime entryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FoodModel? food; // Optional, populated when foodId is present

  const DiaryEntry({
    required this.id,
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
    this.food,
  });

  /// Create DiaryEntry from JSON
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      profileType: json['profile_type'] as String,
      foodId: json['food_id'] as String?,
      customFoodName: json['custom_food_name'] as String?,
      servingSize: (json['serving_size'] as num).toDouble(),
      mealTime: json['meal_time'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      entryDate: DateTime.parse(json['entry_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      food: json['food'] != null ? FoodModel.fromJson(json['food'] as Map<String, dynamic>) : null,
    );
  }

  /// Convert DiaryEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      if (food != null) 'food': food!.toJson(),
    };
  }

  /// Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Get display name (food name or custom food name)
  String get displayName {
    if (food != null) {
      return food!.name;
    } else if (customFoodName != null) {
      return customFoodName!;
    }
    return 'Unknown Food';
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

  /// Create a copy with updated fields
  DiaryEntry copyWith({
    String? id,
    String? userId,
    String? profileType,
    String? foodId,
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
    FoodModel? food,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
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
      food: food ?? this.food,
    );
  }

  @override
  List<Object?> get props => [
        id,
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
        food,
      ];
}
