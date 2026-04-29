# Backend Documentation

Dokumentasi lengkap untuk NutriBunda Backend API (Golang).

## 📚 Contents

### Getting Started
- [API Testing Guide](./api-testing-guide.md) - Panduan testing API endpoints dengan curl/Postman
- [Testing Guide](./testing-guide.md) - Panduan testing backend dengan testify

### Modules

#### Authentication
- [Auth Module](./modules/auth.md) - JWT authentication, bcrypt, middleware

#### User Management
- [User Module](./modules/user.md) - User profile, foto upload, validasi

#### Diary Service
- [Diary README](./modules/diary/README.md) - Food diary overview
- [Sync API](./modules/diary/sync-api.md) - Offline sync endpoints
- [Sync Implementation](./modules/diary/sync-implementation.md) - Sync implementation details
- [Property Testing](./modules/diary/property-testing.md) - Property-based testing guide
- [Property Test Summary](./modules/diary/property-test-summary.md) - Test results

#### Recipe Service
- [Recipe README](./modules/recipe/README.md) - Recipe management overview
- [Recipe Testing](./modules/recipe/testing.md) - Recipe testing guide

## 🚀 Quick Links

### API Endpoints
- Health Check: `GET /api/health`
- Authentication: `POST /api/auth/register`, `POST /api/auth/login`
- User Profile: `GET /api/profile`, `PUT /api/profile`
- Food Database: `GET /api/foods`, `GET /api/foods/:id`
- Food Diary: `GET /api/diary`, `POST /api/diary`
- Recipes: `GET /api/recipes`, `GET /api/recipes/random`

### Testing
```bash
# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Run specific module
go test ./internal/auth
```

### Development
```bash
# Run with hot reload
air

# Build for production
go build -o nutribunda-api cmd/api/main.go
```

## 📊 Module Status

| Module | Status | Documentation |
|--------|--------|---------------|
| Auth | ✅ Done | [Auth Module](./modules/auth.md) |
| User Profile | ✅ Done | [User Module](./modules/user.md) |
| Food Database | ✅ Done | - |
| Food Diary | ✅ Done | [Diary Module](./modules/diary/) |
| Recipe | ✅ Done | [Recipe Module](./modules/recipe/) |
| Quiz | 🔜 Upcoming | - |
| Notifications | 🔜 Upcoming | - |

## 🔧 Tech Stack

- **Language**: Go 1.26+
- **Framework**: Gin
- **Database**: PostgreSQL 14+ with GORM
- **Authentication**: JWT + bcrypt
- **Testing**: testify

## 📝 Related Documentation

- [Database Setup](../getting-started/database-setup.md)
- [Backend Setup](../getting-started/backend-setup.md)
- [Project Overview](../getting-started/project-overview.md)

---

**Last Updated**: April 29, 2026
