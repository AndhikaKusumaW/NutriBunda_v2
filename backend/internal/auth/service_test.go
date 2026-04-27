package auth

import (
	"nutribunda-backend/internal/database"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// setupTestDB creates a test database connection
func setupTestDB(t *testing.T) *gorm.DB {
	// Use test database connection
	dsn := "host=localhost user=nutribunda_user password=nutribunda_pass dbname=nutribunda_test port=5432 sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	require.NoError(t, err)

	// Run migrations
	err = db.AutoMigrate(&database.User{})
	require.NoError(t, err)

	return db
}

// cleanupTestDB cleans up test data
func cleanupTestDB(t *testing.T, db *gorm.DB) {
	db.Exec("DELETE FROM users")
}

func TestNewService(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	service, err := NewService(db, "test-secret", "24h")
	require.NoError(t, err)
	assert.NotNil(t, service)
	assert.Equal(t, 24*time.Hour, service.jwtExpiration)
}

func TestRegister(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	service, err := NewService(db, "test-secret", "24h")
	require.NoError(t, err)

	t.Run("successful registration", func(t *testing.T) {
		req := &RegisterRequest{
			Email:    "test@example.com",
			Password: "password123",
			FullName: "Test User",
		}

		response, err := service.Register(req)
		require.NoError(t, err)
		assert.NotNil(t, response)
		assert.NotEmpty(t, response.Token)
		assert.Equal(t, req.Email, response.User.Email)
		assert.Equal(t, req.FullName, response.User.FullName)
		assert.NotEmpty(t, response.User.ID)

		// Verify password is hashed
		assert.NotEqual(t, req.Password, response.User.PasswordHash)

		// Verify password hash is valid bcrypt
		err = bcrypt.CompareHashAndPassword([]byte(response.User.PasswordHash), []byte(req.Password))
		assert.NoError(t, err)
	})

	t.Run("duplicate email", func(t *testing.T) {
		req := &RegisterRequest{
			Email:    "duplicate@example.com",
			Password: "password123",
			FullName: "Test User",
		}

		// First registration
		_, err := service.Register(req)
		require.NoError(t, err)

		// Second registration with same email
		_, err = service.Register(req)
		assert.ErrorIs(t, err, ErrEmailAlreadyExists)
	})
}

func TestLogin(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	service, err := NewService(db, "test-secret", "24h")
	require.NoError(t, err)

	// Create a test user
	registerReq := &RegisterRequest{
		Email:    "login@example.com",
		Password: "password123",
		FullName: "Login Test User",
	}
	_, err = service.Register(registerReq)
	require.NoError(t, err)

	t.Run("successful login", func(t *testing.T) {
		loginReq := &LoginRequest{
			Email:    "login@example.com",
			Password: "password123",
		}

		response, err := service.Login(loginReq)
		require.NoError(t, err)
		assert.NotNil(t, response)
		assert.NotEmpty(t, response.Token)
		assert.Equal(t, loginReq.Email, response.User.Email)
	})

	t.Run("invalid email", func(t *testing.T) {
		loginReq := &LoginRequest{
			Email:    "nonexistent@example.com",
			Password: "password123",
		}

		_, err := service.Login(loginReq)
		assert.ErrorIs(t, err, ErrInvalidCredentials)
	})

	t.Run("invalid password", func(t *testing.T) {
		loginReq := &LoginRequest{
			Email:    "login@example.com",
			Password: "wrongpassword",
		}

		_, err := service.Login(loginReq)
		assert.ErrorIs(t, err, ErrInvalidCredentials)
	})
}

func TestGenerateToken(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	service, err := NewService(db, "test-secret", "24h")
	require.NoError(t, err)

	user := &database.User{
		ID:       uuid.New(),
		Email:    "token@example.com",
		FullName: "Token Test User",
	}

	token, err := service.generateToken(user)
	require.NoError(t, err)
	assert.NotEmpty(t, token)
}

func TestValidateToken(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	service, err := NewService(db, "test-secret", "24h")
	require.NoError(t, err)

	user := &database.User{
		ID:       uuid.New(),
		Email:    "validate@example.com",
		FullName: "Validate Test User",
	}

	t.Run("valid token", func(t *testing.T) {
		token, err := service.generateToken(user)
		require.NoError(t, err)

		claims, err := service.ValidateToken(token)
		require.NoError(t, err)
		assert.Equal(t, user.ID, claims.UserID)
		assert.Equal(t, user.Email, claims.Email)
	})

	t.Run("invalid token", func(t *testing.T) {
		_, err := service.ValidateToken("invalid.token.here")
		assert.Error(t, err)
	})

	t.Run("expired token", func(t *testing.T) {
		// Create service with very short expiration
		shortService, err := NewService(db, "test-secret", "1ns")
		require.NoError(t, err)

		token, err := shortService.generateToken(user)
		require.NoError(t, err)

		// Wait for token to expire
		time.Sleep(10 * time.Millisecond)

		_, err = shortService.ValidateToken(token)
		assert.Error(t, err)
	})
}

func TestGetUserByID(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	service, err := NewService(db, "test-secret", "24h")
	require.NoError(t, err)

	// Create a test user
	registerReq := &RegisterRequest{
		Email:    "getuser@example.com",
		Password: "password123",
		FullName: "Get User Test",
	}
	response, err := service.Register(registerReq)
	require.NoError(t, err)

	t.Run("existing user", func(t *testing.T) {
		user, err := service.GetUserByID(response.User.ID)
		require.NoError(t, err)
		assert.Equal(t, response.User.ID, user.ID)
		assert.Equal(t, response.User.Email, user.Email)
	})

	t.Run("non-existent user", func(t *testing.T) {
		_, err := service.GetUserByID(uuid.New())
		assert.ErrorIs(t, err, ErrUserNotFound)
	})
}

// Property-based test: Password hashing consistency
func TestPasswordHashingConsistency(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	service, err := NewService(db, "test-secret", "24h")
	require.NoError(t, err)

	testCases := []struct {
		password string
	}{
		{"password123"},
		{"VeryLongPasswordWithSpecialChars!@#$%^&*()"},
		{"short"},
		{"12345678"},
		{"P@ssw0rd!"},
	}

	for _, tc := range testCases {
		t.Run("password_"+tc.password, func(t *testing.T) {
			// Register user
			req := &RegisterRequest{
				Email:    "hash_" + uuid.New().String() + "@example.com",
				Password: tc.password,
				FullName: "Hash Test User",
			}

			response, err := service.Register(req)
			require.NoError(t, err)

			// Property: Password should be hashed (not equal to original)
			assert.NotEqual(t, tc.password, response.User.PasswordHash)

			// Property: Hash should be verifiable with bcrypt
			err = bcrypt.CompareHashAndPassword([]byte(response.User.PasswordHash), []byte(tc.password))
			assert.NoError(t, err, "Password hash should be verifiable")

			// Property: Login with correct password should succeed
			loginReq := &LoginRequest{
				Email:    req.Email,
				Password: tc.password,
			}
			loginResponse, err := service.Login(loginReq)
			require.NoError(t, err)
			assert.Equal(t, response.User.ID, loginResponse.User.ID)

			// Property: Login with incorrect password should fail
			wrongLoginReq := &LoginRequest{
				Email:    req.Email,
				Password: tc.password + "wrong",
			}
			_, err = service.Login(wrongLoginReq)
			assert.ErrorIs(t, err, ErrInvalidCredentials)
		})
	}
}
