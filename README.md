# NutriBunda

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

### 1. Setup Database

```bash
# Start PostgreSQL container
docker-compose up -d

# Verify container is running
docker-compose ps

# Check logs
docker-compose logs postgres
```

### 2. Setup Backend

```bash
cd backend

# Install dependencies
go mod download

# Copy environment file
cp .env.example .env

# Test database connection and run migrations
go run cmd/test-db/main.go

# Run backend server
go run cmd/api/main.go
```

Backend akan berjalan di `http://localhost:8080`

### 3. Setup Flutter App

```bash
cd nutribunda

# Install dependencies
flutter pub get

# Run app (pilih device/emulator)
flutter run
```

## 🗄️ Database

<!-- ### Connection Details

- **Host**: localhost
- **Port**: 5432
- **Database**: nutribunda
- **User**: nutribunda_user
- **Password**: nutribunda_pass -->

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

### Seeding Data

Untuk seed data awal (makanan, resep, quiz):

```bash
cd backend
# TODO: Implement seed command
```

## 🔧 Development

### Backend Development

```bash
cd backend

# Run with hot reload (install air first)
go install github.com/air-verse/air@latest
air

# Run tests
go test ./...

# Build for production
go build -o nutribunda-api cmd/api/main.go
```

### Flutter Development

```bash
cd nutribunda

# Run with hot reload
flutter run

# Run tests
flutter test

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

### Database Management

```bash
# Connect to database
docker-compose exec postgres psql -U nutribunda_user -d nutribunda

# Stop database
docker-compose down

# Reset database (WARNING: deletes all data)
docker-compose down -v
docker-compose up -d
```

## 📝 API Documentation

### Health Check
```
GET /api/health
```

### Authentication (Coming Soon)
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
```

### User Profile (Coming Soon)
```
GET /api/profile
PUT /api/profile
POST /api/profile/upload-image
```

### Food Database (Coming Soon)
```
GET /api/foods
GET /api/foods/:id
GET /api/foods/sync
```

### Food Diary (Coming Soon)
```
GET /api/diary
POST /api/diary
DELETE /api/diary/:id
```

### Recipes (Coming Soon)
```
GET /api/recipes
GET /api/recipes/random
GET /api/recipes/favorites
POST /api/recipes/:id/favorite
DELETE /api/recipes/:id/favorite
```

### Quiz (Coming Soon)
```
GET /api/quiz/questions
POST /api/quiz/submit
```

## 🧪 Testing

### Backend Tests
```bash
cd backend
go test ./... -v
```

### Flutter Tests
```bash
cd nutribunda
flutter test
```

### Integration Tests
```bash
cd nutribunda
flutter test integration_test/
```

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

**Progress**: 3/20 Tasks Complete (15%)

### ✅ Completed Tasks

- **Task 1**: Setup Proyek dan Infrastruktur
  - Struktur proyek Flutter dan Golang
  - PostgreSQL dengan Docker
  - Database schema dan migrations
  - Testing framework

- **Task 2**: Autentikasi dan Keamanan Backend
  - Auth Service dengan JWT dan bcrypt
  - Property tests untuk Auth Service
  - User Profile API endpoints
  - Unit tests untuk User Profile

- **Task 3**: Food Database dan API
  - Food Database dengan data MPASI
  - Recipe API dan favorit
  - Property tests untuk Food Database

### 🚧 In Progress

- **Task 4**: Food Diary API (Next)

### 📋 Upcoming

- Task 5-20: Frontend Core, Fitur Utama, Integrasi Eksternal, Testing & Finalisasi

---

**Last Updated**: April 27, 2026
