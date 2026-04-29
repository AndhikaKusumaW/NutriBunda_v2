# Provider Pattern Implementation

Dokumentasi untuk implementasi Provider pattern dan dependency injection di NutriBunda.

## Overview

Aplikasi NutriBunda menggunakan **Provider pattern** untuk state management dengan **GetIt** untuk dependency injection. Implementasi ini menyediakan:

- ✅ Base provider dengan error handling dan loading states
- ✅ Stateful provider dengan ResourceState management
- ✅ Dependency injection menggunakan GetIt
- ✅ Helper utilities untuk common operations
- ✅ Comprehensive testing support

## Architecture

```
lib/
├── core/
│   ├── utils/
│   │   ├── resource_state.dart      # State classes (Initial, Loading, Success, Error)
│   │   └── provider_helper.dart     # Helper utilities untuk providers
│   └── errors/
│       └── failures.dart             # Failure classes
├── presentation/
│   └── providers/
│       ├── base_provider.dart        # Base provider dengan error handling
│       ├── stateful_provider.dart    # Provider dengan ResourceState
│       └── app_provider.dart         # Example provider
└── injection_container.dart          # GetIt dependency injection setup
```

## Base Provider

`BaseProvider` adalah abstract class yang menyediakan common functionality untuk semua providers.

### Features

- ✅ Loading state management
- ✅ Error/Failure handling
- ✅ Safe notify listeners (tidak notify setelah dispose)
- ✅ Helper methods untuk async operations
- ✅ Automatic error conversion

### Usage

```dart
class MyProvider extends BaseProvider {
  List<Item> _items = [];
  
  List<Item> get items => _items;
  
  Future<void> loadItems() async {
    await executeWithLoading(() async {
      final result = await repository.getItems();
      _items = result;
    });
  }
  
  Future<void> deleteItem(String id) async {
    await executeWithLoading(
      () async {
        await repository.deleteItem(id);
        _items.removeWhere((item) => item.id == id);
      },
      onError: (failure) {
        // Handle error
        print('Error: ${failure.message}');
      },
    );
  }
}
```

### Available Methods

- `setLoading(bool loading)` - Set loading state
- `setFailure(Failure? failure)` - Set error/failure
- `clearError()` - Clear error state
- `executeWithLoading<T>(operation)` - Execute async operation dengan automatic loading state
- `executeWithState<T>(operation)` - Execute async operation dan return ResourceState
- `resetState()` - Reset provider state

### Properties

- `isLoading` - Loading state
- `failure` - Current failure
- `hasError` - Apakah ada error
- `errorMessage` - Error message string

## Stateful Provider

`StatefulProvider<T>` extends `BaseProvider` dan menambahkan ResourceState management.

### Features

- ✅ ResourceState tracking (Initial, Loading, Success, Error)
- ✅ Type-safe data access
- ✅ Automatic state transitions
- ✅ Inherited error handling dari BaseProvider

### Usage

```dart
class UserProvider extends StatefulProvider<User> {
  Future<void> loadUser(String userId) async {
    await executeWithStateManagement(() async {
      return await repository.getUser(userId);
    });
  }
}

// Di widget
Consumer<UserProvider>(
  builder: (context, provider, child) {
    if (provider.isStateLoading) {
      return CircularProgressIndicator();
    }
    
    if (provider.isStateError) {
      return Text('Error: ${provider.errorMessage}');
    }
    
    if (provider.isStateSuccess) {
      final user = provider.data!;
      return Text('Hello, ${user.name}');
    }
    
    return Text('No data');
  },
)
```

### Available Methods

- `setState(ResourceState<T> newState)` - Set state
- `executeWithStateManagement(operation)` - Execute dengan automatic state management

### Properties

- `state` - Current ResourceState
- `isStateLoading` - Apakah state Loading
- `isStateSuccess` - Apakah state Success
- `isStateError` - Apakah state Error
- `isStateInitial` - Apakah state Initial
- `data` - Data dari Success state (null jika bukan Success)

## Resource State

ResourceState adalah sealed class untuk represent berbagai state dari data loading.

### States

```dart
// Initial state sebelum ada operasi
const Initial<T>()

// Loading state saat data sedang dimuat
const Loading<T>()

// Success state dengan data
const Success<T>(data)

// Error state dengan failure
const Error<T>(failure)
```

### Usage

```dart
final state = await executeWithState(() async {
  return await fetchData();
});

switch (state) {
  case Initial<Data>():
    print('No operation yet');
  case Loading<Data>():
    print('Loading...');
  case Success<Data>(:final data):
    print('Success: $data');
  case Error<Data>(:final failure):
    print('Error: ${failure.message}');
}
```

## Dependency Injection

Menggunakan GetIt untuk dependency injection.

### Setup

