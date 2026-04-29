# API Testing Guide - NutriBunda Backend

This guide provides examples for testing the authentication and user profile endpoints using curl or any HTTP client.

## Prerequisites

1. Start PostgreSQL database:
```bash
docker-compose up -d
```

2. Start the API server:
```bash
cd backend
go run cmd/api/main.go
```

The server will start on `http://localhost:8080`

## Authentication Endpoints

### 1. Health Check
```bash
curl http://localhost:8080/api/health
```

**Expected Response:**
```json
{
  "status": "ok",
  "message": "NutriBunda API is running"
}
```

### 2. Register New User
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "full_name": "Test User"
  }'
```

**Expected Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "test@example.com",
    "full_name": "Test User",
    "weight": null,
    "height": null,
    "age": null,
    "is_breastfeeding": false,
    "activity_level": "sedentary",
    "profile_image_url": null,
    "timezone": "WIB",
    "created_at": "2026-04-27T10:00:00Z",
    "updated_at": "2026-04-27T10:00:00Z"
  }
}
```

**Save the token for subsequent requests!**

### 3. Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Expected Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { ... }
}
```

### 4. Logout
```bash
curl -X POST http://localhost:8080/api/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected Response (200 OK):**
```json
{
  "message": "Logged out successfully"
}
```

## User Profile Endpoints

**Note:** All profile endpoints require authentication. Replace `YOUR_TOKEN_HERE` with the token from login/register.

### 5. Get Profile
```bash
curl http://localhost:8080/api/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected Response (200 OK):**
```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "test@example.com",
    "full_name": "Test User",
    "weight": null,
    "height": null,
    "age": null,
    "is_breastfeeding": false,
    "activity_level": "sedentary",
    "profile_image_url": null,
    "timezone": "WIB",
    "created_at": "2026-04-27T10:00:00Z",
    "updated_at": "2026-04-27T10:00:00Z"
  }
}
```

### 6. Update Profile
```bash
curl -X PUT http://localhost:8080/api/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Updated Name",
    "weight": 65.5,
    "height": 165.0,
    "age": 30,
    "is_breastfeeding": true,
    "activity_level": "lightly_active",
    "timezone": "WITA"
  }'
```

**Expected Response (200 OK):**
```json
{
  "message": "Profile updated successfully",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "test@example.com",
    "full_name": "Updated Name",
    "weight": 65.5,
    "height": 165.0,
    "age": 30,
    "is_breastfeeding": true,
    "activity_level": "lightly_active",
    "profile_image_url": null,
    "timezone": "WITA",
    "created_at": "2026-04-27T10:00:00Z",
    "updated_at": "2026-04-27T10:30:00Z"
  }
}
```

### 7. Upload Profile Image
```bash
curl -X POST http://localhost:8080/api/profile/upload-image \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -F "image=@/path/to/your/image.jpg"
```

**Expected Response (200 OK):**
```json
{
  "message": "Profile image uploaded successfully",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "profile_image_url": "/uploads/abc123-def456.jpg",
    ...
  }
}
```

### 8. Delete Profile Image
```bash
curl -X DELETE http://localhost:8080/api/profile/image \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected Response (200 OK):**
```json
{
  "message": "Profile image deleted successfully"
}
```

## Error Scenarios

### Invalid Credentials
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "wrongpassword"
  }'
```

**Response (401 Unauthorized):**
```json
{
  "error": "Invalid email or password"
}
```

### Duplicate Email Registration
```bash
# Try to register with an existing email
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "full_name": "Another User"
  }'
```

**Response (409 Conflict):**
```json
{
  "error": "Email already exists"
}
```

### Invalid Weight
```bash
curl -X PUT http://localhost:8080/api/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "weight": 250.0
  }'
```

**Response (400 Bad Request):**
```json
{
  "error": "Weight must be between 30 and 200 kg"
}
```

### Invalid Height
```bash
curl -X PUT http://localhost:8080/api/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "height": 90.0
  }'
```

**Response (400 Bad Request):**
```json
{
  "error": "Height must be between 100 and 250 cm"
}
```

### Missing Authorization Header
```bash
curl http://localhost:8080/api/profile
```

**Response (401 Unauthorized):**
```json
{
  "error": "Authorization header is required"
}
```

### Invalid Token
```bash
curl http://localhost:8080/api/profile \
  -H "Authorization: Bearer invalid.token.here"
```

**Response (401 Unauthorized):**
```json
{
  "error": "Invalid or expired token"
}
```

## Testing with Postman

1. Import the following as a Postman collection
2. Create an environment variable `token` to store the JWT
3. Set `{{token}}` in Authorization header for protected endpoints

### Collection Structure
```
NutriBunda API
├── Auth
│   ├── Register
│   ├── Login
│   └── Logout
└── Profile
    ├── Get Profile
    ├── Update Profile
    ├── Upload Image
    └── Delete Image
```

## Testing Workflow

1. **Register** a new user → Save token
2. **Login** with credentials → Verify token matches
3. **Get Profile** → Verify default values
4. **Update Profile** → Verify changes persist
5. **Upload Image** → Verify image URL returned
6. **Get Profile** → Verify image URL present
7. **Delete Image** → Verify image removed
8. **Logout** → Verify success message

## Validation Test Cases

### Weight Validation
- ✅ Valid: 30.0, 65.5, 200.0
- ❌ Invalid: 29.9, 200.1, -10, 0

### Height Validation
- ✅ Valid: 100.0, 165.0, 250.0
- ❌ Invalid: 99.9, 250.1, -50, 0

### Activity Level Validation
- ✅ Valid: "sedentary", "lightly_active", "moderately_active"
- ❌ Invalid: "super_active", "inactive", ""

### Timezone Validation
- ✅ Valid: "WIB", "WITA", "WIT"
- ❌ Invalid: "PST", "UTC", "GMT"

### Image Format Validation
- ✅ Valid: .jpg, .jpeg, .png
- ❌ Invalid: .gif, .bmp, .svg, .pdf

## Notes

- All timestamps are in ISO 8601 format (UTC)
- JWT tokens expire after 24 hours (configurable)
- Profile images are automatically compressed to max 500KB
- Images wider than 800px are automatically resized
- Uploaded images are stored in `./uploads/` directory
- Image URLs are relative paths: `/uploads/<uuid>.<ext>`

## Troubleshooting

### "Failed to connect to database"
- Ensure PostgreSQL is running: `docker-compose ps`
- Check database credentials in `.env` file

### "Authorization header is required"
- Ensure you're including the token in the header
- Format: `Authorization: Bearer <token>`

### "Invalid or expired token"
- Token may have expired (24h default)
- Login again to get a new token

### "Image size exceeds 10MB limit"
- Compress image before upload
- Use smaller image file

### "Failed to upload image"
- Ensure `./uploads/` directory exists and is writable
- Check file format (only JPEG and PNG supported)
