# Rencana Implementasi: NutriBunda

## Gambaran Umum

Dokumen ini berisi rencana implementasi lengkap aplikasi NutriBunda - aplikasi mobile Flutter untuk memantau gizi MPASI dan diet pemulihan ibu pasca-melahirkan. Implementasi menggunakan arsitektur client-server dengan backend Golang, PostgreSQL sebagai database utama, dan SQLite untuk penyimpanan lokal dengan strategi offline-first.

## Struktur Implementasi

Implementasi dibagi menjadi 6 fase utama:
1. **Setup Proyek** - Inisialisasi struktur proyek dan konfigurasi dasar
2. **Backend Development** - API Golang dengan autentikasi JWT dan database PostgreSQL
3. **Frontend Core** - Aplikasi Flutter dengan state management dan UI dasar
4. **Fitur Utama** - Implementasi fitur inti seperti food diary, diet plan, dan sensor
5. **Integrasi Eksternal** - AI chatbot, maps, dan notifikasi
6. **Testing & Finalisasi** - Testing komprehensif dan optimisasi

---

## Tasks

### Fase 1: Setup Proyek dan Infrastruktur

- [x] 1. Setup struktur proyek dan konfigurasi dasar
  - [x] 1.1 Inisialisasi proyek Flutter dengan struktur clean architecture
    - Buat proyek Flutter baru dengan nama `nutribunda`
    - Setup struktur folder: `lib/core/`, `lib/data/`, `lib/domain/`, `lib/presentation/`
    - Konfigurasi `pubspec.yaml` dengan dependencies utama
    - _Requirements: 13.1, 13.2_

  - [x] 1.2 Setup proyek backend Golang
    - Inisialisasi proyek Go dengan struktur modular
    - Setup folder: `cmd/`, `internal/`, `pkg/`, `configs/`
    - Konfigurasi `go.mod` dengan dependencies (Gin, GORM, JWT, bcrypt)
    - _Requirements: 1.2, 1.3_

  - [x] 1.3 Setup PostgreSQL menggunakan Docker
    - Buat `docker-compose.yml` untuk PostgreSQL container
    - Konfigurasi environment variables untuk database connection
    - Setup volume untuk data persistence
    - Buat script untuk database initialization
    - _Requirements: 3.1, 4.1_

  - [x] 1.4 Konfigurasi database schema dan migrations
    - Setup schema database dengan 7 tabel utama
    - Buat migration files untuk semua tabel
    - Setup connection pool dan konfigurasi GORM
    - Test koneksi database dari aplikasi Golang
    - _Requirements: 3.1, 4.1_

  - [x] 1.5 Setup testing framework untuk backend dan frontend
    - Konfigurasi testing untuk Go (testify)
    - Konfigurasi testing untuk Flutter (flutter_test, mockito)
    - _Requirements: Semua_

### Fase 2: Backend Development

- [x] 2. Implementasi autentikasi dan keamanan backend
  - [x] 2.1 Implementasi Auth Service dengan JWT dan bcrypt
    - Buat handler registrasi dengan bcrypt password hashing
    - Buat handler login dengan JWT token generation
    - Implementasi middleware JWT untuk proteksi endpoint
    - _Requirements: 1.1, 1.2, 1.3, 1.6_

  - [x] 2.2 Write property test untuk Auth Service
    - **Property 1: Password hashing consistency**
    - **Validates: Requirements 1.2**

  - [x] 2.3 Implementasi User Profile API endpoints
    - Buat CRUD endpoints untuk user profile
    - Implementasi upload dan kompresi foto profil
    - Validasi data profil (berat badan 30-200kg, tinggi 100-250cm)
    - _Requirements: 12.1, 12.2, 12.3, 12.4_

  - [x] 2.4 Write unit tests untuk User Profile endpoints
    - Test validasi data profil
    - Test upload foto profil
    - _Requirements: 12.4, 12.5_

