# Perbaikan Error: toStringAsFixed() called on null

## Error yang Muncul

```
NoSuchMethodError: The method 'toStringAsFixed' was called on null.
Receiver: null
Tried calling: toStringAsFixed(0)
```

## Penyebab Error

Error ini terjadi karena:

1. **Inconsistent key naming** di `getDietPlanSummary()` method
   - Method menggunakan snake_case: `'target_calories'`, `'consumed_calories'`, dll
   - Widget menggunakan camelCase: `'targetCalories'`, `'consumedCalories'`, dll

2. **Missing null-safety checks** di widget
   - Widget langsung memanggil `.toStringAsFixed()` tanpa cek null
   - Saat key tidak ditemukan, nilai menjadi `null`
   - `null.toStringAsFixed()` menyebabkan error

## Lokasi Error

### File: `diet_plan_dashboard.dart`

Baris yang error:
```dart
// Baris 146 - Error karena key tidak cocok
summary['targetCalories'].toStringAsFixed(0)  // ❌ key tidak ada

// Baris 322, 333, 359 - Error karena key tidak cocok
summary['bmr'].toStringAsFixed(0)             // ❌ key tidak ada
summary['tdee'].toStringAsFixed(0)            // ❌ key tidak ada
summary['caloriesBurned'].toStringAsFixed(1)  // ❌ key tidak ada
```

### File: `diet_plan_provider.dart`

Method yang mengembalikan data dengan key yang salah:
```dart
Map<String, dynamic> getDietPlanSummary(double consumedCalories) {
  return {
    'target_calories': _targetCalories,    // ❌ snake_case
    'consumed_calories': consumedCalories, // ❌ snake_case
    'calories_burned': _caloriesBurned,    // ❌ snake_case
    // ...
  };
}
```

## Solusi yang Diterapkan

### 1. Perbaiki Key Naming di `diet_plan_provider.dart`

Ubah semua key dari snake_case ke camelCase:

```dart
Map<String, dynamic> getDietPlanSummary(double consumedCalories) {
  return {
    'bmr': _bmr,
    'tdee': _tdee,
    'targetCalories': _targetCalories,           // ✅ camelCase
    'consumedCalories': consumedCalories,        // ✅ camelCase
    'caloriesBurned': _caloriesBurned,           // ✅ camelCase
    'remainingCalories': getRemainingCalories(consumedCalories),
    'progressPercentage': getCalorieProgress(consumedCalories),
    'progressColor': getProgressColor(consumedCalories),
    'isExceeded': isCaloriesExceeded(consumedCalories),
    'excessAmount': getCalorieExcess(consumedCalories),
    'steps': _steps,
    'canCalculate': canCalculateDietPlan,
    'missingData': missingProfileData,
  };
}
```

### 2. Tambahkan Null-Safety Checks di `diet_plan_dashboard.dart`

Gunakan null-coalescing operator (`??`) untuk memberikan default value:

```dart
// Target Calories
Text(
  (summary['targetCalories'] ?? 0).toStringAsFixed(0),  // ✅ default 0
  // ...
)

// BMR
_buildMetricCard(
  'BMR',
  (summary['bmr'] ?? 0).toStringAsFixed(0),              // ✅ default 0
  // ...
)

// TDEE
_buildMetricCard(
  'TDEE',
  (summary['tdee'] ?? 0).toStringAsFixed(0),             // ✅ default 0
  // ...
)

// Steps
_buildMetricCard(
  'Langkah Kaki',
  (summary['steps'] ?? 0).toString(),                    // ✅ default 0
  // ...
)

// Calories Burned
_buildMetricCard(
  'Kalori Terbakar',
  (summary['caloriesBurned'] ?? 0.0).toStringAsFixed(1), // ✅ default 0.0
  // ...
)
```

## Penjelasan Null-Coalescing Operator

### Syntax: `value ?? defaultValue`

Operator `??` mengembalikan nilai di sebelah kiri jika tidak null, atau nilai di sebelah kanan jika null.

### Contoh:

```dart
// Tanpa null-safety (ERROR jika null)
int? value = null;
print(value.toString());  // ❌ Error: called on null

// Dengan null-safety (AMAN)
int? value = null;
print((value ?? 0).toString());  // ✅ Output: "0"
```

### Dalam Konteks Kita:

```dart
// SEBELUM (ERROR)
summary['targetCalories'].toStringAsFixed(0)
// Jika key tidak ada → null.toStringAsFixed(0) → ERROR

// SESUDAH (AMAN)
(summary['targetCalories'] ?? 0).toStringAsFixed(0)
// Jika key tidak ada → (null ?? 0).toStringAsFixed(0) → "0"
```

## Verifikasi Perbaikan

Jalankan command berikut untuk memastikan tidak ada error:

