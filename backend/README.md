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

### Authentication (Coming Soon)
- `POST /api/auth/register` - Register user baru
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user

### User Profile (Coming Soon)
- `GET /api/profile` - Get user profile
- `PUT /api/profile` - Update user profile
- `POST /api/profile/upload-image` - Upload profile image

### Food Database (Coming Soon)
- `GET /api/foods` - Get list makanan
- `GET /api/foods/:id` - Get detail makanan
- `GET /api/foods/sync` - Sync data makanan

### Food Diary (Coming Soon)
- `GET /api/diary` - Get diary entries
- `POST /api/diary` - Add diary entry
- `DELETE /api/diary/:id` - Delete diary entry

### Recipes (Coming Soon)
- `GET /api/recipes` - Get list resep
- `GET /api/recipes/random` - Get random resep
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
