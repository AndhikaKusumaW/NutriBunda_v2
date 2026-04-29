import 'package:equatable/equatable.dart';
import '../food_model.dart';

/// Local Food Model with sync tracking
/// Extends FoodModel with local database fields
class LocalFoodModel extends Equatable {
  final int? id; // Local SQLite ID
  final String? serverId; // Server UUID
  final String name;
  final String category;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final DateTime createdAt;
  final String syncStatus; // 'synced', 'pending', 'failed'

  const LocalFoodModel({
    this.id,
    this.serverId,
    required this.name,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.createdAt,
    this.syncStatus = 'synced',
  });

  /// Create from FoodModel (from server)
  factory LocalFoodModel.fromFoodModel(FoodModel food) {
    return LocalFoodModel(
      serverId: food.id,
      name: food.name,
      category: food.category,
      caloriesPer100g: food.caloriesPer100g,
      proteinPer100g: food.proteinPer100g,
      carbsPer100g: food.carbsPer100g,
      fatPer100g: food.fatPer100g,
      createdAt: food.createdAt,
      syncStatus: 'synced',
    );
  }

  /// Convert to FoodModel (for API)
  FoodModel toFoodModel() {
    return FoodModel(
      id: serverId ?? '',
      name: name,
      category: category,
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g,
      carbsPer100g: carbsPer100g,
      fatPer100g: fatPer100g,
      createdAt: createdAt,
    );
  }

  /// Create from SQLite map
  factory LocalFoodModel.fromMap(Map<String, dynamic> map) {
    return LocalFoodModel(
      id: map['id'] as int?,
      serverId: map['server_id'] as String?,
      name: map['name'] as String,
      category: map['category'] as String,
      caloriesPer100g: (map['calories_per_100g'] as num).toDouble(),
      proteinPer100g: (map['protein_per_100g'] as num).toDouble(),
      carbsPer100g: (map['carbs_per_100g'] as num).toDouble(),
      fatPer100g: (map['fat_per_100g'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      syncStatus: map['sync_status'] as String? ?? 'synced',
    );
  }

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'server_id': serverId,
      'name': name,
      'category': category,
      'calories_per_100g': caloriesPer100g,
      'protein_per_100g': proteinPer100g,
      'carbs_per_100g': carbsPer100g,
      'fat_per_100g': fatPer100g,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  /// Calculate nutrition for a specific serving size
  NutritionInfo calculateNutrition(double servingSizeGrams) {
    final multiplier = servingSizeGrams / 100.0;
    return NutritionInfo(
      calories: caloriesPer100g * multiplier,
      protein: proteinPer100g * multiplier,
      carbs: carbsPer100g * multiplier,
      fat: fatPer100g * multiplier,
    );
  }

  /// Copy with updated fields
  LocalFoodModel copyWith({
    int? id,
    String? serverId,
    String? name,
    String? category,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return LocalFoodModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      category: category ?? this.category,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        serverId,
        name,
        category,
        caloriesPer100g,
        proteinPer100g,
        carbsPer100g,
        fatPer100g,
        createdAt,
        syncStatus,
      ];
}
