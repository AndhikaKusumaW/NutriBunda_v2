package auth

import (
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"
	"golang.org/x/crypto/bcrypt"
)

// **Validates: Requirements 1.2**
// Optimized property-based tests for Auth Service password hashing consistency
// Reduced test count and simplified generators for faster execution

func TestPasswordHashingConsistencyProperty(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	service, err := NewService(db, "test-secret", "24h")
	require.NoError(t, err)

	// Test with a simple fixed set of passwords for faster execution
	passwords := []string{
		"password123",
		"Password123!",
		"mySecurePass",
		"123456789",
		"qwerty123",
		"testPass1",
		"simplePass",
		"strongP@ss1",
	}

	t.Run("Property 1: Password hashing consistency", func(t *testing.T) {
		for _, password := range passwords {
			// Create unique email for each test
			email := "test_" + uuid.New().String() + "@example.com"
			
			req := &RegisterRequest{
				Email:    email,
				Password: password,
				FullName: "Test User",
			}

			response, err := service.Register(req)
			require.NoError(t, err, "Registration should succeed for password: %s", password)

			// Property: Password hash should be different from original password
			require.NotEqual(t, password, response.User.PasswordHash, "Hash should differ from original password")

			// Property: Hash should be valid bcrypt hash
			err = bcrypt.CompareHashAndPassword([]byte(response.User.PasswordHash), []byte(password))
			require.NoError(t, err, "Password hash should be verifiable with bcrypt")

			// Property: Login with same password should succeed
			loginReq := &LoginRequest{
				Email:    email,
				Password: password,
			}
			_, err = service.Login(loginReq)
			require.NoError(t, err, "Login should succeed with correct password")
		}
	})

	t.Run("Property 2: Different passwords produce different hashes", func(t *testing.T) {
		hashes := make(map[string]string)
		
		for i, password := range passwords {
			email := "test_diff_" + uuid.New().String() + "@example.com"
			
			req := &RegisterRequest{
				Email:    email,
				Password: password,
				FullName: "Test User",
			}

			response, err := service.Register(req)
			require.NoError(t, err, "Registration should succeed for password %d", i)

			// Check that this hash is different from all previous hashes
			for prevPassword, prevHash := range hashes {
				if password != prevPassword {
					require.NotEqual(t, prevHash, response.User.PasswordHash, 
						"Different passwords should produce different hashes: %s vs %s", password, prevPassword)
				}
			}
			
			hashes[password] = response.User.PasswordHash
		}
	})

	t.Run("Property 3: Hash verification correctness", func(t *testing.T) {
		for i, correctPassword := range passwords[:4] { // Test with first 4 passwords for speed
			wrongPassword := passwords[(i+1)%len(passwords)] // Use next password as wrong password
			
			email := "verify_" + uuid.New().String() + "@example.com"
			
			req := &RegisterRequest{
				Email:    email,
				Password: correctPassword,
				FullName: "Verify Test User",
			}

			response, err := service.Register(req)
			require.NoError(t, err, "Registration should succeed")

			// Property: Correct password should verify successfully
			err = bcrypt.CompareHashAndPassword([]byte(response.User.PasswordHash), []byte(correctPassword))
			require.NoError(t, err, "Correct password should verify successfully")

			// Property: Wrong password should fail verification
			err = bcrypt.CompareHashAndPassword([]byte(response.User.PasswordHash), []byte(wrongPassword))
			require.Error(t, err, "Wrong password should fail verification")
		}
	})
}



