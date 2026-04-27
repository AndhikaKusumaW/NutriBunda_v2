# Core Services

Direktori ini berisi service-service inti yang digunakan di seluruh aplikasi NutriBunda.

## Services

### 1. SecureStorageService

Service untuk mengelola penyimpanan terenkripsi menggunakan `flutter_secure_storage`.

**Fitur:**
- Menyimpan dan mengambil JWT access token dan refresh token
- Menyimpan data user (ID, email)
- Mengelola pengaturan biometric authentication
- Menyediakan utility methods untuk custom key-value storage

**Requirements yang dipenuhi:**
- **Requirement 1.4**: JWT harus disimpan di penyimpanan terenkripsi perangkat
- **Requirement 1.6**: Middleware JWT untuk proteksi endpoint
- **Requirement 1.7**: Saat logout, JWT harus dihapus dari storage

**Penggunaan:**

```dart
// Inject via GetIt
final secureStorage = sl<SecureStorageService>();

// Simpan token
await secureStorage.saveAccessToken('jwt_token_here');
await secureStorage.saveRefreshToken('refresh_token_here');

// Ambil token
final token = await secureStorage.getAccessToken();

// Cek apakah user memiliki token valid
final hasToken = await secureStorage.hasValidToken();

// Hapus token saat logout
await secureStorage.deleteTokens();

// Simpan user data
await secureStorage.saveUserId('user_123');
await secureStorage.saveUserEmail('user@example.com');

// Biometric settings
await secureStorage.setBiometricEnabled(true);
final isBiometricEnabled = await secureStorage.isBiometricEnabled();

// Clear semua data
await secureStorage.clearAll();
```

**Platform Configuration:**

Android (`AndroidManifest.xml`):
```xml
<!-- Tidak perlu konfigurasi tambahan, sudah otomatis menggunakan EncryptedSharedPreferences -->
```

iOS (`Info.plist`):
```xml
<!-- Tidak perlu konfigurasi tambahan, sudah otomatis menggunakan Keychain -->
```

---

### 2. HttpClientService

Service untuk mengelola HTTP client dengan Dio, termasuk interceptors untuk autentikasi dan error handling.

**Fitur:**
- Automatic JWT token injection ke request headers
- Automatic token refresh saat token expired (401)
- Comprehensive error handling dengan custom exceptions
- Support untuk semua HTTP methods (GET, POST, PUT, DELETE, PATCH)
- File upload dan download support
- Request/response logging untuk debugging

**Requirements yang dipenuhi:**
- **Requirement 1.4**: JWT harus dapat diambil untuk autentikasi API
- **Requirement 1.6**: Middleware JWT untuk proteksi endpoint dan automatic token refresh

**Penggunaan:**

```dart
// Inject via GetIt
final httpClient = sl<HttpClientService>();

// GET request
final response = await httpClient.get('/api/foods');
final foods = response.data;

// POST request
final response = await httpClient.post(
  '/api/auth/login',
  data: {
    'email': 'user@example.com',
    'password': 'password123',
  },
);

// PUT request
final response = await httpClient.put(
  '/api/profile',
  data: {
    'full_name': 'John Doe',
    'weight': 70.5,
  },
);

// DELETE request
await httpClient.delete('/api/diary/123');

// Upload file
final response = await httpClient.uploadFile(
  '/api/profile/upload-image',
  filePath: '/path/to/image.jpg',
  fieldName: 'image',
  data: {'description': 'Profile photo'},
  onSendProgress: (sent, total) {
    print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
  },
);

// Download file
await httpClient.downloadFile(
  '/api/files/document.pdf',
  '/path/to/save/document.pdf',
  onReceiveProgress: (received, total) {
    print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
  },
);

// Utility methods
httpClient.updateBaseUrl('https://new-api.example.com');
httpClient.addHeader('X-Custom-Header', 'value');
httpClient.removeHeader('X-Custom-Header');
httpClient.clearHeaders();
```

**Automatic Token Refresh:**