- [x] 3. Implementasi Food Database dan API
  - [x] 3.1 Setup Food Database dengan data makanan MPASI
    - Buat model Food dengan nutrisi lengkap
    - Implementasi seeding data makanan MPASI dan ibu
    - Buat API endpoints untuk pencarian makanan
    - _Requirements: 3.1, 3.2_

  - [x] 3.2 Implementasi Recipe API dan favorit
    - Buat model Recipe dengan ingredients dan instructions
    - Implementasi endpoints untuk resep favorit
    - Buat endpoint random recipe untuk shake-to-recipe
    - _Requirements: 6.3, 7.1, 7.2, 7.3_

  - [x] 3.3 Write property test untuk Food Database
    - **Property 2: Nutrition calculation consistency**
    - **Validates: Requirements 3.1, 4.3**

- [x] 4. Implementasi Food Diary API
  - [x] 4.1 Buat Food Diary endpoints dengan dual profile
    - Implementasi model DiaryEntry untuk bayi dan ibu
    - Buat endpoints untuk CRUD diary entries
    - Implementasi kalkulasi nutrition summary harian
    - _Requirements: 4.1, 4.2, 4.3, 4.5_

  - [x] 4.2 Implementasi sinkronisasi data offline
    - Buat endpoints untuk sync data dengan timestamp
    - Implementasi conflict resolution untuk data sync
    - _Requirements: 3.4, 3.5, 7.4_

  - [x] 4.3 Write property test untuk Nutrition Tracking
    - **Property 3: Nutrition tracking consistency**
    - **Validates: Requirements 4.3, 4.5**

### Fase 3: Frontend Core Development

- [x] 5. Setup state management dan arsitektur Flutter
  - [x] 5.1 Implementasi Provider pattern dan dependency injection
    - Setup GetIt untuk dependency injection
    - Buat base providers untuk state management
    - Implementasi error handling dan loading states
    - _Requirements: 13.1, 13.2_

  - [x] 5.2 Implementasi secure storage dan HTTP client
    - Setup flutter_secure_storage untuk JWT
    - Konfigurasi Dio dengan interceptors untuk auth
    - Implementasi automatic token refresh
    - _Requirements: 1.4, 1.6_

  - [x] 5.3 Write unit tests untuk core services
    - Test secure storage functionality
    - Test HTTP client dengan mock responses
    - _Requirements: 1.4, 1.7_

- [x] 6. Implementasi autentikasi Flutter
  - [x] 6.1 Buat AuthProvider dan login/register screens
    - Implementasi AuthProvider dengan login/register methods
    - Buat UI untuk login dan registrasi
    - Implementasi form validation dan error handling
    - _Requirements: 1.1, 1.5, 1.7_

  - [x] 6.2 Implementasi biometric authentication
    - Setup local_auth untuk sidik jari dan Face ID
    - Implementasi BiometricService dengan fallback
    - Buat UI untuk enable/disable biometric auth
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [x] 6.3 Write integration tests untuk authentication flow
    - Test complete login/logout flow
    - Test biometric authentication scenarios
    - _Requirements: 1.1-1.7, 2.1-2.5_

### Fase 4: Implementasi Fitur Utama

- [x] 7. Implementasi Food Diary dan Nutrition Tracking
  - [x] 7.1 Buat FoodDiaryProvider dan UI screens
    - Implementasi FoodDiaryProvider dengan dual profile support
    - Buat UI untuk pencatatan makanan bayi dan ibu
    - Implementasi food search dengan autocomplete
    - _Requirements: 4.1, 4.2, 4.4_

  - [x] 7.2 Implementasi nutrition summary dan visualisasi
    - Buat NutritionTracker untuk kalkulasi harian
    - Implementasi progress bars dan charts untuk nutrisi
    - Buat dashboard dengan ringkasan nutrisi
    - _Requirements: 4.3, 4.6, 13.2_

  - [x] 7.3 Write property test untuk nutrition calculations
    - **Property 4: Add/remove entry consistency**
    - **Validates: Requirements 4.3, 4.5**

