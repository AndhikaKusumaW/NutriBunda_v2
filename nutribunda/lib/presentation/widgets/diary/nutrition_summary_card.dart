import 'package:flutter/material.dart';
import '../../../data/models/nutrition_summary.dart';

/// Nutrition Summary Card Widget
/// Requirements: 4.6 - Menampilkan ringkasan nutrisi harian
class NutritionSummaryCard extends StatelessWidget {
  final NutritionSummary summary;
  final String profileType;

  const NutritionSummaryCard({
    Key? key,
    required this.summary,
    required this.profileType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  profileType == 'baby' ? Icons.child_care : Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ringkasan Nutrisi Harian',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildNutrientColumn(
                    'Kalori',
                    summary.calories.toStringAsFixed(1),
                    'kkal',
                    Icons.local_fire_department,
                  ),
                ),
                Expanded(
                  child: _buildNutrientColumn(
                    'Protein',
                    summary.protein.toStringAsFixed(1),
                    'g',
                    Icons.egg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNutrientColumn(
                    'Karbohidrat',
                    summary.carbs.toStringAsFixed(1),
                    'g',
                    Icons.rice_bowl,
                  ),
                ),
                Expanded(
                  child: _buildNutrientColumn(
                    'Lemak',
                    summary.fat.toStringAsFixed(1),
                    'g',
                    Icons.water_drop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientColumn(String label, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