```dart
// Di main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize dependencies
  runApp(MyApp());
}
```

### Registration

```dart
// Di injection_container.dart

// Providers - gunakan registerFactory
sl.registerFactory(() => AuthProvider(
  loginUseCase: sl(),
  logoutUseCase: sl(),
));

// Use Cases - gunakan registerLazySingleton
sl.registerLazySingleton(() => LoginUseCase(
  repository: sl(),
));

// Repositories - gunakan registerLazySingleton
sl.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
  ),
);

// Services - gunakan registerLazySingleton
sl.registerLazySingleton(() => BiometricService());
```

### Usage

```dart
// Get instance dari service locator
final authProvider = sl<AuthProvider>();

// Di MultiProvider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
    ChangeNotifierProvider(create: (_) => sl<FoodDiaryProvider>()),
  ],
  child: MyApp(),
)
```

## Provider Helper

Utility class untuk common provider operations.

### Usage

```dart
// Read provider tanpa listen
final provider = ProviderHelper.read<AuthProvider>(context);
await provider.login(email, password);

// Watch provider dengan listen
final isLoading = ProviderHelper.watch<AuthProvider>(context).isLoading;

// Select specific value
final userName = ProviderHelper.select<UserProvider, String>(
  context,
  (provider) => provider.user?.name ?? '',
);

// Execute dengan error handling
await ProviderHelper.executeProviderMethod(
  context,
  () => provider.loadData(),
  onSuccess: (data) {
    ProviderHelper.showSuccessSnackbar(context, 'Data loaded');
  },
  onError: (error) {
    ProviderHelper.showErrorSnackbar(context, error);
  },
);

// Show loading dialog
ProviderHelper.showLoadingDialog(context, message: 'Loading...');
await someOperation();
ProviderHelper.hideLoadingDialog(context);

// Show snackbars
ProviderHelper.showSuccessSnackbar(context, 'Success!');
ProviderHelper.showErrorSnackbar(context, 'Error occurred');
ProviderHelper.showInfoSnackbar(context, 'Info message');
```

## Best Practices

### 1. Provider Lifecycle

```dart
// ✅ Good - dispose resources
class MyProvider extends BaseProvider {
  StreamSubscription? _subscription;
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// ❌ Bad - tidak dispose resources
class MyProvider extends BaseProvider {
  StreamSubscription? _subscription;
  // Missing dispose!
}
```

### 2. Error Handling

```dart
// ✅ Good - handle errors properly
Future<void> loadData() async {
  await executeWithLoading(
    () async {
      final data = await repository.getData();
      _data = data;
    },
    onError: (failure) {
      // Log error, show message, etc
      debugPrint('Error loading data: ${failure.message}');
    },
  );
}

// ❌ Bad - tidak handle errors
Future<void> loadData() async {
  final data = await repository.getData(); // Bisa throw error!
  _data = data;
  notifyListeners();
}
```

### 3. State Management

```dart
// ✅ Good - gunakan StatefulProvider untuk complex state
class UserProvider extends StatefulProvider<User> {
  Future<void> loadUser() async {
    await executeWithStateManagement(() async {
      return await repository.getUser();
    });
  }
}

// ✅ Good - gunakan BaseProvider untuk simple state
class CounterProvider extends BaseProvider {
  int _count = 0;
  int get count => _count;
  
  void increment() {
    _count++;
    safeNotifyListeners();
  }
}
```

### 4. Dependency Injection

```dart
// ✅ Good - inject dependencies
class AuthProvider extends BaseProvider {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  
  AuthProvider({
    required this.loginUseCase,
    required this.logoutUseCase,
  });
}

// ❌ Bad - create dependencies inside provider
class AuthProvider extends BaseProvider {
  final loginUseCase = LoginUseCase(); // Hard to test!
}
```

### 5. Testing

```dart
// ✅ Good - test provider behavior
test('should update loading state during operation', () async {
  final provider = TestProvider();
  
  expect(provider.isLoading, false);
  
  final future = provider.loadData();
  await Future.delayed(Duration(milliseconds: 50));
  expect(provider.isLoading, true);
  
  await future;
  expect(provider.isLoading, false);
});
```

## Testing

Lihat test files untuk examples:
- `test/presentation/providers/base_provider_test.dart`
- `test/presentation/providers/stateful_provider_test.dart`

## Requirements Mapping

Implementasi ini memenuhi requirements:

- **Requirement 13.1**: Setup struktur clean architecture dengan Provider pattern
- **Requirement 13.2**: State management dengan error handling dan loading states

## Next Steps

1. Implement specific providers (AuthProvider, FoodDiaryProvider, dll)
2. Register providers di injection_container.dart
3. Add providers ke MultiProvider di main.dart
4. Implement use cases dan repositories
5. Write integration tests
