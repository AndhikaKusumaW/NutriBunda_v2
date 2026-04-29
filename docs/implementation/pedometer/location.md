# Lokasi UI Pedometer di Aplikasi NutriBunda

## 📍 Dimana UI Pedometer Berada?

UI Pedometer/Jalan Kaki berada di **Tab Home (Dashboard)** aplikasi NutriBunda.

### Cara Mengakses:

1. **Buka aplikasi NutriBunda**
2. **Pastikan Anda sudah login**
3. **Tap tab "Home"** di bottom navigation bar (icon rumah)
4. **Scroll ke bawah** setelah bagian tanggal
5. **UI Pedometer akan muncul** di section "Diet Plan & Aktivitas"

### Struktur Tampilan di Tab Home:

```
┌─────────────────────────────────────┐
│ Dashboard                           │
├─────────────────────────────────────┤
│ 📅 Ringkasan Hari Ini               │
│    Rabu, 29 April 2026              │
├─────────────────────────────────────┤
│                                     │
│ 💪 Diet Plan & Aktivitas            │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🚶 Pedometer      [🟢 Aktif]   │ │
│ │                                 │ │
│ │     🟢 1,234 langkah            │ │
│ │     🔥 2.4 kkal terbakar        │ │
│ │                                 │ │
│ │  [Berhenti]       [Reset]      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Diet Plan Summary               │ │
│ │ Target: 1800 kkal               │ │
│ │ BMR: 1400 kkal                  │ │
│ │ TDEE: 2100 kkal                 │ │
│ └─────────────────────────────────┘ │
│                                     │
├─────────────────────────────────────┤
│ 👶 Nutrisi Bayi                     │
│    (Chart & Progress Bars)          │
├─────────────────────────────────────┤
│ 👩 Nutrisi Ibu                      │
│    (Chart & Progress Bars)          │
├─────────────────────────────────────┤
│ 🎲 Shake-to-Recipe                  │
├─────────────────────────────────────┤
│ ⚡ Aksi Cepat                       │
│    - Tambah Makanan Bayi            │
│    - Tambah Makanan Ibu             │
│    - Kuis Gizi Bunda                │
│    - TanyaBunda AI                  │
│    - Resep Favorit                  │
│    - Pengaturan Notifikasi          │
└─────────────────────────────────────┘
```

## 🔧 Persyaratan untuk Melihat UI Pedometer

UI Pedometer hanya akan muncul jika **data profil Anda sudah lengkap**:

### Data yang Diperlukan:
- ✅ **Berat Badan** (kg)
- ✅ **Tinggi Badan** (cm)
- ✅ **Usia** (tahun)

### Jika Data Belum Lengkap:

Anda akan melihat card informasi seperti ini:

```
┌─────────────────────────────────────┐
│ 🚶 Diet Plan & Pedometer            │
│                                     │
│ Lengkapi data profil Anda           │
│ (berat badan, tinggi badan, usia)   │
│ untuk menggunakan fitur ini         │
│                                     │
│     [Lengkapi Profil]               │
└─────────────────────────────────────┘
```

Tap tombol **"Lengkapi Profil"** untuk mengisi data yang diperlukan.

## 🎯 Fitur UI Pedometer

### 1. **Auto-Start**
- Pedometer otomatis mulai tracking saat Anda membuka tab Home
- Tidak perlu tap tombol "Mulai" secara manual

### 2. **Status Indicator**
- 🟢 **Aktif** - Pedometer sedang tracking langkah Anda
- ⚫ **Berhenti** - Pedometer tidak tracking
- 🔴 **Error** - Ada masalah dengan sensor

### 3. **Step Counter**
- Menampilkan jumlah langkah hari ini
- Update secara real-time
- Pulsing dot hijau saat aktif tracking

### 4. **Calories Burned**
- Menghitung kalori terbakar dari langkah kaki
- Formula: `langkah × 0.04 × berat_badan / 1000`
- Ditampilkan dengan icon api 🔥

### 5. **Control Buttons**

**Tombol Berhenti/Mulai:**
- Tap untuk pause/resume tracking
- Warna berubah sesuai status (Biru = Mulai, Orange = Berhenti)

**Tombol Reset:**
- Tap untuk reset hitungan langkah hari ini
- Akan muncul dialog konfirmasi untuk mencegah reset tidak sengaja

## 📱 Bottom Navigation Tabs

```
┌─────────────────────────────────────┐
│  🏠      📖      🗺️      👤        │
│ Home   Diary   Peta   Profil       │
└─────────────────────────────────────┘
     ↑
  Pedometer ada di sini!
```

## 🔍 Troubleshooting

### Tidak Melihat UI Pedometer?

**Kemungkinan Penyebab:**

1. **Data profil belum lengkap**
   - Solusi: Tap "Lengkapi Profil" atau buka tab Profil untuk mengisi data

2. **Belum membuka tab Home**
   - Solusi: Tap icon rumah (🏠) di bottom navigation

3. **Perlu scroll ke bawah**
   - Solusi: Scroll layar ke bawah setelah bagian tanggal

### Pedometer Menampilkan Error?

**Kemungkinan Penyebab:**

1. **Izin sensor belum diberikan**
   - Solusi: Ikuti instruksi di dialog untuk mengaktifkan izin sensor di pengaturan perangkat

2. **Perangkat tidak mendukung pedometer**
   - Solusi: Gunakan perangkat yang memiliki sensor accelerometer/step counter

3. **Sensor sedang digunakan aplikasi lain**
   - Solusi: Tutup aplikasi lain yang menggunakan sensor langkah

## 📂 File Lokasi (Untuk Developer)

### Widget Pedometer:
```
nutribunda/lib/presentation/widgets/diet_plan/pedometer_controls.dart
```

### Dashboard Screen (yang menampilkan pedometer):
```
nutribunda/lib/presentation/pages/dashboard/dashboard_screen.dart
```

### Test File:
```
nutribunda/test/presentation/widgets/diet_plan/pedometer_controls_test.dart
```

## ✅ Checklist Penggunaan

- [ ] Login ke aplikasi
- [ ] Lengkapi data profil (berat badan, tinggi badan, usia)
- [ ] Buka tab Home
- [ ] Scroll ke section "Diet Plan & Aktivitas"
- [ ] Lihat UI Pedometer dengan jumlah langkah
- [ ] Pedometer otomatis mulai tracking
- [ ] Gunakan tombol Berhenti/Mulai untuk kontrol manual
- [ ] Gunakan tombol Reset untuk reset hitungan harian

---

**Catatan:** UI Pedometer terintegrasi dengan Diet Plan untuk menghitung total kalori terbakar dari aktivitas fisik Anda, yang akan mempengaruhi sisa kalori harian Anda.