Service ini secara otomatis menangani token refresh saat menerima response 401 (Unauthorized):

1. Saat request mendapat response 401, interceptor akan mencoba refresh token
2. Jika refresh berhasil, request original akan di-retry dengan token baru
3. Jika refresh gagal, token akan dihapus dan user harus login ulang

**Error Handling:**

Service ini mengkonversi Dio errors menjadi custom exceptions:

- `NetworkException`: Connection timeout, no internet, connection error
- `UnauthorizedException`: 401 status code
- `ValidationException`: 400 status code
- `ServerException`: 404, 500+ status codes

```dart
try {
  final response = await httpClient.get('/api/foods');
  // Handle success
} on NetworkException catch (e) {
  // Handle network errors
  print('Network error: ${e.message}');
} on UnauthorizedException catch (e) {
  // Handle unauthorized (redirect to login)
  print('Unauthorized: ${e.message}');
} on ValidationException catch (e) {
  // Handle validation errors
  print('Validation error: ${e.message}');
} on ServerException catch (e) {
  // Handle server errors
  print('Server error: ${e.message}');
}
```

**Request Interceptor Flow:**

```
Request
  ↓
Check if auth endpoint? → Yes → Skip token injection
  ↓ No
Get token from SecureStorageService
  ↓
Add Authorization header: Bearer <token>
  ↓
Send request
  ↓
Response 401? → Yes → Attempt token refresh → Retry request
  ↓ No
Return response
```

---

## Dependency Injection

Kedua service ini sudah terdaftar di `injection_container.dart`:

```dart
// Secure Storage Service
sl.registerLazySingleton<SecureStorageService>(
  () => SecureStorageService(secureStorage: sl()),
);

// HTTP Client Service
sl.registerLazySingleton<HttpClientService>(
  () => HttpClientService(secureStorage: sl()),
);
```

## Testing

Kedua service memiliki comprehensive unit tests:

- `test/core/services/secure_storage_service_test.dart` - 28 tests
- `test/core/services/http_client_service_test.dart` - 16 tests

Run tests:

```bash
# Test semua services
flutter test test/core/services/

# Test specific service
flutter test test/core/services/secure_storage_service_test.dart
flutter test test/core/services/http_client_service_test.dart
```

## Security Considerations

### SecureStorageService

1. **Android**: Menggunakan `EncryptedSharedPreferences` untuk enkripsi data
2. **iOS**: Menggunakan Keychain dengan accessibility level `first_unlock`
3. **Token Storage**: JWT tokens disimpan terenkripsi dan hanya dapat diakses oleh aplikasi
4. **Biometric Data**: Pengaturan biometric disimpan terenkripsi

### HttpClientService

1. **Token Injection**: Token hanya ditambahkan untuk non-auth endpoints
2. **Token Refresh**: Automatic refresh mencegah session expired yang tidak perlu
3. **Error Handling**: Tidak mengekspos detail internal error ke user
4. **HTTPS Only**: Pastikan base URL menggunakan HTTPS di production

## Best Practices

1. **Jangan hardcode tokens**: Selalu gunakan SecureStorageService untuk menyimpan tokens
2. **Handle errors gracefully**: Gunakan try-catch untuk menangani exceptions dari HttpClientService
3. **Clear tokens on logout**: Selalu panggil `deleteTokens()` atau `clearAll()` saat logout
4. **Use dependency injection**: Selalu inject services via GetIt, jangan create instance manual
5. **Test thoroughly**: Pastikan semua edge cases tertangani dengan baik

## Future Enhancements

1. **Certificate Pinning**: Tambahkan SSL pinning untuk keamanan tambahan
2. **Request Caching**: Implementasi caching untuk mengurangi network calls
3. **Offline Queue**: Queue requests saat offline dan kirim saat online
4. **Rate Limiting**: Implementasi rate limiting untuk mencegah abuse
5. **Request Retry**: Automatic retry untuk failed requests dengan exponential backoff
