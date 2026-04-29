# Perbaikan Error: Provider Not Found

## Error yang Muncul

```
Error: Could not find the correct Provider<DietPlanProvider> above this Consumer<DietPlanProvider> Widget
```

## Penyebab Error

Error ini terjadi karena `DietPlanProvider` tidak tersedia di widget tree saat `DashboardScreen` mencoba mengaksesnya dengan `Consumer<DietPlanProvider>`.

### Penjelasan Detail:

1. **Dashboard screen** menggunakan `Consumer<DietPlanProvider>` untuk menampilkan UI pedometer
2. **Provider tidak terdaftar** di `MultiProvider` di `main.dart`
3. **Flutter tidak bisa menemukan** provider yang diminta oleh Consumer

## Solusi yang Diterapkan

### 1. Menambahkan Import di `main.dart`

```dart
import 'presentation/providers/diet_plan_provider.dart';
```

### 2. Menambahkan DietPlanProvider ke MultiProvider

Di `main.dart`, tambahkan provider ke list:

```dart
MultiProvider(
  providers: [
    // ... providers lain ...
    ChangeNotifierProvider(
      create: (_) => di.sl<DietPlanProvider>(),
    ),
  ],
  // ...
)
```

### 3. Mendaftarkan DietPlanProvider di Dependency Injection

Di `injection_container.dart`:

**Import:**
```dart
import 'presentation/providers/diet_plan_provider.dart';
import 'core/services/pedometer_service.dart';
```

**Registrasi Service:**
```dart
// Pedometer Service - untuk menghitung langkah kaki
sl.registerLazySingleton<PedometerService>(
  () => PedometerService(),
);
```

**Registrasi Provider:**
```dart
// Diet Plan Provider
sl.registerFactory(() => DietPlanProvider());
```

### 4. Perbaikan Navigation di Dashboard

Mengganti:
```dart
DefaultTabController.of(context)?.animateTo(3);
```

Menjadi:
```dart
Navigator.pushNamed(context, '/profile');
```

Karena `MainNavigation` tidak menggunakan `DefaultTabController`, melainkan `IndexedStack`.

## Struktur Provider Hierarchy

Setelah perbaikan, struktur provider menjadi:

```
MyApp (MaterialApp)
└── MultiProvider
    ├── AuthProvider
    ├── ProfileProvider
    ├── FoodDiaryProvider
    ├── RecipeProvider
    ├── ChatProvider
    ├── QuizProvider
    ├── NotificationProvider
    └── DietPlanProvider ← DITAMBAHKAN
        └── MainNavigation
            └── DashboardScreen
                └── Consumer<DietPlanProvider> ← BISA AKSES PROVIDER
```

## Cara Kerja Provider Pattern

### 1. **Registrasi di Dependency Injection**
```dart
sl.registerFactory(() => DietPlanProvider());
```
- Mendaftarkan cara membuat instance `DietPlanProvider`
- `registerFactory` = buat instance baru setiap kali diminta

### 2. **Provide di Widget Tree**
```dart
ChangeNotifierProvider(
  create: (_) => di.sl<DietPlanProvider>(),
  child: MaterialApp(...),
)
```
- Membuat instance provider dan menempatkannya di widget tree
- Semua widget di bawahnya bisa mengakses provider ini

### 3. **Consume di Widget**
```dart
Consumer<DietPlanProvider>(
  builder: (context, provider, child) {
    return Text('Steps: ${provider.steps}');
  },
)
```
- Widget mengakses provider dari widget tree
- Otomatis rebuild saat provider berubah

## Verifikasi Perbaikan

Jalankan command berikut untuk memastikan tidak ada error:

```bash
flutter analyze lib/main.dart lib/injection_container.dart lib/presentation/pages/dashboard/dashboard_screen.dart
```

Output yang diharapkan:
```
No issues found!
```

## Testing

Jalankan test untuk memastikan semua berfungsi:

```bash
flutter test test/presentation/widgets/diet_plan/pedometer_controls_test.dart
```

Output yang diharapkan:
```
00:03 +14: All tests passed!
```

## Checklist Perbaikan

- [x] Import `DietPlanProvider` di `main.dart`
- [x] Tambahkan `DietPlanProvider` ke `MultiProvider`
- [x] Import `DietPlanProvider` dan `PedometerService` di `injection_container.dart`
- [x] Registrasi `PedometerService` di dependency injection
- [x] Registrasi `DietPlanProvider` di dependency injection
- [x] Perbaiki navigation di dashboard (hapus `DefaultTabController`)
- [x] Verifikasi dengan `flutter analyze`
- [x] Test pedometer controls

## Catatan Penting

### Kapan Menggunakan registerFactory vs registerLazySingleton?

**registerFactory:**
- Digunakan untuk **Providers** (ChangeNotifier)
- Membuat instance baru setiap kali diminta
- Cocok untuk stateful objects yang perlu di-dispose

**registerLazySingleton:**
- Digunakan untuk **Services** (stateless utilities)
- Membuat instance sekali dan reuse
- Cocok untuk services yang tidak memiliki state

### Contoh:

```dart
// Provider - buat baru setiap kali
sl.registerFactory(() => DietPlanProvider());

// Service - singleton, reuse instance yang sama
sl.registerLazySingleton<PedometerService>(
  () => PedometerService(),
);
```

## Troubleshooting

### Jika masih muncul error "Provider not found":

1. **Pastikan provider terdaftar di `main.dart`**
   - Cek apakah ada di list `providers` di `MultiProvider`

2. **Pastikan import sudah benar**
   - Cek path import di `main.dart` dan `injection_container.dart`

3. **Restart aplikasi**
   - Hot reload mungkin tidak cukup untuk perubahan provider
   - Gunakan hot restart atau stop & run ulang

4. **Clear build cache**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Jika error "Undefined class 'DietPlanProvider'":

1. **Pastikan file provider ada**
   - Cek `lib/presentation/providers/diet_plan_provider.dart` exists

2. **Pastikan import path benar**
   - Relative path harus sesuai dengan struktur folder

3. **Run pub get**
   ```bash
   flutter pub get
   ```

## Kesimpulan

Error "Provider not found" terjadi karena:
1. Provider tidak terdaftar di dependency injection
2. Provider tidak di-provide di widget tree
3. Widget mencoba mengakses provider yang tidak ada

Solusinya adalah memastikan provider:
1. ✅ Terdaftar di `injection_container.dart`
2. ✅ Di-provide di `main.dart` dengan `MultiProvider`
3. ✅ Dapat diakses oleh widget yang membutuhkan

Setelah perbaikan, UI Pedometer dapat diakses di **Tab Home (Dashboard)** tanpa error.
