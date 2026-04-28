import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diet_plan_provider.dart';
import '../../providers/food_diary_provider.dart';
import 'calorie_progress_bar.dart';

/// Diet Plan Dashboard Widget
/// Requirements: 5.8, 5.9, 5.10 - Dashboard dengan ringkasan harian dan progress tracking
class DietPlanDashboard extends StatelessWidget {
  final VoidCallback? onEditProfile;

  const DietPlanDashboard({
    super.key,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<DietPlanProvider, FoodDiaryProvider>(
      builder: (context, dietPlanProvider, foodDiaryProvider, child) {
        // Get consumed calories from food diary (mother profile)
        final consumedCalories = foodDiaryProvider.selectedProfile == 'mother'
            ? foodDiaryProvider.nutritionSummary.calories
            : 0.0;

        final summary = dietPlanProvider.getDietPlanSummary(consumedCalories);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main summary card
            _buildSummaryCard(context, dietPlanProvider, summary),
            const SizedBox(height: 16),

            // Calorie progress card
            _buildCalorieProgressCard(
              context,
              dietPlanProvider,
              consumedCalories,
            ),
            const SizedBox(height: 16),

            // Detailed metrics cards
            _buildMetricsGrid(context, summary),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    DietPlanProvider provider,
    Map<String, dynamic> summary,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Diet Plan Harian',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (onEditProfile != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: onEditProfile,
                    tooltip: 'Edit Profil',
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Target calories - main metric
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Kalori Harian',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Dengan defisit aman 500 kkal',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        summary['targetCalories'].toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8, left: 4),
                        child: Text(
                          'kkal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Requirement 5.9, 5.10: Progress bar dengan color coding dan warning
  Widget _buildCalorieProgressCard(
    BuildContext context,
    DietPlanProvider provider,
    double consumedCalories,
  ) {
    final remainingCalories = provider.getRemainingCalories(consumedCalories);
    final isExceeded = provider.isCaloriesExceeded(consumedCalories);
    final excessCalories = provider.getCalorieExcess(consumedCalories);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Kalori Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Calorie progress bar with color coding
            CalorieProgressBar(
              consumedCalories: consumedCalories,
              targetCalories: provider.targetCalories ?? 0,
            ),
            const SizedBox(height: 20),

            // Calorie breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCalorieInfo(
                  'Dikonsumsi',
                  consumedCalories,
                  Icons.restaurant,
                  Colors.blue,
                ),
                _buildCalorieInfo(
                  'Target',
                  provider.targetCalories ?? 0,
                  Icons.flag,
                  Colors.green,
                ),
                _buildCalorieInfo(
                  'Sisa',
                  remainingCalories,
                  Icons.trending_down,
                  isExceeded ? Colors.red : Colors.orange,
                ),
              ],
            ),

            // Requirement 5.10: Warning when calories exceeded
            if (isExceeded) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kalori melebihi target sebesar ${excessCalories.toStringAsFixed(0)} kkal',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieInfo(
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Text(
          'kkal',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// Requirement 5.8: Detailed metrics grid
  Widget _buildMetricsGrid(
    BuildContext context,
    Map<String, dynamic> summary,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'BMR',
                summary['bmr'].toStringAsFixed(0),
                'kkal',
                Icons.local_fire_department,
                Colors.orange,
                'Metabolisme Basal',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'TDEE',
                summary['tdee'].toStringAsFixed(0),
                'kkal',
                Icons.directions_run,
                Colors.blue,
                'Total Energi Harian',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Langkah Kaki',
                summary['steps'].toString(),
                'langkah',
                Icons.directions_walk,
                Colors.green,
                'Hari ini',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Kalori Terbakar',
                summary['caloriesBurned'].toStringAsFixed(1),
                'kkal',
                Icons.whatshot,
                Colors.red,
                'Dari langkah kaki',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
