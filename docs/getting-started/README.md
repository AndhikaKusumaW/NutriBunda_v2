# Getting Started with NutriBunda

Panduan lengkap untuk memulai development NutriBunda.

## 📚 Setup Guides

1. [Project Overview](./project-overview.md) - Overview proyek dan arsitektur
2. [Database Setup](./database-setup.md) - Setup PostgreSQL dengan Docker
3. [Backend Setup](./backend-setup.md) - Setup Golang backend API
4. [Flutter Setup](./flutter-setup.md) - Setup Flutter mobile app

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.x
- Go 1.26+
- Docker Desktop
- Git

### Setup in 5 Minutes

```bash
# 1. Clone repository
git clone <repository-url>
cd NutriBunda

# 2. Start database
docker-compose up -d

# 3. Setup backend
cd backend
cp .env.example .env
go mod download
go run cmd/api/main.go

# 4. Setup Flutter (in new terminal)
cd nutribunda
flutter pub get
flutter run
```

## 📖 Detailed Setup

### Step 1: Database Setup

Start PostgreSQL container:

```bash
docker-compose up -d
```

Verify database is running:

```bash
docker-compose ps
```

See: [Database Setup Guide](./database-setup.md)

### Step 2: Backend Setup

Navigate to backend directory:

```bash
cd backend
```

Install dependencies:

```bash
go mod download
```

Configure environment:

```bash
cp .env.example .env
# Edit .env file with your configuration
```

Run backend server:

```bash
go run cmd/api/main.go
```

Backend will run on `http://localhost:8080`

See: [Backend Setup Guide](./backend-setup.md)

### Step 3: Flutter Setup

Navigate to Flutter directory:

```bash
cd nutribunda
```

Install dependencies:

```bash
flutter pub get
```

Create `.env` file:

```env
API_BASE_URL=http://localhost:8080/api
GEMINI_API_KEY=your-gemini-api-key
```

Run the app:

```bash
flutter run
```

See: [Flutter Setup Guide](./flutter-setup.md)

## 🔧 Development Workflow

### Backend Development

```bash
# Run with hot reload
air

# Run tests
go test ./...

# Build for production
go build -o nutribunda-api cmd/api/main.go
```

### Flutter Development

```bash
# Run app
flutter run

# Hot reload: press 'r'
# Hot restart: press 'R'

# Run tests
flutter test

# Build APK
flutter build apk --release
```

## 📊 Project Structure

```
NutriBunda/
├── backend/                # Golang backend API
│   ├── cmd/               # Entry points
│   ├── internal/          # Internal packages
│   ├── pkg/               # Public packages
│   └── configs/           # Configuration
│
├── nutribunda/            # Flutter mobile app
│   ├── lib/
│   │   ├── core/         # Core utilities
│   │   ├── data/         # Data layer
│   │   ├── domain/       # Domain layer
│   │   └── presentation/ # UI layer
│   └── test/             # Tests
│
├── database/              # Database setup
│   └── init/             # Init scripts
│
├── docs/                  # Documentation
│   ├── getting-started/  # Setup guides
│   ├── backend/          # Backend docs
│   ├── frontend/         # Frontend docs
│   ├── implementation/   # Implementation guides
│   ├── tasks/            # Task summaries
│   └── testing/          # Testing docs
│
└── docker-compose.yml     # PostgreSQL container
```

## 🧪 Testing

### Backend Tests

```bash
cd backend
go test ./...
```

### Flutter Tests

```bash
cd nutribunda
flutter test
```

See: [Testing Documentation](../testing/)

## 🔍 Troubleshooting

### Database Connection Failed
- Ensure Docker is running
- Check `docker-compose ps`
- Verify credentials in `.env`

### Backend Port Already in Use
- Change port in `.env`: `PORT=8081`
- Or stop process using port 8080

### Flutter Build Failed
```bash
flutter clean
flutter pub get
flutter run
```

### API Connection Failed (Flutter)
- Ensure backend is running
- Check API_BASE_URL in `.env`
- For Android emulator, use `http://10.0.2.2:8080`

## 📝 Next Steps

After setup is complete:

1. Read [Project Overview](./project-overview.md) to understand the architecture
2. Explore [Backend Documentation](../backend/) for API details
3. Check [Frontend Documentation](../frontend/) for Flutter app structure
4. Review [Implementation Guides](../implementation/) for specific features
5. See [Task Summaries](../tasks/) for implementation details

## 🔗 Quick Links

- [API Testing Guide](../backend/api-testing-guide.md)
- [Backend Testing Guide](../backend/testing-guide.md)
- [Frontend Testing Guide](../frontend/testing-guide.md)
- [Gemini API Setup](../implementation/gemini-api-setup.md)

## 📞 Support

For issues or questions:
- Check [Troubleshooting](#-troubleshooting) section
- Review relevant documentation
- Contact team members

---

**Last Updated**: April 29, 2026
