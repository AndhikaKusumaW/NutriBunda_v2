# NutriBunda Backend

Backend API untuk aplikasi NutriBunda - Aplikasi pemantau gizi MPASI dan diet pemulihan ibu pasca-melahirkan.

## Tech Stack

- **Language**: Go 1.26+
- **Framework**: Gin
- **Database**: PostgreSQL 14+
- **ORM**: GORM
- **Authentication**: JWT dengan bcrypt

## Struktur Proyek

```
backend/
├── cmd/
│   └── api/
│       └── main.go          # Entry point aplikasi
├── internal/
│   ├── auth/                # Authentication logic
│   ├── user/                # User management
│   ├── food/                # Food database
│   ├── diary/               # Food diary
│   ├── recipe/              # Recipe management
│   ├── quiz/                # Quiz game
│   ├── database/            # Database initialization
│   └── middleware/          # HTTP middlewares
├── pkg/
│   ├── utils/               # Utility functions
│   └── validator/           # Input validation
├── configs/
│   └── config.go            # Configuration management
├── go.mod
├── go.sum
└── .env.example
```

## Setup

1. Copy `.env.example` ke `.env` dan sesuaikan konfigurasi:
   ```bash
   cp .env.example .env
   ```

2. Install dependencies:
   ```bash
   go mod download
   ```

3. Pastikan PostgreSQL sudah berjalan (lihat docker-compose.yml di root project)

4. Run aplikasi:
   ```bash
   go run cmd/api/main.go
   ```

## API Endpoints

### Health Check
- `GET /api/health` - Check API status

### Authentication ✅
- `POST /api/auth/register` - Register user baru (bcrypt + JWT)
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user

### User Profile ✅
- `GET /api/profile` - Get user profile
- `PUT /api/profile` - Update user profile (validasi berat 30–200kg, tinggi 100–250cm)
- `POST /api/profile/upload-image` - Upload & kompresi foto profil (maks 500KB)

### Food Database ✅
- `GET /api/foods` - Get list makanan (filter by kategori, search by nama)
- `GET /api/foods/:id` - Get detail makanan
- `GET /api/foods/sync` - Sync data makanan dengan timestamp

### Food Diary ✅
- `GET /api/diary` - Get diary entries (filter by profil bayi/ibu & tanggal)
- `POST /api/diary` - Add diary entry
- `DELETE /api/diary/:id` - Delete diary entry
- `POST /api/diary/sync` - Sync diary data offline

### Recipes ✅
- `GET /api/recipes` - Get list resep
- `GET /api/recipes/random` - Get random resep (untuk shake-to-recipe)
- `GET /api/recipes/favorites` - Get resep favorit
- `POST /api/recipes/:id/favorite` - Add resep ke favorit
- `DELETE /api/recipes/:id/favorite` - Remove resep dari favorit

### Quiz (Coming Soon)
- `GET /api/quiz/questions` - Get quiz questions
- `POST /api/quiz/submit` - Submit quiz answers

## Development

### Run dengan hot reload (menggunakan air):
```bash
go install github.com/air-verse/air@latest
air
```

### Run tests:
```bash
go test ./...
```

### Build untuk production:
```bash
go build -o nutribunda-api cmd/api/main.go
```

## Environment Variables

Lihat `.env.example` untuk daftar lengkap environment variables yang diperlukan.

## Status Backend

| Module | Status | Keterangan |
|--------|--------|------------|
| Auth | ✅ Done | JWT, bcrypt, middleware |
| User Profile | ✅ Done | CRUD, foto upload, validasi |
| Food Database | ✅ Done | Search, kategori, sync |
| Food Diary | ✅ Done | Dual profile, nutrition summary, offline sync |
| Recipe | ✅ Done | CRUD, favorit, random |
| Quiz | 🔜 Upcoming | - |
| Notifications | 🔜 Upcoming | - |

## Seeding Data

Untuk seed data awal (makanan MPASI, resep, quiz questions):

```bash
go run cmd/seed/main.go
```

