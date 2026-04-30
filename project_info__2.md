# NutriBunda_v2 — Codebase Overview (Focus: Fitur Notifikasi)

## Summary
NutriBunda_v2 adalah aplikasi Flutter untuk pemantauan gizi MPASI anak usia 6–24 bulan dan dukungan diet pemulihan ibu pasca-melahirkan. Fitur notifikasi seharusnya memberi pengingat jadwal makan MPASI dan vitamin secara lokal (offline-first) menggunakan `flutter_local_notifications` dengan dukungan timezone. Dari pembacaan kode, ada inkonsistensi besar antara implementasi notifikasi “real” (`NotificationService`) dan implementasi yang dipakai oleh halaman pengaturan (`NotificationServiceRef`) sehingga notifikasi sering tidak muncul sesuai ekspektasi.

## Architecture
- **Pola utama**: Flutter dengan **Dependency Injection (get_it)** + **state management Provider**.
- **Sub-sistem notifikasi**:
  1. `NotificationService` (core) — implementasi lengkap: inisialisasi timezone, buat notification channel, scheduling repeating via `zonedSchedule`.
  2. `NotificationProvider` (presentation) — menyimpan setting notifikasi (SharedPreferences) dan memanggil `NotificationService` untuk scheduling/cancel ketika izin dan setting valid.
  3. `NotificationServiceRef` (utility/ref) — implementasi lain yang lebih “simplified/demonstration”, dipakai langsung oleh halaman setting.
  4. `NotificationSettingsPage` — UI setting notifikasi, memanggil `NotificationServiceRef`, bukan `NotificationProvider`/`NotificationService`.

### Entry point eksekusi
- Aplikasi dimulai dari `nutribunda/lib/main.dart`.
- DI diinisialisasi lewat `nutribunda/lib/injection_container.dart`.
- Provider `NotificationProvider` didaftarkan di `main.dart`, tetapi **tidak ada pemanggilan `NotificationProvider.initialize()` saat startup** pada `main.dart` (yang membuat scheduling “real” tidak otomatis berjalan saat app dibuka).

## Directory Structure (ringkas yang relevan)
```text
nutribunda/
├── lib/
│   ├── main.dart                         # register providers + routes
│   ├── injection_container.dart         # get_it DI
│   ├── core/
│   │   └── services/
│   │       ├── notification_service.dart      # scheduling repeating + timezone
│   │       └── notification_service_ref.dart  # scheduling “ref”/simplified
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── notification_provider.dart     # state + call NotificationService
│   │   └── pages/settings/
│   │       └── notification_settings_page.dart # UI pengaturan notifikasi
```

## Key Abstractions

### NotificationService
- **File**: `nutribunda/lib/core/services/notification_service.dart`
- **Responsibility**: “Engine” notifikasi lokal:
  - `initialize()` → `tz.initializeTimeZones()`, inisialisasi plugin, buat notification channels Android.
  - `requestPermissions()` → minta izin Android/iOS.
  - `scheduleMpasiReminders()` → scheduling repeating MPASI dengan `zonedSchedule` (menghitung next instance dan match time components).
  - `scheduleVitaminReminder()` → scheduling repeating vitamin dengan `zonedSchedule`.
  - `cancelMpasiReminders()/cancelVitaminReminder()` → cancel per-id.
- **Interface penting**:
  - `Future<bool> initialize()`
  - `Future<bool> requestPermissions()`
  - `Future<void> scheduleMpasiReminders({timezone, enabledMeals})`
  - `Future<void> scheduleVitaminReminder({time, timezone, enabled})`
- **Lifecycle**: di-register sebagai singleton di `injection_container.dart`; tetapi **harus** dipanggil lewat `NotificationProvider.initialize()` atau UI lain agar schedule terjadi.
- **Used by**:
  - `NotificationProvider`

### NotificationProvider
- **File**: `nutribunda/lib/presentation/providers/notification_provider.dart`
- **Responsibility**: menyimpan state konfigurasi notifikasi + memastikan scheduling/cancel selaras dengan izin & setting.
- **Interface penting**:
  - `Future<void> initialize()`: memanggil `NotificationService.initialize()`, load SharedPreferences, cek `areNotificationsEnabled()`, lalu `_scheduleActiveNotifications()`.
  - `Future<bool> requestPermissions()`
  - `toggleMpasiNotifications(...)`, `toggleMpasiMeal(...)`, `toggleVitaminNotifications(...)`
  - `changeTimezone(...)` → `NotificationService.updateTimezone(...)`
