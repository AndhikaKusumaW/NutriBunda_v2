import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/services/nutrition_tracker_service.dart';

/// Widget untuk menampilkan chart nutrisi dalam bentuk circular/radial
/// Requirements: 13.2 - Charts untuk visualisasi nutrisi
class NutritionChart extends StatelessWidget {
  final NutritionProgress progress;
  final double size;

  const NutritionChart({
    super.key,
    required this.progress,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NutritionChartPainter(progress: progress),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                progress.summary.calories.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.bold,
                  color: _getColorFromNutritionColor(progress.caloriesColor),
                ),
              ),
              Text(
                'kkal',
                style: TextStyle(
                  fontSize: size * 0.08,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

/// Custom painter untuk menggambar nutrition chart
class _NutritionChartPainter extends CustomPainter {
  final NutritionProgress progress;

  _NutritionChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arcs for each nutrient
    final nutrients = [
      {
        'percentage': progress.caloriesPercentage,
        'color': _getColorFromNutritionColor(progress.caloriesColor),
      },
      {
        'percentage': progress.proteinPercentage,
        'color': _getColorFromNutritionColor(progress.proteinColor),
      },
      {
        'percentage': progress.carbsPercentage,
        'color': _getColorFromNutritionColor(progress.carbsColor),
      },
      {
        'percentage': progress.fatPercentage,
        'color': _getColorFromNutritionColor(progress.fatColor),
      },
    ];

    // Calculate average percentage for main arc
    final avgPercentage = (progress.caloriesPercentage +
            progress.proteinPercentage +
            progress.carbsPercentage +
            progress.fatPercentage) /
        4;

    // Draw main progress arc
    final progressPaint = Paint()
      ..color = _getColorFromNutritionColor(
        NutritionTrackerService.getColorForPercentage(avgPercentage),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (avgPercentage / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw small indicator dots for each nutrient
    final dotRadius = 6.0;
    final dotDistance = radius + 15;

    for (int i = 0; i < nutrients.length; i++) {
      final angle = (i / nutrients.length) * 2 * math.pi - math.pi / 2;
      final dotX = center.dx + dotDistance * math.cos(angle);
      final dotY = center.dy + dotDistance * math.sin(angle);

      final dotPaint = Paint()
        ..color = nutrients[i]['color'] as Color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

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

/// Widget untuk menampilkan legend chart
class NutritionChartLegend extends StatelessWidget {
  final NutritionProgress progress;

  const NutritionChartLegend({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(
          context,
          'Kalori',
          progress.caloriesColor,
          '${progress.summary.calories.toStringAsFixed(0)} kkal',
        ),
        const SizedBox(height: 8),
        _buildLegendItem(
          context,
          'Protein',
          progress.proteinColor,
          '${progress.summary.protein.toStringAsFixed(1)} g',
        ),
        const SizedBox(height: 8),
        _buildLegendItem(
          context,
          'Karbohidrat',
          progress.carbsColor,
          '${progress.summary.carbs.toStringAsFixed(1)} g',
        ),
        const SizedBox(height: 8),
        _buildLegendItem(
          context,
          'Lemak',
          progress.fatColor,
          '${progress.summary.fat.toStringAsFixed(1)} g',
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    NutritionColor color,
    String value,
  ) {
    final displayColor = _getColorFromNutritionColor(color);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: displayColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: displayColor,
          ),
        ),
      ],
    );
  }

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
