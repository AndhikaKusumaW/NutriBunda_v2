# Implementation Guides

Panduan implementasi fitur-fitur spesifik dalam NutriBunda.

## 📚 Contents

### Core Implementations
- [Gemini API Setup](./gemini-api-setup.md) - Setup dan integrasi Gemini API untuk AI chatbot
- [SQLite Implementation](./sqlite-implementation.md) - Implementasi local database dengan SQLite
- [Sync Implementation](./sync-implementation.md) - Implementasi data synchronization offline-first
- [Null Safety Fix](./null-safety-fix.md) - Perbaikan null safety issues
- [Implementation Notes](./implementation-notes.md) - Catatan implementasi umum

### Pedometer Implementation
- [UI Implementation](./pedometer/ui-implementation.md) - Implementasi UI pedometer
- [Location Integration](./pedometer/location.md) - Integrasi GPS location
- [Error Fix](./pedometer/error-fix.md) - Perbaikan error pedometer

## 🚀 Quick Start Guides

### Gemini API Setup

1. Dapatkan API key dari [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Tambahkan ke `.env`:
   ```env
   GEMINI_API_KEY=your-api-key-here
   ```
3. Implementasi chat service:
   ```dart
   final chatService = ChatService(apiKey: geminiApiKey);
   await chatService.sendMessage(message);
   ```

See: [Gemini API Setup Guide](./gemini-api-setup.md)

### SQLite Implementation

1. Add dependencies:
   ```yaml
   dependencies:
     sqflite: ^2.2.0
     path: ^1.8.0
   ```
2. Create database helper
3. Implement CRUD operations
4. Add sync mechanism

See: [SQLite Implementation Guide](./sqlite-implementation.md)

### Sync Implementation

1. Implement conflict resolution strategy
2. Add timestamp tracking
3. Create sync service
4. Handle offline/online transitions

See: [Sync Implementation Guide](./sync-implementation.md)

### Pedometer Implementation

1. Add pedometer dependency
2. Request permissions
3. Listen to step count stream
4. Calculate calories burned

See: [Pedometer Guides](./pedometer/)

## 📊 Implementation Status

| Feature | Status | Guide |
|---------|--------|-------|
| Gemini API | ✅ Done | [Guide](./gemini-api-setup.md) |
| SQLite | ✅ Done | [Guide](./sqlite-implementation.md) |
| Sync Service | ✅ Done | [Guide](./sync-implementation.md) |
| Pedometer | ✅ Done | [Guides](./pedometer/) |
| Null Safety | ✅ Done | [Fix](./null-safety-fix.md) |

## 🔧 Common Patterns

### Offline-First Pattern

```dart
// 1. Try to fetch from local database
final localData = await localDataSource.getData();

// 2. Return local data immediately
if (localData.isNotEmpty) {
  return localData;
}

// 3. Fetch from API in background
try {
  final remoteData = await remoteDataSource.getData();
  await localDataSource.saveData(remoteData);
  return remoteData;
} catch (e) {
  // Return cached data if API fails
  return localData;
}
```

### Sync Pattern

```dart
// 1. Get unsync'd local changes
final unsynced = await localDataSource.getUnsyncedData();

// 2. Send to server
for (final item in unsynced) {
  try {
    await remoteDataSource.sync(item);
    await localDataSource.markAsSynced(item.id);
  } catch (e) {
    // Handle conflict or retry later
  }
}

// 3. Fetch server changes
final serverChanges = await remoteDataSource.getChanges(lastSyncTime);
await localDataSource.applyChanges(serverChanges);
```

### Error Handling Pattern

```dart
try {
  final result = await apiCall();
  return Right(result);
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    return Left(NetworkFailure('Connection timeout'));
  } else if (e.response?.statusCode == 401) {
    return Left(AuthFailure('Unauthorized'));
  } else {
    return Left(ServerFailure('Server error'));
  }
} catch (e) {
  return Left(UnexpectedFailure(e.toString()));
}
```

## 📝 Best Practices

### 1. Dependency Injection

Use GetIt untuk dependency injection:

```dart
final getIt = GetIt.instance;

void setupLocator() {
  // Services
  getIt.registerLazySingleton(() => HttpService());
  getIt.registerLazySingleton(() => StorageService());
  
  // Repositories
  getIt.registerLazySingleton(() => AuthRepository());
  
  // Providers
  getIt.registerFactory(() => AuthProvider());
}
```

### 2. State Management

Use Provider pattern dengan ChangeNotifier:

```dart
class MyProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final data = await repository.getData();
      // Process data
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 3. Error Handling

Always handle errors gracefully:

```dart
// Show user-friendly error messages
if (error != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error)),
  );
}

// Log errors for debugging
debugPrint('Error: $error');
```

### 4. Testing

Write tests for critical functionality:

```dart
test('should fetch data successfully', () async {
  // Arrange
  when(mockRepository.getData()).thenAnswer((_) async => testData);
  
  // Act
  await provider.fetchData();
  
  // Assert
  expect(provider.isLoading, false);
  expect(provider.error, null);
  expect(provider.data, testData);
});
```

## 🔗 Related Documentation

- [Frontend Documentation](../frontend/)
- [Backend Documentation](../backend/)
- [Task Summaries](../tasks/)
- [Testing Documentation](../testing/)

---

**Last Updated**: April 29, 2026
