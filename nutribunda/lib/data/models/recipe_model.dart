import 'package:equatable/equatable.dart';

/// Model untuk Recipe
/// Requirements: 6.3, 6.4, 7.1
class RecipeModel extends Equatable {
  final String id;
  final String name;
  final List<String> ingredients;
  final String instructions;
  final NutritionInfo? nutritionInfo;
  final String category;
  final DateTime createdAt;

  const RecipeModel({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    this.nutritionInfo,
    required this.category,
    required this.createdAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    // Parse ingredients - could be JSON array or comma-separated string
    List<String> ingredientsList = [];
    if (json['ingredients'] is List) {
      ingredientsList = (json['ingredients'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (json['ingredients'] is String) {
      final ingredientsStr = json['ingredients'] as String;
      // Try to parse as JSON array first
      try {
        // Remove brackets and split by comma
        final cleaned = ingredientsStr
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '');
        ingredientsList = cleaned
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } catch (e) {
        // If parsing fails, treat as single ingredient
        ingredientsList = [ingredientsStr];
      }
    }

    // Parse nutrition info if available
    NutritionInfo? nutritionInfo;
    if (json['nutrition_info'] != null) {
      if (json['nutrition_info'] is Map) {
        nutritionInfo = NutritionInfo.fromJson(
          json['nutrition_info'] as Map<String, dynamic>,
        );
      }
    }

    return RecipeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ingredients: ingredientsList,
      instructions: json['instructions'] as String,
      nutritionInfo: nutritionInfo,
      category: json['category'] as String? ?? 'mpasi',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'instructions': instructions,
      'nutrition_info': nutritionInfo?.toJson(),
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        ingredients,
        instructions,
        nutritionInfo,
        category,
        createdAt,
      ];
}

/// Model untuk informasi nutrisi per sajian
class NutritionInfo extends Equatable {
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

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: _parseDouble(json['calories']),
      protein: _parseDouble(json['protein']),
      carbs: _parseDouble(json['carbs']),
      fat: _parseDouble(json['fat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props => [calories, protein, carbs, fat];
}
