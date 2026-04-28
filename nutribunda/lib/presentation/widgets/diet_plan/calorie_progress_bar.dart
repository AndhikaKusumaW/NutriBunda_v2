import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diet_plan_provider.dart';

/// Calorie Progress Bar Widget
/// Requirement 5.9: Progress bar visual dengan color coding
/// - Hijau (0-80% target)
/// - Kuning (81-100% target)
/// - Merah (>100% target)
class CalorieProgressBar extends StatelessWidget {
  final double consumedCalories;
  final double targetCalories;

  const CalorieProgressBar({
    super.key,
    required this.consumedCalories,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final dietPlanProvider = context.watch<DietPlanProvider>();
    
    final progressPercentage = dietPlanProvider.getCalorieProgress(consumedCalories);
    final progressColorString = dietPlanProvider.getProgressColor(consumedCalories);
    final progressPercentageText = progressPercentage.toStringAsFixed(1);
    
    // Convert percentage to fraction for progress bar (0-1)
    final progressFraction = progressPercentage / 100;
    
    // Convert string color to Color object
    final Color progressColor;
    switch (progressColorString) {
      case 'green':
        progressColor = Colors.green;
        break;
      case 'yellow':
        progressColor = Colors.yellow[700]!;
        break;
      case 'red':
        progressColor = Colors.red;
        break;
      default:
        progressColor = Colors.grey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress percentage text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$progressPercentageText%',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
            _buildProgressLabel(progressPercentage, progressColor),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 24,
            child: Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Progress fill
                FractionallySizedBox(
                  widthFactor: progressFraction.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          progressColor,
                          progressColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Overflow indicator (if > 100%)
                if (progressFraction > 1.0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Color coding legend
        _buildColorLegend(),
      ],
    );
  }

  Widget _buildProgressLabel(double progressPercentage, Color progressColor) {
    String label;
    IconData icon;
    Color color = progressColor;

    if (progressPercentage <= 80) {
      label = 'Baik';
      icon = Icons.check_circle;
    } else if (progressPercentage <= 100) {
      label = 'Mendekati Target';
      icon = Icons.info;
    } else {
      label = 'Melebihi Target';
      icon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLegendItem('0-80%', Colors.green, 'Baik'),
        _buildLegendItem('81-100%', Colors.yellow[700]!, 'Mendekati'),
        _buildLegendItem('>100%', Colors.red, 'Melebihi'),
      ],
    );
  }

  Widget _buildLegendItem(String range, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              range,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