- [ ] 8. Implementasi Diet Plan dengan BMR/TDEE
  - [ ] 8.1 Buat DietPlanProvider dengan kalkulasi BMR/TDEE
    - Implementasi kalkulasi BMR menggunakan Mifflin-St Jeor formula
    - Implementasi kalkulasi TDEE dengan activity factors
    - Buat logic untuk target kalori dengan defisit aman
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [ ] 8.2 Implementasi UI Diet Plan dengan progress tracking
    - Buat UI untuk input data fisik pengguna
    - Implementasi progress bar kalori dengan color coding
    - Buat dashboard diet plan dengan ringkasan harian
    - _Requirements: 5.8, 5.9, 5.10, 5.11_

  - [ ] 8.3 Write property test untuk BMR/TDEE calculations
    - **Property 5: BMR calculation accuracy**
    - **Property 6: Calorie deficit safety**
    - **Validates: Requirements 5.1, 5.2, 5.3**

- [ ] 9. Checkpoint - Validasi fitur inti
  - Pastikan semua test pass, tanyakan user jika ada pertanyaan.

### Fase 5: Implementasi Sensor dan Fitur Interaktif

- [ ] 10. Implementasi sensor integration
  - [ ] 10.1 Implementasi Pedometer Service untuk step counting
    - Setup pedometer plugin untuk menghitung langkah
    - Implementasi kalkulasi kalori terbakar dari langkah
    - Integrasi dengan DietPlanProvider untuk update real-time
    - _Requirements: 5.6, 5.7_

  - [ ] 10.2 Implementasi Accelerometer Service untuk shake detection
    - Setup sensors_plus untuk accelerometer data
    - Implementasi shake detection dengan threshold dan debounce
    - Integrasi dengan random recipe selection
    - _Requirements: 6.1, 6.2, 6.3, 6.6_

  - [ ] 10.3 Write property test untuk sensor services
    - **Property 7: Shake detection debounce**
    - **Validates: Requirements 6.6**

- [ ] 11. Implementasi Recipe dan Favorit
  - [ ] 11.1 Buat RecipeProvider dan recipe screens
    - Implementasi RecipeProvider untuk manage resep
    - Buat UI untuk display resep dengan detail lengkap
    - Implementasi shake-to-recipe dengan animasi
    - _Requirements: 6.3, 6.4, 6.5_

  - [ ] 11.2 Implementasi sistem favorit resep
    - Buat FavoriteProvider untuk manage resep favorit
    - Implementasi UI untuk save/remove favorit
    - Buat screen untuk daftar resep favorit
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [ ] 11.3 Write unit tests untuk recipe management
    - Test recipe favorit functionality
    - Test shake-to-recipe integration
    - _Requirements: 6.3-6.6, 7.1-7.4_

### Fase 6: Integrasi Eksternal dan Fitur Lanjutan

- [ ] 12. Implementasi Location-Based Service (LBS)
  - [ ] 12.1 Setup location services dan deep link launcher
    - Setup geolocator untuk mendapatkan GPS coordinates
    - Setup url_launcher untuk membuka deep link
    - Implementasi permission handling untuk location access
    - Konfigurasi AndroidManifest.xml dan Info.plist untuk location permissions
    - _Requirements: 8.1, 8.2, 8.7_

  - [ ] 12.2 Implementasi deep link launcher untuk Google Maps eksternal
    - Buat LocationService untuk mendapatkan GPS coordinates pengguna
    - Buat MapsLauncherService untuk membuat deep link URL Google Maps
    - Buat LBSProvider untuk state management lokasi dan error handling
    - Implementasi UI dengan 4 kategori fasilitas (Rumah Sakit, Puskesmas, Posyandu, Apotek) dalam grid cards
    - Implementasi logic untuk membuka Google Maps app atau fallback ke browser
    - _Requirements: 8.3, 8.4, 8.5, 8.6_

  - [ ] 12.3 Write integration tests untuk LBS functionality
    - Test location permission handling dan error scenarios
    - Test deep link URL formatting untuk berbagai kategori
    - Test fallback behavior (Maps app vs browser)
    - _Requirements: 8.1-8.7_

