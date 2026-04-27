import 'package:flutter/material.dart';
import '../../../data/models/diary_entry.dart';

/// Diary Entry Card Widget
/// Displays a single diary entry with nutrition information
class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onDelete;

  const DiaryEntryCard({
    Key? key,
    required this.entry,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // Could show details dialog here
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Food icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),

              // Food info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.servingSize.toStringAsFixed(0)}g',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Nutrition info
                    Wrap(
                      spacing: 12,
                      children: [
                        _buildNutrientChip(
                          '${entry.calories.toStringAsFixed(0)} kkal',
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                        _buildNutrientChip(
                          '${entry.protein.toStringAsFixed(1)}g P',
                          Icons.egg,
                          Colors.blue,
                        ),
                        _buildNutrientChip(
                          '${entry.carbs.toStringAsFixed(1)}g C',
                          Icons.rice_bowl,
                          Colors.green,
                        ),
                        _buildNutrientChip(
                          '${entry.fat.toStringAsFixed(1)}g F',
                          Icons.water_drop,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red[400],
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