- **Lifecycle**:
  - `NotificationProvider` memang di-register di `main.dart`, tetapi **tidak dipanggil `initialize()` saat startup**. Jadi scheduling repeating “versi real” tidak otomatis terjadi ketika app dibuka.
- **Used by**:
  - (Secara kode yang terbaca) tidak tampak dipanggil langsung oleh UI setting; UI setting justru memakai `NotificationServiceRef`.

### NotificationServiceRef
- **File**: `nutribunda/lib/core/services/notification_service_ref.dart`
- **Responsibility**: implementasi ref/alternatif yang dipakai langsung oleh `NotificationSettingsPage`.
- **Interface penting**:
  - `initialize()` → inisialisasi plugin (tanpa timezone support).
  - `requestPermission()` → minta izin Android.
  - `scheduleDaily(...)` → **tidak menggunakan `hour`/`minute` untuk scheduling**; malah:
    - `cancelNotification(id)`
    - langsung memanggil `showNotification(...)` “sekarang” (demonstration).
- **Lifecycle**:
  - dipakai via `NotificationServiceRef()` (singleton internal), dipanggil `initialize()` di `initState()` halaman setting (tetapi tanpa `await`).
- **Used by**:
  - `NotificationSettingsPage` (langsung)

### NotificationSettingsPage
- **File**: `nutribunda/lib/presentation/pages/settings/notification_settings_page.dart`
- **Responsibility**: UI pengaturan pengingat MPASI & vitamin.
- **Interface penting**:
  - `initState()` memanggil `NotificationServiceRef().initialize()` (tanpa menunggu/await).
  - `_saveAll()`:
    - `await svc.requestPermission()`
    - jika enabled, memanggil `svc.scheduleDaily(id, ..., hour, minute)` untuk setiap jenis notifikasi,
    - jika disabled, `svc.cancelNotification(id)`.
- **Critical behavior**: halaman ini **tidak** memakai `NotificationProvider` maupun `NotificationService` (engine timezone repeating). Karena itu perilaku notifikasi mengikuti `NotificationServiceRef`, bukan perilaku yang “sesuai spec” dari `NotificationService`.

## Data Flow (alur utama yang terjadi saat fitur notifikasi)
1. User membuka pengaturan notifikasi → `NotificationSettingsPage`.
2. `initState()` memanggil `NotificationServiceRef.initialize()` (tanpa await).
3. User menekan “Simpan Pengaturan” → `_saveAll()`:
   - meminta izin via `NotificationServiceRef.requestPermission()`
   - untuk tiap item enabled:
     - memanggil `NotificationServiceRef.scheduleDaily(...)`
4. `NotificationServiceRef.scheduleDaily(...)`:
   - membatalkan notifikasi dengan id tersebut
   - **langsung memanggil `showNotification(...)` (sekali instan), bukan menjadwalkan untuk jam yang dipilih**
5. Hasilnya:
   - notifikasi tidak akan muncul “setiap hari pada jam X” seperti yang user harapkan,
   - dan bisa terlihat seperti “fitur notifikasi tidak jalan” bila user tidak melihat notifikasi instan atau melihatnya hanya sesaat.

## Non-Obvious Behaviors & Design Decisions (penyebab paling mungkin)

### 1) Ada dua implementasi notifikasi — dan UI setting memakai yang “salah untuk kebutuhan”
**Bukti**:
- Halaman setting: `NotificationSettingsPage` mengimpor dan memakai `core/services/notification_service_ref.dart`.
- Engine yang benar ada di `core/services/notification_service.dart` (timezone + repeating).
- `NotificationServiceRef.scheduleDaily()` mengabaikan parameter `hour`/`minute` dan hanya memanggil `showNotification(...)` segera.

**Dampak**:
- Jika user menyetel jam, ekspektasinya adalah notifikasi repeating sesuai jam.
- Faktanya: notifikasi hanya “ditampilkan langsung saat tombol simpan ditekan”, bukan dijadwalkan.

**Ini adalah penyebab paling kuat** untuk “notifikasi tidak mau muncul” / “tidak muncul sesuai jadwal”.

### 2) `NotificationProvider.initialize()` tidak dipanggil saat startup (sehingga engine real tidak otomatis schedule)
**Bukti**:
- `main.dart` mendaftarkan `ChangeNotifierProvider(create: (_) => di.sl<NotificationProvider>())`.
- Namun di potongan `main.dart` yang terbaca, tidak ada `..initialize()` untuk `NotificationProvider` (berbeda dengan `AuthProvider` yang memang dipanggil `initializeAuth()`).