- [ ] 13. Implementasi AI Chatbot (TanyaBunda)
  - [ ] 13.1 Setup Gemini API integration
    - Konfigurasi Gemini API dengan system prompt
    - Implementasi ChatService untuk manage conversations
    - Buat error handling untuk API failures
    - _Requirements: 9.1, 9.2, 9.4_

  - [ ] 13.2 Buat UI chatbot dengan conversation history
    - Implementasi ChatProvider untuk state management
    - Buat UI chat dengan message bubbles
    - Implementasi typing indicators dan loading states
    - _Requirements: 9.3, 9.5, 9.6_

  - [ ] 13.3 Write unit tests untuk chatbot functionality
    - Test Gemini API integration
    - Test conversation history management
    - _Requirements: 9.1-9.6_

- [ ] 14. Implementasi Quiz Game dan Notifikasi
  - [ ] 14.1 Buat Quiz Game dengan scoring system
    - Implementasi QuizProvider dengan question randomization
    - Buat UI quiz dengan multiple choice
    - Implementasi local scoring dan high score tracking
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7_

  - [ ] 14.2 Implementasi notification system
    - Setup flutter_local_notifications dengan timezone support
    - Implementasi NotificationService untuk MPASI dan vitamin reminders
    - Buat UI untuk manage notification settings
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6_

  - [ ] 14.3 Write unit tests untuk quiz dan notifications
    - Test quiz scoring dan randomization
    - Test notification scheduling dengan timezone
    - _Requirements: 10.1-10.7, 11.1-11.6_

### Fase 7: UI/UX dan Navigation

- [ ] 15. Implementasi navigation dan UI polish
  - [ ] 15.1 Setup bottom navigation dan routing
    - Implementasi bottom navigation bar dengan 4 tabs
    - Setup navigation routing dengan named routes
    - Buat splash screen dan onboarding flow
    - _Requirements: 13.1, 13.3, 13.4, 13.5, 13.6_

  - [ ] 15.2 Implementasi profile management UI
    - Buat ProfileProvider untuk manage user data
    - Implementasi UI untuk edit profile dengan photo upload
    - Buat settings screen dengan logout functionality
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 13.5_

  - [ ] 15.3 Write UI tests untuk navigation flow
    - Test bottom navigation functionality
    - Test profile management screens
    - _Requirements: 12.1-12.5, 13.1-13.6_

### Fase 8: Offline Support dan Sinkronisasi

- [ ] 16. Implementasi offline-first architecture
  - [ ] 16.1 Setup SQLite local database
    - Buat SQLite schema yang mirror PostgreSQL
    - Implementasi local database service dengan sqflite
    - Setup data models untuk local storage
    - _Requirements: 3.3, 3.4, 7.4_

  - [ ] 16.2 Implementasi data synchronization
    - Buat SyncService untuk bidirectional sync
    - Implementasi conflict resolution strategies
    - Buat background sync dengan connectivity monitoring
    - _Requirements: 3.5, 4.1, 7.4_

  - [ ] 16.3 Write property test untuk data synchronization
    - **Property 8: Sync consistency**
    - **Validates: Requirements 3.4, 3.5**

- [ ] 17. Checkpoint - Integrasi dan testing menyeluruh
  - Pastikan semua fitur terintegrasi dengan baik, jalankan full test suite, tanyakan user jika ada pertanyaan.

### Fase 9: Testing dan Optimisasi