```bash
flutter analyze lib/presentation/providers/diet_plan_provider.dart lib/presentation/widgets/diet_plan/diet_plan_dashboard.dart
```

Output yang diharapkan:
```
No issues found!
```

## Testing

Jalankan test untuk memastikan perubahan tidak merusak fungsionalitas:

```bash
flutter test test/presentation/providers/diet_plan_provider_test.dart
```

## Checklist Perbaikan

- [x] Ubah key naming dari snake_case ke camelCase di `getDietPlanSummary()`
- [x] Tambahkan null-safety check untuk `targetCalories`
- [x] Tambahkan null-safety check untuk `bmr`
- [x] Tambahkan null-safety check untuk `tdee`
- [x] Tambahkan null-safety check untuk `steps`
- [x] Tambahkan null-safety check untuk `caloriesBurned`
- [x] Verifikasi dengan `flutter analyze`
- [x] Test aplikasi untuk memastikan UI muncul tanpa error

## Best Practices untuk Menghindari Error Serupa

### 1. Consistent Naming Convention

Pilih satu convention dan gunakan secara konsisten:

```dart
// ✅ GOOD - Consistent camelCase
Map<String, dynamic> data = {
  'firstName': 'John',
  'lastName': 'Doe',
  'phoneNumber': '123456',
};

// ❌ BAD - Mixed conventions
Map<String, dynamic> data = {
  'first_name': 'John',    // snake_case
  'lastName': 'Doe',       // camelCase
  'phone-number': '123456', // kebab-case
};
```

### 2. Always Use Null-Safety

Selalu gunakan null-safety checks saat mengakses dynamic data:

```dart
// ✅ GOOD - Safe access
final value = (data['key'] ?? defaultValue).toString();

// ❌ BAD - Unsafe access
final value = data['key'].toString();  // Crash jika null
```

### 3. Type-Safe Models

Gunakan typed models daripada `Map<String, dynamic>`:

```dart
// ✅ GOOD - Type-safe model
class DietPlanSummary {
  final double? bmr;
  final double? tdee;
  final double targetCalories;
  final int steps;
  final double caloriesBurned;
  
  DietPlanSummary({
    this.bmr,
    this.tdee,
    required this.targetCalories,
    required this.steps,
    required this.caloriesBurned,
  });
}

// Usage
final summary = provider.getDietPlanSummary();
Text(summary.targetCalories.toStringAsFixed(0))  // Type-safe!
```

### 4. Defensive Programming

Selalu asumsikan data bisa null:

```dart
// ✅ GOOD - Defensive
Widget buildValue(Map<String, dynamic> data) {
  final value = data['value'];
  if (value == null) {
    return Text('N/A');
  }
  return Text(value.toString());
}

// ❌ BAD - Optimistic
Widget buildValue(Map<String, dynamic> data) {
  return Text(data['value'].toString());  // Assumes never null
}
```

## Troubleshooting

### Jika masih muncul error "called on null":

1. **Cek key naming**
   - Pastikan key di provider dan widget sama persis
   - Case-sensitive: `'targetCalories'` ≠ `'target_calories'`

2. **Tambahkan null checks**
   - Gunakan `??` operator untuk default values
   - Atau gunakan conditional rendering

3. **Debug dengan print**
   ```dart
   final summary = provider.getDietPlanSummary();
   print('Summary keys: ${summary.keys}');
   print('Target calories: ${summary['targetCalories']}');
   ```

4. **Pastikan provider initialized**
   - Cek apakah `setUser()` sudah dipanggil
   - Cek apakah `calculateBMR()`, `calculateTDEE()`, dll sudah dipanggil

### Jika nilai masih 0 padahal seharusnya ada:

1. **Cek user data**
   ```dart
   print('User: ${provider.user}');
   print('Weight: ${provider.user?.weight}');
   print('Height: ${provider.user?.height}');
   print('Age: ${provider.user?.age}');
   ```

2. **Cek kalkulasi**
   ```dart
   print('BMR: ${provider.bmr}');
   print('TDEE: ${provider.tdee}');
   print('Target: ${provider.targetCalories}');
   ```

3. **Pastikan data profil lengkap**
   - Berat badan, tinggi badan, dan usia harus terisi
   - Gunakan `canCalculateDietPlan` untuk validasi

## Kesimpulan

Error "toStringAsFixed() called on null" terjadi karena:
1. ❌ Inconsistent key naming (snake_case vs camelCase)
2. ❌ Missing null-safety checks

Solusinya:
1. ✅ Gunakan consistent naming convention (camelCase)
2. ✅ Tambahkan null-safety checks dengan `??` operator
3. ✅ Defensive programming untuk handle edge cases

Setelah perbaikan, UI Pedometer dapat ditampilkan tanpa error di Tab Home (Dashboard).