**Dampak**:
- Bahkan bila UI lain di app mengandalkan `NotificationProvider`, scheduling “real” tidak akan terjadi sampai `initialize()` dipanggil dari tempat lain (dan dari file yang terbaca, UI setting tidak memanggil itu).

### 3) Channel id berbeda antara dua implementasi
**Bukti**:
- `NotificationService` memakai channel id:
  - `mpasi_reminders`
  - `vitamin_reminders`
- `NotificationServiceRef.showNotification()` memakai channel id:
  - `'nutribunda_channel'`

**Dampak potensial**:
- Jika channel `'nutribunda_channel'` tidak dibuat dengan benar, perilaku Android bisa jadi tidak sesuai.
- Tetapi meskipun itu, masalah “scheduleDaily langsung show” tetap menjadi akar utama.

### 4) `NotificationSettingsPage.initState()` memanggil `initialize()` tanpa `await`
**Bukti**:
- `svc.initialize();` tanpa `await`.

**Dampak potensial**:
- Ada race condition: user cepat menekan “Simpan Pengaturan” sebelum plugin selesai initialize.
- Namun karena `scheduleDaily` tetap langsung show, biasanya tetap terlihat jika race tidak fatal.

## Module Reference (yang paling relevan)
| File | Purpose |
|---|---|
| `nutribunda/lib/core/services/notification_service.dart` | Engine notifikasi: timezone + channel + repeating schedule via `zonedSchedule` |
| `nutribunda/lib/presentation/providers/notification_provider.dart` | Stateful orchestrator: load preferences, izin, schedule/cancel, update timezone |
| `nutribunda/lib/core/services/notification_service_ref.dart` | Implementasi ref: `scheduleDaily()` hanya show instan (bukan repeating) |
| `nutribunda/lib/presentation/pages/settings/notification_settings_page.dart` | UI settings notifikasi yang memanggil `NotificationServiceRef` |
| `nutribunda/lib/main.dart` | Register Provider; `NotificationProvider` tidak di-initialize otomatis |

## Suggested Reading Order
1. `nutribunda/lib/presentation/pages/settings/notification_settings_page.dart` — cari kenapa UI tidak memicu scheduling repeating.
2. `nutribunda/lib/core/services/notification_service_ref.dart` — fokus ke implementasi `scheduleDaily()` (ini akar masalah).
3. `nutribunda/lib/presentation/providers/notification_provider.dart` — lihat bagaimana seharusnya notifikasi dijadwalkan.
4. `nutribunda/lib/core/services/notification_service.dart` — lihat engine timezone + repeating yang “benar”.
5. `nutribunda/lib/main.dart` — konfirmasi bahwa `NotificationProvider.initialize()` tidak dipanggil otomatis.

## Checklist Diagnosa Cepat (untuk memperkuat temuan)
- [x] Cek UI setting: `NotificationSettingsPage` memakai `NotificationServiceRef`, bukan `NotificationProvider/NotificationService`.
- [x] Cek implementasi `scheduleDaily`: ternyata hanya memanggil `showNotification()` instan dan mengabaikan `hour/minute`.
- [x] Cek startup flow: `NotificationProvider` tidak di-initialize otomatis di `main.dart`.
- [ ] (Untuk investigasi lanjut di sesi berikutnya) cari apakah ada tempat lain yang memanggil `NotificationProvider.initialize()` selain dari setting page.
- [ ] (Untuk investigasi lanjut) cek logcat/device output saat menekan “Simpan Pengaturan” untuk melihat apakah scheduling benar-benar dilakukan.

## Kesimpulan (jawaban pertanyaan user)
Fitur notifikasi tidak berjalan semestinya terutama karena **inkonsistensi penggunaan service**:
- `NotificationSettingsPage` memakai `NotificationServiceRef`, dan `scheduleDaily()` pada service itu **tidak menjadwalkan** notifikasi repeating sesuai jam, melainkan **hanya menampilkan notifikasi instan**.
- Di sisi lain, implementasi yang benar untuk repeating (timezone + `zonedSchedule`) ada di `NotificationService` dan diorkestrasi oleh `NotificationProvider`, tetapi `NotificationProvider.initialize()` **tidak dipanggil saat startup**, sehingga engine “real” tidak otomatis schedule.

Jika Anda ingin, saya bisa lanjutkan dengan menelusuri: (1) apakah ada halaman lain yang seharusnya memanggil `NotificationProvider.initialize()`; (2) apakah ada dependensi/flow offline-first yang memutus scheduling saat user login/logout.