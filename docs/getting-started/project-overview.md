# NutriBunda - Project Overview

Aplikasi mobile Flutter untuk memantau gizi MPASI (Makanan Pendamping ASI) anak usia 6–24 bulan dan mendukung program diet pemulihan pasca-melahirkan bagi ibu.

## 📱 Fitur Utama

- **Autentikasi Aman**: Login dengan JWT dan autentikasi biometrik (sidik jari/Face ID)
- **Food Diary**: Pencatatan makanan harian untuk bayi dan ibu
- **Diet Plan**: Kalkulasi BMR/TDEE dan tracking kalori dengan pedometer
- **Shake-to-Recipe**: Rekomendasi resep MPASI dengan menggoyangkan smartphone
- **TanyaBunda AI**: Chatbot konsultan gizi berbasis Gemini API
- **Location-Based Service**: Pencarian fasilitas kesehatan terdekat
- **Kuis Gizi**: Mini game edukatif tentang nutrisi
- **Notifikasi**: Pengingat jadwal makan MPASI dan vitamin
- **Offline-First**: Aplikasi tetap berfungsi tanpa koneksi internet

## 🏗️ Arsitektur

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Local Storage**: SQLite + flutter_secure_storage
- **Sensors**: Pedometer, Accelerometer, GPS
- **Maps**: Google Maps Flutter

### Backend (Golang)
- **Framework**: Gin
- **Database**: PostgreSQL 14+
- **ORM**: GORM
- **Authentication**: JWT + bcrypt

## 📁 Struktur Proyek

```
NutriBunda/
├── nutribunda/              # Flutter mobile app
│   ├── lib/
│   │   ├── core/           # Core utilities, constants, services
│   │   ├── data/           # Data layer (models, repositories, datasources)
│   │   ├── domain/         # Domain layer (entities, repositories, usecases)
│   │   ├── presentation/   # Presentation layer (providers, pages, widgets)
│   │   └── main.dart
│   └── pubspec.yaml
│
├── backend/                # Golang backend API
│   ├── cmd/
│   │   ├── api/           # Main API server
│   │   └── test-db/       # Database connection test
│   ├── internal/          # Internal packages
│   │   ├── auth/          # Authentication logic
│   │   ├── user/          # User management
│   │   ├── food/          # Food database
│   │   ├── diary/         # Food diary
│   │   ├── recipe/        # Recipe management
│   │   ├── quiz/          # Quiz game
│   │   ├── database/      # Database models and migrations
│   │   └── middleware/    # HTTP middlewares
│   ├── pkg/               # Public packages
│   ├── configs/           # Configuration
│   └── go.mod
│
├── database/              # Database setup
│   ├── init/             # Initialization scripts
│   └── README.md
│
├── docs/                 # Documentation
│   ├── getting-started/  # Setup guides
│   ├── backend/          # Backend documentation
│   ├── frontend/         # Frontend documentation
│   ├── implementation/   # Implementation guides
│   ├── tasks/            # Task summaries
│   └── testing/          # Testing documentation
│
├── .kiro/                # Kiro specs
│   └── specs/
│       └── nutribunda/
│           ├── requirements.md
│           ├── design.md
│           └── tasks.md
│
├── docker-compose.yml    # PostgreSQL container
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.x
- Go 1.26+
- Docker Desktop
- PostgreSQL client (optional)

### Setup Steps

1. [Database Setup](./database-setup.md) - Setup PostgreSQL dengan Docker
2. [Backend Setup](./backend-setup.md) - Setup Golang backend API
3. [Flutter Setup](./flutter-setup.md) - Setup Flutter mobile app

## 🗄️ Database

### Tables

1. **users** - Data pengguna
2. **foods** - Database makanan dan nutrisi
3. **recipes** - Resep MPASI
4. **diary_entries** - Catatan makanan harian
5. **favorite_recipes** - Resep favorit pengguna
6. **quiz_questions** - Pertanyaan kuis
7. **notifications** - Pengaturan notifikasi

### Migrations

Migrations dijalankan otomatis saat backend start menggunakan GORM AutoMigrate.

## 📦 Dependencies

### Flutter Dependencies
- provider - State management
- dio - HTTP client
- sqflite - Local database
- flutter_secure_storage - Secure storage
- local_auth - Biometric authentication
- sensors_plus - Accelerometer
- pedometer - Step counter
- geolocator - GPS
- google_maps_flutter - Maps
- flutter_local_notifications - Notifications

### Go Dependencies
- gin - Web framework
- gorm - ORM
- jwt - Authentication
- bcrypt - Password hashing
- godotenv - Environment variables

## 🔐 Security

- Passwords di-hash menggunakan bcrypt
- JWT untuk session management
- Secure storage untuk token di device
- Biometric authentication support
- CORS middleware
- Input validation

## 📄 License

This project is private and not licensed for public use.

## 👥 Team

Developed by TPM Team - Semester 6

---

## 📊 Status Implementasi

**Progress**: 5/20 Tasks Complete (25%)

### ✅ Completed Tasks

- **Task 1**: Setup Proyek dan Infrastruktur
  - Inisialisasi proyek Flutter dengan clean architecture
  - Setup backend Golang dengan struktur modular
  - PostgreSQL dengan Docker + volume persistence
  - Database schema 7 tabel + GORM AutoMigrate
  - Testing framework: testify (Go) + flutter_test/mockito (Flutter)

- **Task 2**: Autentikasi dan Keamanan Backend
  - Auth Service: registrasi, login, JWT generation, bcrypt password hashing
  - JWT middleware untuk proteksi endpoint
  - User Profile API: CRUD, upload & kompresi foto profil, validasi data
  - Property test: password hashing consistency
  - Unit tests: validasi profil & upload foto

- **Task 3**: Food Database dan API
  - Model `Food` dengan nutrisi lengkap
  - Seeding data makanan MPASI dan makanan ibu
  - API pencarian makanan dengan filter kategori
  - Recipe API: CRUD, favorit, random recipe
  - Property test: nutrition calculation consistency

- **Task 4**: Food Diary API
  - Model `DiaryEntry` dengan dual profile (bayi & ibu)
  - CRUD endpoints diary entries dengan kalkulasi nutrition summary harian
  - Kategorisasi slot waktu: Makan Pagi, Siang, Malam, Selingan
  - Endpoint sinkronisasi data offline dengan timestamp & conflict resolution
  - Property test: nutrition tracking consistency

- **Task 5**: Setup State Management dan Arsitektur Flutter
  - Provider pattern dengan GetIt dependency injection
  - Base providers untuk state management dengan error handling & loading states
  - Secure storage (flutter_secure_storage) untuk JWT tokens
  - HTTP client (Dio) dengan interceptors untuk auth & automatic token refresh
  - Unit tests: secure storage functionality (27 tests) & HTTP client dengan mock responses (17 tests)
  - Total 44 tests passing

### 📋 Upcoming

- **Task 6**: Autentikasi Flutter
- **Task 7–9**: Fitur Utama (Food Diary UI, Diet Plan)
- **Task 10–11**: Sensor & Resep
- **Task 12–14**: Integrasi Eksternal (LBS, AI Chatbot, Quiz, Notifikasi)
- **Task 15–17**: UI/UX & Offline
- **Task 18–20**: Testing & Finalisasi

---

**Last Updated**: April 29, 2026
