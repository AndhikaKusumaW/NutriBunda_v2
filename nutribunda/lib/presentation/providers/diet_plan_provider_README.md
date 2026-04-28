# DietPlanProvider

## Overview

`DietPlanProvider` adalah provider untuk mengelola Diet Plan ibu pasca-melahirkan dengan kalkulasi BMR (Basal Metabolic Rate) dan TDEE (Total Daily Energy Expenditure). Provider ini mengimplementasikan Requirements 5.1 - 5.11 dari spesifikasi NutriBunda.

## Features

### 1. BMR Calculation (Requirement 5.1)
Menghitung BMR menggunakan **Mifflin-St Jeor formula** untuk wanita:

```
BMR = (10 × weight_kg) + (6.25 × height_cm) − (5 × age_years) − 161
```

**Contoh:**
- Berat: 60 kg
- Tinggi: 165 cm
- Usia: 30 tahun
- BMR = (10 × 60) + (6.25 × 165) − (5 × 30) − 161 = **1320.25 kcal**

### 2. TDEE Calculation (Requirement 5.2)
Menghitung TDEE dengan mengalikan BMR dengan activity factor:

| Activity Level | Factor | Description |
|---------------|--------|-------------|
| Sedentary | 1.2 | Aktivitas minimal, duduk sepanjang hari |
| Lightly Active | 1.375 | Olahraga ringan 1-3 hari/minggu |
| Moderately Active | 1.55 | Olahraga sedang 3-5 hari/minggu |

**Formula:**
```
TDEE = BMR × Activity Factor
```

### 3. Target Calories (Requirements 5.3, 5.4)
Menghitung target kalori harian dengan:
- **Safe Deficit**: Maksimal 500 kcal di bawah TDEE
- **Breastfeeding Adjustment**: Tambahan 300-500 kcal (rata-rata 400 kcal) jika menyusui
- **Safety Minimum**: Tidak boleh kurang dari 80% BMR

**Formula:**
```
Target = TDEE - 500 (deficit)
If breastfeeding: Target = Target + 400
If Target < (BMR × 0.8): Target = BMR × 0.8
```

### 4. Automatic Recalculation (Requirement 5.5)
Provider secara otomatis menghitung ulang BMR, TDEE, dan target kalori ketika:
- User data diupdate (weight, height, age)
- Activity level berubah
- Breastfeeding status berubah

### 5. Step Tracking (Requirements 5.6, 5.7)
Menghitung kalori yang terbakar dari langkah kaki:

**Formula:**
```
Calories Burned = steps × 0.04 × weight_kg / 1000
```

**Contoh:**
- Steps: 10,000 langkah
- Weight: 60 kg
- Calories Burned = 10,000 × 0.04 × 60 / 1000 = **24 kcal**

### 6. Progress Tracking (Requirements 5.8, 5.9, 5.10)
- **Remaining Calories**: Target - Consumed + Burned
- **Progress Percentage**: (Consumed - Burned) / Target × 100%
- **Color Coding**:
  - 🟢 Green: 0-80% (on track)
  - 🟡 Yellow: 81-100% (approaching limit)
  - 🔴 Red: >100% (exceeded)
- **Excess Warning**: Menampilkan selisih kalori yang melebihi target

## Usage

### Basic Setup

```dart
import 'package:provider/provider.dart';
import 'package:nutribunda/presentation/providers/diet_plan_provider.dart';
import 'package:nutribunda/data/models/user_model.dart';

// In your widget tree
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => DietPlanProvider()),
  ],
  child: MyApp(),
)
```

### Setting User Data

```dart
final dietPlanProvider = context.read<DietPlanProvider>();

final user = UserModel(
  id: 'user-123',
  email: 'user@example.com',
  fullName: 'Jane Doe',
  weight: 60.0,      // kg
  height: 165.0,     // cm
  age: 30,           // years
  isBreastfeeding: true,
  activityLevel: 'lightly_active',
  timezone: 'WIB',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Set user - automatically calculates BMR, TDEE, and target calories
dietPlanProvider.setUser(user);
```

### Checking if Diet Plan Can Be Calculated

```dart
if (dietPlanProvider.canCalculateDietPlan) {
  // All required data is available
  print('BMR: ${dietPlanProvider.bmr}');
  print('TDEE: ${dietPlanProvider.tdee}');
  print('Target Calories: ${dietPlanProvider.targetCalories}');
} else {
  // Show missing data
  final missing = dietPlanProvider.missingProfileData;
  print('Missing data: ${missing.join(', ')}');
}
```

### Updating User Profile

```dart
// Update specific fields - automatically recalculates
dietPlanProvider.updateUserProfile(
  weight: 58.0,  // Lost 2 kg
  activityLevel: 'moderately_active',  // Increased activity
  isBreastfeeding: false,  // Stopped breastfeeding
);
```

### Tracking Steps

```dart
// Update steps from pedometer
dietPlanProvider.updateSteps(8500);

print('Steps: ${dietPlanProvider.steps}');
print('Calories Burned: ${dietPlanProvider.caloriesBurned}');

// Reset at midnight
dietPlanProvider.resetDailySteps();
```

### Getting Calorie Progress

```dart
final consumedCalories = 1200.0; // From food diary

// Get remaining calories
final remaining = dietPlanProvider.getRemainingCalories(consumedCalories);
print('Remaining: $remaining kcal');

// Get progress percentage
final progress = dietPlanProvider.getCalorieProgress(consumedCalories);
print('Progress: $progress%');

// Get progress color
final color = dietPlanProvider.getProgressColor(consumedCalories);
print('Color: $color'); // 'green', 'yellow', or 'red'

// Check if exceeded
if (dietPlanProvider.isCaloriesExceeded(consumedCalories)) {
  final excess = dietPlanProvider.getCalorieExcess(consumedCalories);
  print('Warning: Exceeded by $excess kcal');
}
```

