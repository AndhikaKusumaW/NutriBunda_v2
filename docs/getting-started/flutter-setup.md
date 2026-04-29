# NutriBunda Flutter Setup

Setup Flutter mobile app untuk NutriBunda.

## Prerequisites

- Flutter SDK 3.x
- Android Studio / Xcode (untuk emulator)
- Backend API running (see [Backend Setup](./backend-setup.md))
- Git

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Local Storage**: SQLite + flutter_secure_storage
- **HTTP Client**: Dio
- **Sensors**: Pedometer, Accelerometer
- **Maps**: Google Maps Flutter
- **AI**: Gemini API

## Project Structure

```
nutribunda/
├── lib/
│   ├── core/               # Core utilities, constants, services
│   │   ├── constants/      # App constants
│   │   ├── services/       # Services (HTTP, storage, chat, sync)
│   │   └── utils/          # Utility functions
│   ├── data/               # Data layer
│   │   ├── datasources/    # Local & remote data sources
│   │   ├── models/         # Data models
│   │   └── repositories/   # Repository implementations
│   ├── domain/             # Domain layer
│   │   ├── entities/       # Business entities
│   │   └── repositories/   # Repository interfaces
│   ├── presentation/       # Presentation layer
│   │   ├── pages/          # UI screens
│   │   ├── providers/      # State management
│   │   ├── themes/         # App themes
│   │   └── widgets/        # Reusable widgets
│   └── main.dart           # Entry point
├── test/                   # Unit & widget tests
├── integration_test/       # Integration tests
└── pubspec.yaml            # Dependencies
```

## Setup Steps

### 1. Navigate to Flutter Directory

```bash
cd nutribunda
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment

Create `.env` file di root folder `nutribunda/`:

```env
# API Configuration
API_BASE_URL=http://localhost:8080/api

# Gemini API
GEMINI_API_KEY=your-gemini-api-key-here

# Google Maps (optional for LBS)
GOOGLE_MAPS_API_KEY=your-google-maps-key-here
```

### 4. Run the App

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode (default)
flutter run

# Run in release mode
flutter run --release
```

## Development Workflow

### Hot Reload

Saat app running, tekan:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

### Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/providers/auth_provider_test.dart

# Run integration tests
flutter test integration_test/
```

### Build for Production

#### Android APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK by ABI (smaller size)
flutter build apk --split-per-abi
```

APK location: `build/app/outputs/flutter-apk/`

#### iOS

```bash
# Build iOS
flutter build ios --release
```

Requires macOS and Xcode.

### Code Generation

Jika menggunakan code generation (freezed, json_serializable):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Key Features Setup

### 1. Authentication

Menggunakan JWT tokens yang disimpan di secure storage:

```dart
// Login
await authProvider.login(email, password);

// Register
await authProvider.register(email, password, fullName);

// Biometric auth
await authProvider.authenticateWithBiometrics();
```

See: [Auth Feature Documentation](../frontend/features/auth.md)

### 2. Food Diary

Pencatatan makanan harian dengan offline support:

```dart
// Add diary entry
await diaryProvider.addEntry(entry);

// Get entries
await diaryProvider.fetchEntries(date);

// Sync with server
await diaryProvider.syncEntries();
```

See: [Diary Integration Guide](../frontend/features/diary-integration.md)

### 3. Diet Plan

Kalkulasi BMR/TDEE dengan pedometer tracking:

```dart
// Calculate BMR
final bmr = dietPlanProvider.calculateBMR(weight, height, age);

// Get step count
final steps = await pedometerProvider.getStepCount();
```

### 4. AI Chatbot

Konsultasi gizi dengan Gemini API:

```dart
// Send message
await chatProvider.sendMessage(message);

// Get response
final response = chatProvider.messages.last;
```

See: [Gemini API Setup](../implementation/gemini-api-setup.md)

### 5. Location-Based Services

Pencarian fasilitas kesehatan terdekat:

```dart
// Get current location
final location = await lbsProvider.getCurrentLocation();

// Open in maps
await lbsProvider.openInMaps(latitude, longitude);
```

See: [LBS Feature](../frontend/features/lbs.md)

## Testing

### Unit Tests

```bash
flutter test test/providers/
flutter test test/services/
```

### Widget Tests

```bash
flutter test test/widgets/
```

### Integration Tests

```bash
flutter test integration_test/
```

See: [Frontend Testing Guide](../frontend/testing-guide.md)

## Troubleshooting

### "Pub get failed"
```bash
flutter clean
flutter pub get
```

### "No devices found"
- Start Android emulator or iOS simulator
- Connect physical device via USB
- Enable USB debugging (Android)

### "Build failed"
```bash
flutter clean
flutter pub get
flutter run
```

### "API connection failed"
- Ensure backend is running on `http://localhost:8080`
- Check `.env` file configuration
- For Android emulator, use `http://10.0.2.2:8080` instead of `localhost`

### "Biometric authentication not working"
- Ensure device has biometric hardware
- Enable biometric authentication in device settings
- Test on physical device (not emulator)

### "Pedometer not working"
- Test on physical device (emulators don't have sensors)
- Grant location/activity permissions
- Check sensor availability

### "Maps not loading"
- Add Google Maps API key to `.env`
- Enable Maps SDK in Google Cloud Console
- Add API key to `AndroidManifest.xml` and `Info.plist`

## Dependencies

Key dependencies in `pubspec.yaml`:

```yaml
dependencies:
  # State Management
  provider: ^6.0.0
  get_it: ^7.2.0
  
  # HTTP & Storage
  dio: ^5.0.0
  flutter_secure_storage: ^8.0.0
  sqflite: ^2.2.0
  
  # Authentication
  local_auth: ^2.1.0
  
  # Sensors
  pedometer: ^4.0.0
  sensors_plus: ^3.0.0
  geolocator: ^10.0.0
  
  # Maps
  google_maps_flutter: ^2.5.0
  url_launcher: ^6.2.0
  
  # AI
  google_generative_ai: ^0.2.0
  
  # Notifications
  flutter_local_notifications: ^16.0.0
  
  # UI
  intl: ^0.18.0
  cached_network_image: ^3.3.0
```

## Environment-Specific Configuration

### Development

```dart
const apiBaseUrl = 'http://localhost:8080/api';
```

### Production

```dart
const apiBaseUrl = 'https://api.nutribunda.com/api';
```

Use environment variables or build flavors untuk manage configurations.

## Next Steps

- [Accessibility Guide](../frontend/accessibility-guide.md)
- [Performance Monitoring](../frontend/performance-monitoring.md)
- [Implementation Guides](../implementation/)

---

**Last Updated**: April 29, 2026
