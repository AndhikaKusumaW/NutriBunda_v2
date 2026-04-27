import 'package:flutter/material.dart';
import '../../../core/services/nutrition_tracker_service.dart';

/// Widget untuk menampilkan progress bar nutrisi dengan color coding
/// Requirements: 13.2 - Progress bars dengan color coding
/// Green (0-80%), Yellow (81-100%), Red (>100%)
class NutritionProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final double percentage;
  final NutritionColor color;
  final String unit;
  final IconData icon;

  const NutritionProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.percentage,
    required this.color,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = _getColorFromNutritionColor(color);
    final displayPercentage = percentage.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon, label, and values
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: progressColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${current.toStringAsFixed(1)} / ${target.toStringAsFixed(0)} $unit',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        Stack(
          children: [
            // Background bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            // Progress bar
            FractionallySizedBox(
              widthFactor: displayPercentage / 100,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Percentage text
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: progressColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Convert NutritionColor enum to Flutter Color
  Color _getColorFromNutritionColor(NutritionColor nutritionColor) {
    switch (nutritionColor) {
      case NutritionColor.green:
        return Colors.green;
      case NutritionColor.yellow:
        return Colors.orange;
      case NutritionColor.red:
        return Colors.red;
    }
  }
}

/// Widget untuk menampilkan semua progress bars nutrisi
/// Requirements: 13.2 - Dashboard dengan ringkasan nutrisi
class NutritionProgressBars extends StatelessWidget {
  final NutritionProgress progress;

  const NutritionProgressBars({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calories
        NutritionProgressBar(
          label: 'Kalori',
          current: progress.summary.calories,
          target: progress.getTarget('calories'),
          percentage: progress.caloriesPercentage,
          color: progress.caloriesColor,
          unit: 'kkal',
          icon: Icons.local_fire_department,
        ),
        const SizedBox(height: 16),

        // Protein
        NutritionProgressBar(
          label: 'Protein',
          current: progress.summary.protein,
          target: progress.getTarget('protein'),
          percentage: progress.proteinPercentage,
          color: progress.proteinColor,
          unit: 'g',
          icon: Icons.egg,
        ),
        const SizedBox(height: 16),

        // Carbs
        NutritionProgressBar(
          label: 'Karbohidrat',
          current: progress.summary.carbs,
          target: progress.getTarget('carbs'),
          percentage: progress.carbsPercentage,
          color: progress.carbsColor,
          unit: 'g',
          icon: Icons.rice_bowl,
        ),
        const SizedBox(height: 16),

        // Fat
        NutritionProgressBar(
          label: 'Lemak',
          current: progress.summary.fat,
          target: progress.getTarget('fat'),
          percentage: progress.fatPercentage,
          color: progress.fatColor,
          unit: 'g',
          icon: Icons.water_drop,
        ),
      ],
    );
  }
}