- [ ] 18. Testing komprehensif dan bug fixes
  - [ ] 18.1 Integration testing untuk end-to-end flows
    - Test complete user journey dari registrasi hingga penggunaan fitur
    - Test offline-online transition scenarios
    - Test error handling dan edge cases
    - _Requirements: Semua_

  - [ ] 18.2 Performance optimization dan memory management
    - Optimisasi image loading dan caching
    - Implementasi lazy loading untuk large datasets
    - Memory leak detection dan fixes
    - _Requirements: 3.2, 12.3_

  - [ ] 18.3 Write property-based tests untuk critical paths
    - **Property 9: Data integrity across offline/online states**
    - **Property 10: Memory usage bounds**
    - **Validates: Requirements 3.3-3.5, 4.1-4.6**

- [ ] 19. Final polish dan deployment preparation
  - [ ] 19.1 UI/UX refinement dan accessibility
    - Implementasi accessibility labels dan semantic widgets
    - UI polish dengan consistent theming
    - Performance monitoring dan analytics setup
    - _Requirements: Semua_

  - [ ] 19.2 Security audit dan production readiness
    - Security review untuk JWT handling dan data storage
    - API rate limiting dan input validation
    - Production configuration dan environment setup
    - _Requirements: 1.1-1.7, 2.1-2.5_

  - [ ] 19.3 Write security tests dan penetration testing
    - Test authentication security
    - Test data encryption dan secure storage
    - _Requirements: 1.1-1.7, 2.1-2.5_

- [ ] 20. Final checkpoint - Production readiness
  - Pastikan semua test pass, aplikasi siap untuk deployment, dokumentasi lengkap tersedia.

---

## Catatan Implementasi

### Docker Setup untuk PostgreSQL
Untuk memudahkan development, PostgreSQL akan dijalankan menggunakan Docker dengan konfigurasi:

```yaml
# docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:14
    environment:
      POSTGRES_DB: nutribunda
      POSTGRES_USER: nutribunda_user
      POSTGRES_PASSWORD: nutribunda_pass
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init:/docker-entrypoint-initdb.d
volumes:
  postgres_data:
```

**Commands untuk development:**
- `docker-compose up -d` - Start PostgreSQL container
- `docker-compose down` - Stop container  
- `docker-compose logs postgres` - View logs
- `docker-compose exec postgres psql -U nutribunda_user -d nutribunda` - Connect to database

**Environment variables untuk Golang:**
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=nutribunda_user
DB_PASSWORD=nutribunda_pass
DB_NAME=nutribunda
DB_SSLMODE=disable
```

### Prioritas Fitur
- **Core Features** (Fase 1-4): Autentikasi, Food Diary, Diet Plan - wajib untuk MVP
- **Interactive Features** (Fase 5): Sensor integration, Recipe management - penting untuk user engagement  
- **Advanced Features** (Fase 6): AI Chatbot, LBS, Quiz - nice-to-have untuk versi lengkap
- **Polish** (Fase 7-9): UI/UX, Offline support, Testing - penting untuk production

### Dependencies dan Urutan
- Backend API harus selesai sebelum frontend integration
- Authentication system harus stabil sebelum fitur lain
- Database schema harus final sebelum implementasi sync
- Core UI components harus ada sebelum advanced features

### Testing Strategy
- Tasks dengan `*` adalah optional dan bisa dilewati untuk MVP cepat
- Property tests memvalidasi correctness properties dari design document
- Unit tests fokus pada business logic dan edge cases
- Integration tests memastikan end-to-end functionality

### Technology Stack Confirmation
- **Frontend**: Flutter 3.x dengan Provider pattern untuk state management
- **Backend**: Golang dengan Gin framework dan GORM untuk database ORM
- **Database**: PostgreSQL untuk server, SQLite untuk local storage
- **Authentication**: JWT dengan bcrypt password hashing
- **External APIs**: Gemini API (chatbot), Google Maps API (LBS)

Setiap task mereferensikan requirements spesifik untuk traceability dan memastikan semua acceptance criteria terpenuhi dalam implementasi.