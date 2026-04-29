# Authentication Implementation

## Overview

This directory contains the authentication UI implementation for NutriBunda, including login and registration screens with comprehensive form validation and error handling.

## Requirements Implemented

### Requirement 1.1: User Registration and Login
- ✅ Auth_Service accepts full name, email, and password for registration
- ✅ Login accepts email and password
- ✅ JWT token is stored in encrypted storage (flutter_secure_storage)

### Requirement 1.5: Error Handling
- ✅ Descriptive error messages for invalid email or password
- ✅ Form validation with real-time feedback
- ✅ Network error handling

### Requirement 1.7: Logout
- ✅ JWT token is removed from secure storage on logout
- ✅ User is redirected to login screen after logout

## Files

### `login_screen.dart`
Login screen with:
- Email and password input fields
- Form validation (email format, required fields)
- Error message display
- Loading state during authentication
- Navigation to register screen
- Password visibility toggle

### `register_screen.dart`
Registration screen with:
- Full name, email, password, and confirm password fields
- Comprehensive password validation:
  - Minimum 8 characters
  - At least 1 uppercase letter
  - At least 1 lowercase letter
  - At least 1 number
- Password requirements info display
- Password confirmation matching
- Error message display
- Loading state during registration

## Form Validation

### Email Validation
- Required field
- Valid email format (regex: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

### Password Validation (Registration)
- Minimum 8 characters
- At least 1 uppercase letter (A-Z)
- At least 1 lowercase letter (a-z)
- At least 1 digit (0-9)

### Full Name Validation
- Required field
- Minimum 3 characters

## Error Messages

The implementation provides descriptive error messages for various scenarios:

### Login Errors
- "Email dan password tidak boleh kosong" - Empty fields
- "Format email tidak valid" - Invalid email format
- "Email atau password salah" - Invalid credentials (401)
- "Data login tidak valid" - Validation error (400)
- "Tidak dapat terhubung ke server. Periksa koneksi internet Anda." - Network error
- "Terjadi kesalahan. Silakan coba lagi." - Generic error

### Registration Errors
- "Semua field harus diisi" - Empty fields
- "Format email tidak valid" - Invalid email format
- "Password minimal 8 karakter" - Password too short
- "Password harus mengandung minimal 1 huruf besar" - Missing uppercase
- "Password harus mengandung minimal 1 huruf kecil" - Missing lowercase
- "Password harus mengandung minimal 1 angka" - Missing digit
- "Password tidak cocok" - Password confirmation mismatch
- "Email sudah terdaftar" - Duplicate email (409)
- "Tidak dapat terhubung ke server. Periksa koneksi internet Anda." - Network error

## Usage

### Login Flow
1. User opens app
2. If not authenticated, LoginScreen is displayed
3. User enters email and password
4. Form validation runs
5. If valid, AuthProvider.login() is called
6. On success, user is navigated to home screen
7. JWT token is stored in secure storage

### Registration Flow
1. User clicks "Daftar" on login screen
2. RegisterScreen is displayed
3. User enters full name, email, password, and confirm password
4. Form validation runs (including password strength)
5. If valid, AuthProvider.register() is called
6. On success, user is navigated to home screen
7. JWT token is stored in secure storage

### Logout Flow
1. User clicks logout button
2. AuthProvider.logout() is called
3. JWT token is removed from secure storage
4. User is navigated to login screen

## Testing

Unit tests are available in `test/presentation/providers/auth_provider_test.dart`:
- Login with valid credentials
- Login with invalid email format
- Login with empty fields
- Login with wrong credentials
- Register with valid data
- Register with weak password
- Register with existing email
- Logout functionality
- Error handling

Run tests with:
```bash
flutter test test/presentation/providers/auth_provider_test.dart
```

## Backend API Integration

The screens integrate with the following backend endpoints:

### POST /api/auth/login
Request:
```json
{
  "email": "user@example.com",
  "password": "Password123"
}
```

Response (200):
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "User Name",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### POST /api/auth/register
Request:
```json
{
  "full_name": "User Name",
  "email": "user@example.com",
  "password": "Password123"
}
```

Response (201):
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "User Name",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### POST /api/auth/logout
Request:
- Headers: `Authorization: Bearer <token>`

Response (200):
```json
{
  "message": "success"
}
```

## Security Considerations

1. **Password Storage**: Passwords are never stored locally. Only the JWT token is stored in encrypted storage.

2. **Secure Storage**: JWT tokens are stored using `flutter_secure_storage` with:
   - Android: Encrypted SharedPreferences
   - iOS: Keychain with first_unlock accessibility

3. **Password Validation**: Strong password requirements enforce security best practices.

4. **Error Messages**: Error messages don't reveal sensitive information (e.g., "Email atau password salah" instead of "Email not found").

5. **HTTPS**: In production, ensure the backend API uses HTTPS to encrypt data in transit.

## Future Enhancements

- [ ] Biometric authentication (fingerprint/Face ID)
- [ ] Remember me functionality
- [ ] Password reset flow
- [ ] Email verification
- [ ] Social login (Google, Facebook)
- [ ] Two-factor authentication (2FA)
