# NutriBunda Backend Setup

Backend API untuk aplikasi NutriBunda menggunakan Golang, Gin framework, dan PostgreSQL.

## Prerequisites

- Go 1.26+
- PostgreSQL running (see [Database Setup](./database-setup.md))
- Git

## Tech Stack

- **Language**: Go 1.26+
- **Framework**: Gin
- **Database**: PostgreSQL 14+
- **ORM**: GORM
- **Authentication**: JWT dengan bcrypt

## Project Structure

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

## Setup Steps

### 1. Navigate to Backend Directory

```bash
cd backend
```

### 2. Install Dependencies

```bash
go mod download
```

### 3. Configure Environment

Copy `.env.example` ke `.env` dan sesuaikan konfigurasi:

```bash
cp .env.example .env
```

Edit `.env` file sesuai kebutuhan (database credentials, JWT secret, dll).

### 4. Verify Database Connection

Test koneksi database dan jalankan migrations:

```bash
go run cmd/test-db/main.go
```

Expected output:
```
✅ Database connection successful!
✅ Migrations completed successfully
```

### 5. Run Backend Server

```bash
go run cmd/api/main.go
```

Server akan berjalan di `http://localhost:8080`

Expected output:
```
[GIN-debug] Listening and serving HTTP on :8080
```

## Development Workflow

### Run with Hot Reload

Install Air untuk hot reload:

```bash
go install github.com/air-verse/air@latest
```

Run dengan Air:

```bash
air
```

### Run Tests

```bash
# Run all tests
go test ./...

# Run with verbose output
go test -v ./...

# Run with coverage
go test -cover ./...

# Run specific package
go test ./internal/auth
```

### Build for Production

```bash
go build -o nutribunda-api cmd/api/main.go
```

Run production build:

```bash
./nutribunda-api
```

## API Endpoints

### Health Check
- `GET /api/health` - Check API status

### Authentication ✅
- `POST /api/auth/register` - Register user baru
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user

### User Profile ✅
- `GET /api/profile` - Get user profile
- `PUT /api/profile` - Update user profile
- `POST /api/profile/upload-image` - Upload foto profil
- `DELETE /api/profile/image` - Delete foto profil

### Food Database ✅
- `GET /api/foods` - Get list makanan
- `GET /api/foods/:id` - Get detail makanan
- `GET /api/foods/sync` - Sync data makanan

### Food Diary ✅
- `GET /api/diary` - Get diary entries
- `POST /api/diary` - Add diary entry
- `DELETE /api/diary/:id` - Delete diary entry
- `POST /api/diary/sync` - Sync diary data

### Recipes ✅
- `GET /api/recipes` - Get list resep
- `GET /api/recipes/random` - Get random resep
- `GET /api/recipes/favorites` - Get resep favorit
- `POST /api/recipes/:id/favorite` - Add to favorites
- `DELETE /api/recipes/:id/favorite` - Remove from favorites

### Quiz (Coming Soon)
- `GET /api/quiz/questions` - Get quiz questions
- `POST /api/quiz/submit` - Submit quiz answers

## Testing the API

### Using curl

```bash
# Health check
curl http://localhost:8080/api/health

# Register
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","full_name":"Test User"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

For complete API testing guide, see [API Testing Guide](../backend/api-testing-guide.md).

## Seeding Data

Untuk seed data awal (makanan MPASI, resep, quiz questions):

```bash
go run cmd/seed/main.go
```

## Module Status

| Module | Status | Documentation |
|--------|--------|---------------|
| Auth | ✅ Done | [Auth Module](../backend/modules/auth.md) |
| User Profile | ✅ Done | [User Module](../backend/modules/user.md) |
| Food Database | ✅ Done | - |
| Food Diary | ✅ Done | [Diary Module](../backend/modules/diary/) |
| Recipe | ✅ Done | [Recipe Module](../backend/modules/recipe/) |
| Quiz | 🔜 Upcoming | - |
| Notifications | 🔜 Upcoming | - |

## Troubleshooting

### "Failed to connect to database"
- Ensure PostgreSQL is running: `docker-compose ps`
- Check database credentials in `.env` file
- Verify connection string format

### "Port 8080 already in use"
- Change port in `.env` file: `PORT=8081`
- Or stop the process using port 8080

### "go: module not found"
- Run `go mod download`
- Run `go mod tidy` to clean up dependencies

### "Permission denied" on uploads directory
- Create uploads directory: `mkdir uploads`
- Set permissions: `chmod 755 uploads`

## Environment Variables

Key environment variables in `.env`:

```env
# Server
PORT=8080

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=nutribunda_user
DB_PASSWORD=nutribunda_pass
DB_NAME=nutribunda

# JWT
JWT_SECRET=your-secret-key-here
JWT_EXPIRY=24h

# File Upload
MAX_UPLOAD_SIZE=10485760  # 10MB
UPLOAD_DIR=./uploads
```

## Next Steps

- [Flutter Setup](./flutter-setup.md) - Setup mobile app
- [API Testing Guide](../backend/api-testing-guide.md) - Test API endpoints
- [Backend Testing Guide](../backend/testing-guide.md) - Run backend tests

---

**Last Updated**: April 29, 2026