### Getting Complete Summary

```dart
final consumedCalories = 1200.0;
final summary = dietPlanProvider.getDietPlanSummary(consumedCalories);

print('BMR: ${summary['bmr']}');
print('TDEE: ${summary['tdee']}');
print('Target: ${summary['target_calories']}');
print('Consumed: ${summary['consumed_calories']}');
print('Burned: ${summary['calories_burned']}');
print('Remaining: ${summary['remaining_calories']}');
print('Progress: ${summary['progress_percentage']}%');
print('Color: ${summary['progress_color']}');
print('Exceeded: ${summary['is_exceeded']}');
print('Excess: ${summary['excess_amount']}');
print('Steps: ${summary['steps']}');
```

## UI Integration Example

### Diet Plan Dashboard

```dart
class DietPlanDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DietPlanProvider>(
      builder: (context, dietPlan, child) {
        if (!dietPlan.canCalculateDietPlan) {
          return _buildMissingDataWarning(dietPlan.missingProfileData);
        }

        final consumedCalories = 1200.0; // Get from FoodDiaryProvider
        final summary = dietPlan.getDietPlanSummary(consumedCalories);

        return Column(
          children: [
            _buildCalorieCard(summary),
            _buildProgressBar(summary),
            _buildStepsCard(summary),
            if (summary['is_exceeded'])
              _buildExcessWarning(summary['excess_amount']),
          ],
        );
      },
    );
  }

  Widget _buildCalorieCard(Map<String, dynamic> summary) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Target Kalori Harian'),
            Text(
              '${summary['target_calories'].toStringAsFixed(0)} kcal',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric('BMR', summary['bmr']),
                _buildMetric('TDEE', summary['tdee']),
                _buildMetric('Sisa', summary['remaining_calories']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(Map<String, dynamic> summary) {
    final progress = summary['progress_percentage'];
    final color = _getColorFromString(summary['progress_color']);

    return LinearProgressIndicator(
      value: (progress / 100).clamp(0.0, 1.0),
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation<Color>(color),
      minHeight: 10,
    );
  }

  Widget _buildStepsCard(Map<String, dynamic> summary) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.directions_walk),
        title: Text('${summary['steps']} langkah'),
        subtitle: Text('${summary['calories_burned'].toStringAsFixed(1)} kcal terbakar'),
      ),
    );
  }

  Widget _buildExcessWarning(double excess) {
    return Card(
      color: Colors.red[50],
      child: ListTile(
        leading: Icon(Icons.warning, color: Colors.red),
        title: Text('Kalori Melebihi Target'),
        subtitle: Text('Anda melebihi ${excess.toStringAsFixed(0)} kcal'),
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow[700]!;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMetric(String label, dynamic value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMissingDataWarning(List<String> missingData) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Data Profil Belum Lengkap',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Silakan lengkapi data berikut:'),
            ...missingData.map((data) => Text('• $data')),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to profile edit
              },
              child: Text('Lengkapi Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Testing

Comprehensive unit tests are available in `test/presentation/providers/diet_plan_provider_test.dart`.

Run tests:
```bash
flutter test test/presentation/providers/diet_plan_provider_test.dart
```

Test coverage includes:
- ✅ BMR calculation accuracy (Mifflin-St Jeor formula)
- ✅ TDEE calculation with activity factors
- ✅ Target calories with safe deficit
- ✅ Breastfeeding calorie adjustment
- ✅ Automatic recalculation on data changes
- ✅ Step tracking and calorie burn calculation
- ✅ Progress tracking and color coding
- ✅ Excess calorie warnings
- ✅ Missing data validation

## Requirements Mapping

| Requirement | Feature | Status |
|------------|---------|--------|
| 5.1 | BMR calculation (Mifflin-St Jeor) | ✅ Implemented |
| 5.2 | TDEE calculation with activity factors | ✅ Implemented |
| 5.3 | Safe calorie deficit (max 500 kcal) | ✅ Implemented |
| 5.4 | Breastfeeding calorie adjustment (+400 kcal) | ✅ Implemented |
| 5.5 | Automatic recalculation on profile update | ✅ Implemented |
| 5.6 | Step counting integration | ✅ Implemented |
| 5.7 | Calorie burn from steps | ✅ Implemented |
| 5.8 | Remaining calories calculation | ✅ Implemented |
| 5.9 | Progress bar with color coding | ✅ Implemented |
| 5.10 | Excess calorie warning | ✅ Implemented |
| 5.11 | Missing data validation | ✅ Implemented |

## Notes

### BMR Formula Choice
Menggunakan **Mifflin-St Jeor formula** karena:
- Lebih akurat untuk populasi modern
- Direkomendasikan oleh Academy of Nutrition and Dietetics
- Lebih baik untuk wanita dengan berbagai tingkat aktivitas

### Safety Considerations
- Target kalori tidak boleh kurang dari 80% BMR untuk keamanan
- Defisit maksimal 500 kcal per hari untuk penurunan berat badan yang sehat (0.5 kg/minggu)
- Kalori tambahan untuk menyusui sesuai rekomendasi WHO (300-500 kcal)

### Integration with Other Providers
- **FoodDiaryProvider**: Mendapatkan consumed calories dari nutrition summary
- **PedometerService**: Mendapatkan step count untuk calorie burn calculation
- **AuthProvider**: Mendapatkan user data untuk BMR/TDEE calculation

## Future Enhancements
- [ ] Support for custom activity factors
- [ ] Weekly/monthly progress tracking
- [ ] Weight loss goal setting and tracking
- [ ] Macronutrient distribution recommendations
- [ ] Integration with fitness trackers (Fitbit, Apple Health)
