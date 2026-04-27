# User Profile Module

This module implements user profile management including CRUD operations and profile image upload with compression for the NutriBunda backend API.

## Features

- Get user profile information
- Update user profile data with validation
- Upload and compress profile images
- Delete profile images
- Data validation (weight: 30-200kg, height: 100-250cm)
- Image compression to max 500KB
- Support for JPEG and PNG formats

## Components

### Service (`service.go`)
Core user profile logic including:
- Profile retrieval by user ID
- Profile updates with field validation
- Image upload with automatic compression
- Image deletion with file cleanup

### Handler (`handler.go`)
HTTP request handlers for:
- `GET /api/profile` - Get current user profile
- `PUT /api/profile` - Update user profile
- `POST /api/profile/upload-image` - Upload profile image
- `DELETE /api/profile/image` - Delete profile image

## API Endpoints

All endpoints require JWT authentication via `Authorization: Bearer <token>` header.

### Get Profile
```http
GET /api/profile
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "John Doe",
    "weight": 65.5,
    "height": 165.0,
    "age": 30,
    "is_breastfeeding": true,
    "activity_level": "lightly_active",
    "profile_image_url": "/uploads/image.jpg",
    "timezone": "WIB",
    "created_at": "2026-04-27T10:00:00Z",
    "updated_at": "2026-04-27T10:30:00Z"
  }
}
```

### Update Profile
```http
PUT /api/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "full_name": "Jane Doe",
  "weight": 60.0,
  "height": 160.0,
  "age": 28,
  "is_breastfeeding": true,
  "activity_level": "moderately_active",
  "timezone": "WITA"
}
```

**Note:** All fields are optional. Only provided fields will be updated.

**Response (200 OK):**
```json
{
  "message": "Profile updated successfully",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "Jane Doe",
    "weight": 60.0,
    "height": 160.0,
    ...
  }
}
```

### Upload Profile Image
```http
POST /api/profile/upload-image
Authorization: Bearer <token>
Content-Type: multipart/form-data

image: <file>
```

**Response (200 OK):**
```json
{
  "message": "Profile image uploaded successfully",
  "user": {
    "id": "uuid",
    "profile_image_url": "/uploads/abc123.jpg",
    ...
  }
}
```

### Delete Profile Image
```http
DELETE /api/profile/image
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "message": "Profile image deleted successfully"
}
```

## Validation Rules

### Weight
- **Range:** 30 - 200 kg
- **Type:** Decimal (2 decimal places)
- **Error:** `ErrInvalidWeight` (400 Bad Request)

### Height
- **Range:** 100 - 250 cm
- **Type:** Decimal (2 decimal places)
- **Error:** `ErrInvalidHeight` (400 Bad Request)

### Activity Level
- **Valid values:**
  - `sedentary` - Little to no exercise
  - `lightly_active` - Light exercise 1-3 days/week
  - `moderately_active` - Moderate exercise 3-5 days/week
- **Error:** Invalid activity level (400 Bad Request)

### Timezone
- **Valid values:**
  - `WIB` - Western Indonesia Time (UTC+7)
  - `WITA` - Central Indonesia Time (UTC+8)
  - `WIT` - Eastern Indonesia Time (UTC+9)
- **Error:** Invalid timezone (400 Bad Request)

### Profile Image
- **Max file size:** 10 MB (before compression)
- **Compressed size:** Max 500 KB
- **Formats:** JPEG, PNG
- **Max width:** 800px (auto-resized if larger)
- **Errors:**
  - `ErrImageTooLarge` (400 Bad Request)
  - `ErrInvalidImageFormat` (400 Bad Request)

## Image Processing

### Compression Algorithm
1. Validate file size (max 10MB)
2. Decode image (JPEG or PNG)
3. Resize if width > 800px (maintains aspect ratio)
4. For JPEG: Try quality levels 85, 75, 65, 55, 50 until size ≤ 500KB
5. For PNG: Encode with standard compression
6. Save to uploads directory with unique UUID filename
7. Update database with image URL

### File Storage
- **Directory:** `./uploads/`
- **Filename format:** `<uuid>.<ext>`
- **URL format:** `/uploads/<uuid>.<ext>`
- **Cleanup:** Old images are deleted when new ones are uploaded

## Testing

### Unit Tests
Run unit tests for the user service:
```bash
cd backend
go test ./internal/user -v -run TestGetProfile
go test ./internal/user -v -run TestUpdateProfile
go test ./internal/user -v -run TestUploadProfileImage
```

### Property-Based Tests
Run property-based tests for validation:
```bash
cd backend
go test ./internal/user -v -run TestProfileValidationConsistency
```

### All Tests
Run all user tests:
```bash
cd backend
go test ./internal/user -v
```

## Usage Example

### Creating User Service
```go
import (
    "nutribunda-backend/internal/user"
)

// Create user service with upload directory
userService := user.NewService(db, "./uploads")

// Create handler
userHandler := user.NewHandler(userService)

// Register routes
profileRoutes := router.Group("/api/profile")
profileRoutes.Use(auth.JWTMiddleware(authService))
{
    profileRoutes.GET("", userHandler.GetProfile)
    profileRoutes.PUT("", userHandler.UpdateProfile)
    profileRoutes.POST("/upload-image", userHandler.UploadProfileImage)
    profileRoutes.DELETE("/image", userHandler.DeleteProfileImage)
}
```

### Updating Profile Programmatically
```go
import (
    "nutribunda-backend/internal/user"
)

weight := 65.5
height := 165.0
req := &user.UpdateProfileRequest{
    Weight: &weight,
    Height: &height,
}

updatedUser, err := userService.UpdateProfile(userID, req)
if err != nil {
    // Handle error
}
```

## Requirements Satisfied

This implementation satisfies the following requirements from the spec:

- **Requirement 12.1**: Display user profile with all fields
- **Requirement 12.2**: Upload profile image from gallery or camera
- **Requirement 12.3**: Compress image to max 500KB before upload
- **Requirement 12.4**: Validate weight (30-200kg) and height (100-250cm)
- **Requirement 12.5**: Display specific error messages for invalid fields

## Error Codes

| Error | HTTP Status | Description |
|-------|-------------|-------------|
| `ErrUserNotFound` | 404 | User not found |
| `ErrInvalidWeight` | 400 | Weight must be between 30 and 200 kg |
| `ErrInvalidHeight` | 400 | Height must be between 100 and 250 cm |
| `ErrInvalidImageFormat` | 400 | Only JPEG and PNG are supported |
| `ErrImageTooLarge` | 400 | Image exceeds 10MB limit |

## File Structure

```
internal/user/
├── service.go          # Core business logic
├── handler.go          # HTTP handlers
├── service_test.go     # Unit and property tests
└── README.md           # This file
```

## Dependencies

- `github.com/nfnt/resize` - Image resizing
- `github.com/google/uuid` - UUID generation
- `gorm.io/gorm` - Database ORM
- `github.com/gin-gonic/gin` - HTTP framework
