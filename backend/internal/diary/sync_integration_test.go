// +build integration

package diary

import (
	"nutribunda-backend/configs"
	"nutribunda-backend/internal/database"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/gorm"
)

// Run with: go test -tags=integration -v ./internal/diary

func setupIntegrationDB(t *testing.T) (*gorm.DB, func()) {
	// Load test configuration
	config := configs.LoadConfig()
	
	// Connect to test database
	db, err := database.InitDB(config)
	require.NoError(t, err)

	// Run migrations
	err = database.RunMigrations(db)
	require.NoError(t, err)

	// Cleanup function
	cleanup := func() {
		// Clean up test data
		db.Exec("DELETE FROM diary_entries WHERE user_id IN (SELECT id FROM users WHERE email LIKE 'test-sync-%')")
		db.Exec("DELETE FROM users WHERE email LIKE 'test-sync-%'")
	}

	return db, cleanup
}

func TestSyncIntegration_FullWorkflow(t *testing.T) {
	db, cleanup := setupIntegrationDB(t)
	defer cleanup()

	service := NewService(db)

	// Create test user
	user := database.User{
		ID:       uuid.New(),
		Email:    "test-sync-" + uuid.New().String() + "@example.com",
		FullName: "Test Sync User",
	}
	db.Create(&user)

	// Step 1: Client creates entry offline
	clientEntry := SyncDiaryEntry{
		ID:          uuid.New(),
		ProfileType: "baby",
		ServingSize: 100,
		MealTime:    "breakfast",
		Calories:    150,
		Protein:     5,
		Carbs:       20,
		Fat:         3,
		EntryDate:   "2024-01-15",
		UpdatedAt:   time.Now().Format(time.RFC3339),
	}

	// Step 2: First sync - upload client entry
	syncReq := &SyncRequest{
		LastSyncTime: "",
		Entries:      []SyncDiaryEntry{clientEntry},
		DeletedIDs:   []uuid.UUID{},
	}

	response, err := service.SyncDiaryEntries(user.ID, syncReq)
	require.NoError(t, err)
	assert.Empty(t, response.Conflicts)

	// Verify entry exists on server
	var serverEntry database.DiaryEntry
	err = db.Where("id = ?", clientEntry.ID).First(&serverEntry).Error
	require.NoError(t, err)

	// Step 3: Simulate server-side update
	time.Sleep(1 * time.Second) // Ensure different timestamp
	serverEntry.Calories = 200
	serverEntry.UpdatedAt = time.Now()
	db.Save(&serverEntry)

	// Step 4: Client tries to update with older version - should get conflict
	clientEntry.Calories = 180
	clientEntry.UpdatedAt = time.Now().Add(-30 * time.Minute).Format(time.RFC3339)

	syncReq2 := &SyncRequest{
		LastSyncTime: time.Now().Add(-1 * time.Hour).Format(time.RFC3339),
		Entries:      []SyncDiaryEntry{clientEntry},
		DeletedIDs:   []uuid.UUID{},
	}

	response2, err := service.SyncDiaryEntries(user.ID, syncReq2)
	require.NoError(t, err)
	assert.Len(t, response2.Conflicts, 1)
	assert.Equal(t, "update_conflict", response2.Conflicts[0].ConflictType)

	// Step 5: Resolve conflict - use server version
	resolveReq := &ResolveConflictRequest{
		EntryID:    clientEntry.ID,
		Resolution: "use_server",
	}

	resolved, err := service.ResolveConflict(user.ID, resolveReq)
	require.NoError(t, err)
	assert.Equal(t, 200.0, resolved.Calories)
}

func TestSyncIntegration_DeleteWorkflow(t *testing.T) {
	db, cleanup := setupIntegrationDB(t)
	defer cleanup()

	service := NewService(db)

	// Create test user
	user := database.User{
		ID:       uuid.New(),
		Email:    "test-sync-" + uuid.New().String() + "@example.com",
		FullName: "Test Sync User",
	}
	db.Create(&user)

	// Create entry on server
	entryID := uuid.New()
	serverEntry := database.DiaryEntry{
		ID:          entryID,
		UserID:      user.ID,
		ProfileType: "baby",
		ServingSize: 100,
		MealTime:    "breakfast",
		Calories:    150,
		Protein:     5,
		Carbs:       20,
		Fat:         3,
		EntryDate:   time.Date(2024, 1, 15, 0, 0, 0, 0, time.UTC),
		UpdatedAt:   time.Now().Add(-1 * time.Hour),
	}
	db.Create(&serverEntry)

	lastSyncTime := time.Now()

	// Client deletes entry
	syncReq := &SyncRequest{
		LastSyncTime: lastSyncTime.Format(time.RFC3339),
		Entries:      []SyncDiaryEntry{},
		DeletedIDs:   []uuid.UUID{entryID},
	}

	response, err := service.SyncDiaryEntries(user.ID, syncReq)
	require.NoError(t, err)
	assert.Empty(t, response.Conflicts)

	// Verify entry was soft deleted
	var deletedEntry database.DiaryEntry
	err = db.Unscoped().Where("id = ?", entryID).First(&deletedEntry).Error
	require.NoError(t, err)
	assert.NotNil(t, deletedEntry.DeletedAt)

	// Verify deleted entry is returned in next sync
	syncReq2 := &SyncRequest{
		LastSyncTime: lastSyncTime.Format(time.RFC3339),
		Entries:      []SyncDiaryEntry{},
		DeletedIDs:   []uuid.UUID{},
	}

	response2, err := service.SyncDiaryEntries(user.ID, syncReq2)
	require.NoError(t, err)
	assert.Contains(t, response2.DeletedIDs, entryID)
}
