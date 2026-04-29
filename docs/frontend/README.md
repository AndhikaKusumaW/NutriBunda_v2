# Frontend Documentation

Dokumentasi lengkap untuk NutriBunda Flutter Mobile App.

## 📚 Contents

### Getting Started
- [Testing Guide](./testing-guide.md) - Panduan testing Flutter app
- [Accessibility Guide](./accessibility-guide.md) - Panduan aksesibilitas UI/UX
- [Performance Monitoring](./performance-monitoring.md) - Monitoring performa aplikasi

### Features

#### Core Features
- [Authentication](./features/auth.md) - Login, register, biometric auth
- [Diary Integration](./features/diary-integration.md) - Food diary dengan offline support
- [Location-Based Services](./features/lbs.md) - Pencarian fasilitas kesehatan
- [Chat Service](./features/chat-service.md) - AI chatbot dengan Gemini API
- [Sync Service](./features/sync-service.md) - Data synchronization

### Architecture

#### Application Architecture
- [Services](./architecture/services.md) - Core services (HTTP, storage, chat, sync)
- [Data Sources](./architecture/datasources.md) - Local & remote data sources
- [Providers](./architecture/providers/) - State management dengan Provider pattern

## 🏗️ Architecture Overview

```
lib/
├── core/               # Core utilities & services
│   ├── constants/      # App constants
│   ├── services/       # HTTP, storage, chat, sync
│   └── utils/          # Utility functions
├── data/               # Data layer
│   ├── datasources/    # Local & remote data sources
│   ├── models/         # Data models
│   └── repositories/   # Repository implementations
├── domain/             # Domain layer
│   ├── entities/       # Business entities
│   └── repositories/   # Repository interfaces
├── presentation/       # Presentation layer
│   ├── pages/          # UI screens
│   ├── providers/      # State management
│   ├── themes/         # App themes
│   └── widgets/        # Reusable widgets
└── main.dart           # Entry point
```

## 🚀 Quick Links

### Key Features
- **Authentication**: JWT + Biometric (Face ID/Fingerprint)
- **Food Diary**: Offline-first dengan SQLite
- **Diet Plan**: BMR/TDEE calculation + Pedometer
- **AI Chatbot**: Gemini API integration
- **LBS**: Google Maps deep linking
- **Sensors**: Pedometer, Accelerometer, GPS

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Development
```bash
# Run app
flutter run

# Hot reload: press 'r'
# Hot restart: press 'R'

# Build APK
flutter build apk --release
```

## 📦 Key Dependencies

### State Management
- `provider` - State management
- `get_it` - Dependency injection

### HTTP & Storage
- `dio` - HTTP client
- `flutter_secure_storage` - Secure token storage
- `sqflite` - Local database

### Authentication
- `local_auth` - Biometric authentication

### Sensors
- `pedometer` - Step counter
- `sensors_plus` - Accelerometer
- `geolocator` - GPS location

### Maps & Navigation
- `google_maps_flutter` - Maps integration
- `url_launcher` - Deep linking

### AI
- `google_generative_ai` - Gemini API

### Notifications
- `flutter_local_notifications` - Local notifications

## 📊 Feature Status

| Feature | Status | Documentation |
|---------|--------|---------------|
| Authentication | ✅ Done | [Auth](./features/auth.md) |
| Food Diary | ✅ Done | [Diary](./features/diary-integration.md) |
| Diet Plan | ✅ Done | - |
| Pedometer | ✅ Done | [Implementation](../implementation/pedometer/) |
| Recipe Management | ✅ Done | - |
| LBS | ✅ Done | [LBS](./features/lbs.md) |
| AI Chatbot | ✅ Done | [Chat](./features/chat-service.md) |
| Quiz | ✅ Done | - |
| Notifications | ✅ Done | - |
| Navigation | ✅ Done | - |
| Accessibility | ✅ Done | [Guide](./accessibility-guide.md) |

## 🔧 Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Local Storage**: SQLite + flutter_secure_storage
- **HTTP Client**: Dio
- **Sensors**: Pedometer, Accelerometer, GPS
- **Maps**: Google Maps Flutter
- **AI**: Gemini API

## 📝 Related Documentation

- [Flutter Setup](../getting-started/flutter-setup.md)
- [Implementation Guides](../implementation/)
- [Task Summaries](../tasks/)
- [Testing Documentation](../testing/frontend/)

---

**Last Updated**: April 29, 2026
