# Authentication Module

This module implements JWT-based authentication with bcrypt password hashing for the NutriBunda backend API.

## Features

- User registration with email and password
- User login with JWT token generation
- JWT middleware for protecting endpoints
- Bcrypt password hashing for security
- Token validation and expiration handling

## Components

### Service (`service.go`)
Core authentication logic including:
- User registration with password hashing
- User login with credential validation
- JWT token generation and validation
- User retrieval by ID

### Handler (`handler.go`)
HTTP request handlers for:
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user (protected)

### Middleware (`middleware.go`)
JWT authentication middleware that:
- Validates Authorization header format
- Verifies JWT token signature and expiration
- Extracts user information into request context
- Protects endpoints from unauthorized access

## API Endpoints

### Register
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "John Doe"
}
```

**Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "John Doe",
    "timezone": "WIB",
    "created_at": "2026-04-27T10:00:00Z",
    "updated_at": "2026-04-27T10:00:00Z"
  }
}
```

### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "John Doe",
    ...
  }
}
```

### Logout
```http
POST /api/auth/logout
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "message": "Logged out successfully"
}
```

## Security Features

### Password Hashing
- Uses bcrypt with default cost (10)
- Passwords are never stored in plain text
- Hash verification during login

### JWT Tokens
- Signed with HMAC-SHA256
- Configurable expiration time (default: 24h)
- Contains user ID and email in claims
- Validated on every protected request

### Error Handling
- Generic error messages to prevent information leakage
- No distinction between "user not found" and "wrong password"
- Proper HTTP status codes

## Testing

### Unit Tests
Run unit tests for the auth service:
```bash
cd backend
go test ./internal/auth -v -run TestRegister
go test ./internal/auth -v -run TestLogin
go test ./internal/auth -v -run TestValidateToken
```

### Integration Tests
Run integration tests for API endpoints:
```bash
cd backend
go test ./internal/auth -v -run TestRegisterEndpoint
go test ./internal/auth -v -run TestLoginEndpoint
go test ./internal/auth -v -run TestJWTMiddleware
```

### Property-Based Tests
Run property-based tests for password hashing:
```bash
cd backend
go test ./internal/auth -v -run TestPasswordHashingConsistency
```

### All Tests
Run all auth tests:
```bash
cd backend
go test ./internal/auth -v
```

## Configuration

The auth module requires the following environment variables:

```env
JWT_SECRET=your-secret-key-change-this-in-production
JWT_EXPIRATION=24h
```

## Usage Example

### Protecting Routes
```go
import (
    "nutribunda-backend/internal/auth"
)

// Create auth service
authService, _ := auth.NewService(db, jwtSecret, jwtExpiration)

// Apply middleware to protected routes
protectedRoutes := router.Group("/api/protected")
protectedRoutes.Use(auth.JWTMiddleware(authService))
{
    protectedRoutes.GET("/profile", profileHandler)
}
```

### Getting User from Context
```go
import (
    "nutribunda-backend/internal/auth"
)

func profileHandler(c *gin.Context) {
    userID, err := auth.GetUserID(c)
    if err != nil {
        c.JSON(401, gin.H{"error": "Unauthorized"})
        return
    }
    
    // Use userID to fetch user data
    // ...
}
```

## Requirements Satisfied

This implementation satisfies the following requirements from the spec:

- **Requirement 1.1**: User registration with email and password
- **Requirement 1.2**: Password hashing with bcrypt before storage
- **Requirement 1.3**: JWT token generation on successful login
- **Requirement 1.4**: JWT storage (handled by client)
- **Requirement 1.5**: Descriptive error messages without security details
- **Requirement 1.6**: Token expiration and rejection of expired tokens
- **Requirement 1.7**: Logout functionality with token deletion

## Error Codes

| Error | HTTP Status | Description |
|-------|-------------|-------------|
| `ErrInvalidCredentials` | 401 | Invalid email or password |
| `ErrEmailAlreadyExists` | 409 | Email already registered |
| `ErrUserNotFound` | 404 | User not found |
| `ErrInvalidToken` | 401 | Invalid or expired token |
