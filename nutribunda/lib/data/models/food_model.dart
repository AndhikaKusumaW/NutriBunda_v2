import 'package:equatable/equatable.dart';

/// Model untuk Food
/// Merepresentasikan data makanan dari Food_Database
/// Requirements: 3.1 - Food_Database dengan kandungan nutrisi
class FoodModel extends Equatable {
  final String id;
  final String name;
  final String category; // 'mpasi' or 'ibu'
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double? estimatedPricePer100g;
  final DateTime createdAt;

  const FoodModel({
    required this.id,
    required this.name,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.estimatedPricePer100g,
    required this.createdAt,
  });

  /// Create FoodModel from JSON
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      caloriesPer100g: (json['calories_per_100g'] as num).toDouble(),
      proteinPer100g: (json['protein_per_100g'] as num).toDouble(),
      carbsPer100g: (json['carbs_per_100g'] as num).toDouble(),
      fatPer100g: (json['fat_per_100g'] as num).toDouble(),
      estimatedPricePer100g: json['estimated_price_per_100g'] != null
          ? (json['estimated_price_per_100g'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert FoodModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'calories_per_100g': caloriesPer100g,
      'protein_per_100g': proteinPer100g,
      'carbs_per_100g': carbsPer100g,
      'fat_per_100g': fatPer100g,
      'estimated_per_price_100g': estimatedPricePer100g,
      'created_at': createdAt.toIso8601String(),
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

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        caloriesPer100g,
        proteinPer100g,
        carbsPer100g,
        fatPer100g,
        estimatedPricePer100g,
        createdAt,
      ];
}

/// Helper class untuk informasi nutrisi
class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
