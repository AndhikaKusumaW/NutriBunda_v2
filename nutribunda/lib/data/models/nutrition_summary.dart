import 'package:equatable/equatable.dart';

/// Model untuk Nutrition Summary
/// Merepresentasikan ringkasan nutrisi harian
/// Requirements: 4.3, 4.6 - Nutrition_Tracker menghitung total nutrisi harian
class NutritionSummary extends Equatable {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionSummary({
    this.calories = 0.0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
  });

  /// Create NutritionSummary from JSON
  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    return NutritionSummary(
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert NutritionSummary to JSON
  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  /// Add nutrition from a diary entry
  /// Requirements: 4.3 - Menghitung dan memperbarui total nutrisi
  NutritionSummary add(double calories, double protein, double carbs, double fat) {
    return NutritionSummary(
      calories: this.calories + calories,
      protein: this.protein + protein,
      carbs: this.carbs + carbs,
      fat: this.fat + fat,
    );
  }

  /// Remove nutrition from a diary entry
  /// Requirements: 4.5 - Mengurangi total nutrisi saat entry dihapus
  NutritionSummary remove(double calories, double protein, double carbs, double fat) {
    return NutritionSummary(
      calories: (this.calories - calories).clamp(0.0, double.infinity),
      protein: (this.protein - protein).clamp(0.0, double.infinity),
      carbs: (this.carbs - carbs).clamp(0.0, double.infinity),
      fat: (this.fat - fat).clamp(0.0, double.infinity),
    );
  }

  /// Create a copy with updated values
  NutritionSummary copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return NutritionSummary(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  @override
  List<Object?> get props => [calories, protein, carbs, fat];

  @override
  String toString() {
    return 'NutritionSummary(calories: ${calories.toStringAsFixed(1)}, '
        'protein: ${protein.toStringAsFixed(1)}g, '
        'carbs: ${carbs.toStringAsFixed(1)}g, '
        'fat: ${fat.toStringAsFixed(1)}g)';
  }
}
