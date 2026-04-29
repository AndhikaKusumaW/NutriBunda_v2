import 'package:equatable/equatable.dart';
import 'dart:convert';
import '../recipe_model.dart';

/// Local Recipe Model with sync tracking
class LocalRecipeModel extends Equatable {
  final int? id; // Local SQLite ID
  final String? serverId; // Server UUID
  final String name;
  final String ingredients; // JSON string
  final String instructions;
  final String? nutritionInfo; // JSON string
  final String category;
  final DateTime createdAt;
  final String syncStatus; // 'synced', 'pending', 'failed'

  const LocalRecipeModel({
    this.id,
    this.serverId,
    required this.name,
    required this.ingredients,
    required this.instructions,
    this.nutritionInfo,
    this.category = 'mpasi',
    required this.createdAt,
    this.syncStatus = 'synced',
  });

  /// Create from RecipeModel (from server)
  factory LocalRecipeModel.fromRecipeModel(RecipeModel recipe) {
    return LocalRecipeModel(
      serverId: recipe.id,
      name: recipe.name,
      ingredients: jsonEncode(recipe.ingredients),
      instructions: recipe.instructions,
      nutritionInfo: recipe.nutritionInfo != null 
          ? jsonEncode(recipe.nutritionInfo!.toJson())
          : null,
      category: recipe.category,
      createdAt: recipe.createdAt,
      syncStatus: 'synced',
    );
  }

  /// Convert to RecipeModel (for API/UI)
  RecipeModel toRecipeModel() {
    List<String> ingredientsList = [];
    try {
      ingredientsList = List<String>.from(jsonDecode(ingredients));
    } catch (e) {
      ingredientsList = [ingredients];
    }

    NutritionInfo? nutrition;
    if (nutritionInfo != null) {
      try {
        nutrition = NutritionInfo.fromJson(
          jsonDecode(nutritionInfo!) as Map<String, dynamic>
        );
      } catch (e) {
        nutrition = null;
      }
    }

    return RecipeModel(
      id: serverId ?? '',
      name: name,
      ingredients: ingredientsList,
      instructions: instructions,
      nutritionInfo: nutrition,
      category: category,
      createdAt: createdAt,
    );
  }

  /// Create from SQLite map
  factory LocalRecipeModel.fromMap(Map<String, dynamic> map) {
    return LocalRecipeModel(
      id: map['id'] as int?,
      serverId: map['server_id'] as String?,
      name: map['name'] as String,
      ingredients: map['ingredients'] as String,
      instructions: map['instructions'] as String,
      nutritionInfo: map['nutrition_info'] as String?,
      category: map['category'] as String? ?? 'mpasi',
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
      'ingredients': ingredients,
      'instructions': instructions,
      'nutrition_info': nutritionInfo,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  /// Copy with updated fields
  LocalRecipeModel copyWith({
    int? id,
    String? serverId,
    String? name,
    String? ingredients,
    String? instructions,
    String? nutritionInfo,
    String? category,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return LocalRecipeModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        serverId,
        name,
        ingredients,
        instructions,
        nutritionInfo,
        category,
        createdAt,
        syncStatus,
      ];
}
