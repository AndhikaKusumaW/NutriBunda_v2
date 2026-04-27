package diary

import (
	"nutribunda-backend/internal/database"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func setupTestDBForSync(t *testing.T) (*gorm.DB, func()) {
	// Create in-memory SQLite database
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	require.NoError(t, err)

	// Run migrations
	err = db.AutoMigrate(
		&database.User{},
		&database.Food{},
		&database.DiaryEntry{},
	)
	require.NoError(t, err)

	// Cleanup function
	cleanup := func() {
		sqlDB, _ := db.DB()
		sqlDB.Close()
	}

	return db, cleanup
}

func TestSyncDiaryEntries_NewEntriesFromClient(t *testing.T) {
	db, cleanup := setupTestDBForSync(t)
	defer cleanup()

	service := NewService(db)

	// Create test user
	user := database.User{
		ID:       uuid.New(),
		Email:    "test@example.com",
		FullName: "Test User",
	}
	db.Create(&user)

	// Create sync request with new entries from client
	clientEntry1 := SyncDiaryEntry{
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

	syncReq := &SyncRequest{
		LastSyncTime: "",
		Entries:      []SyncDiaryEntry{clientEntry1},
		DeletedIDs:   []uuid.UUID{},
	}

	// Perform sync
	response, err := service.SyncDiaryEntries(user.ID, syncReq)
	require.NoError(t, err)
	assert.NotNil(t, response)
	assert.Empty(t, response.Conflicts)

	// Verify entry was created on server
	var serverEntry database.DiaryEntry
	err = db.Where("id = ?", clientEntry1.ID).First(&serverEntry).Error
	require.NoError(t, err)
	assert.Equal(t, clientEntry1.ProfileType, serverEntry.ProfileType)
	assert.Equal(t, clientEntry1.Calories, serverEntry.Calories)
}

func TestSyncDiaryEntries_UpdateConflict(t *testing.T) {
	db, cleanup := setupTestDBForSync(t)
	defer cleanup()

	service := NewService(db)

	// Create test user
	user := database.User{
		ID:       uuid.New(),
		Email:    "test@example.com",
		FullName: "Test User",
	}
	db.Create(&user)

	// Create existing entry on server with recent update
	entryID := uuid.New()
	serverTime := time.Now()
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
		UpdatedAt:   serverTime,
	}
	db.Create(&serverEntry)

	// Client tries to sync older version
	clientTime := serverTime.Add(-1 * time.Hour)
	clientEntry := SyncDiaryEntry{
		ID:          entryID,
		ProfileType: "baby",
		ServingSize: 120, // Different value
		MealTime:    "breakfast",
		Calories:    180, // Different value
		Protein:     6,
		Carbs:       22,
		Fat:         4,
		EntryDate:   "2024-01-15",
		UpdatedAt:   clientTime.Format(time.RFC3339),
	}

	syncReq := &SyncRequest{
		LastSyncTime: clientTime.Add(-24 * time.Hour).Format(time.RFC3339),
		Entries:      []SyncDiaryEntry{clientEntry},
		DeletedIDs:   []uuid.UUID{},
	}

	// Perform sync
	response, err := service.SyncDiaryEntries(user.ID, syncReq)
	require.NoError(t, err)
	assert.NotNil(t, response)
	assert.Len(t, response.Conflicts, 1)
	assert.Equal(t, "update_conflict", response.Conflicts[0].ConflictType)
	assert.Equal(t, entryID, response.Conflicts[0].EntryID)
}

func TestSyncDiaryEntries_ClientHasNewerVersion(t *testing.T) {
	db, cleanup := setupTestDBForSync(t)
	defer cleanup()

	service := NewService(db)

	// Create test user
	user := database.User{
		ID:       uuid.New(),
		Email:    "test@example.com",
		FullName: "Test User",
	}
	db.Create(&user)

	// Create existing entry on server with older update
	entryID := uuid.New()
	serverTime := time.Now().Add(-2 * time.Hour)
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
		UpdatedAt:   serverTime,
	}
	db.Create(&serverEntry)

	// Client has newer version
	clientTime := time.Now()
	clientEntry := SyncDiaryEntry{
		ID:          entryID,
		ProfileType: "baby",
		ServingSize: 120, // Updated value
		MealTime:    "breakfast",
		Calories:    180, // Updated value
		Protein:     6,
		Carbs:       22,
		Fat:         4,
		EntryDate:   "2024-01-15",
		UpdatedAt:   clientTime.Format(time.RFC3339),
	}

	syncReq := &SyncRequest{
		LastSyncTime: serverTime.Add(-1 * time.Hour).Format(time.RFC3339),
		Entries:      []SyncDiaryEntry{clientEntry},
		DeletedIDs:   []uuid.UUID{},
	}

	// Perform sync
	response, err := service.SyncDiaryEntries(user.ID, syncReq)
	require.NoError(t, err)
	assert.NotNil(t, response)
	assert.Empty(t, response.Conflicts)

	// Verify server entry was updated
	var updatedEntry database.DiaryEntry
	err = db.Where("id = ?", entryID).First(&updatedEntry).Error
	require.NoError(t, err)
	assert.Equal(t, clientEntry.ServingSize, updatedEntry.ServingSize)
	assert.Equal(t, clientEntry.Calories, updatedEntry.Calories)
}

func TestSyncDiaryEntries_DeleteConflict(t *testing.T) {
	db, cleanup := setupTestDBForSync(t)
	defer cleanup()

	service := NewService(db)

	// Create test user
	user := database.User{
		ID:       uuid.New(),
		Email:    "test@example.com",
		FullName: "Test User",
	}
	db.Create(&user)

	// Create existing entry on server with recent update
	entryID := uuid.New()
	serverTime := time.Now()
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
		UpdatedAt:   serverTime,
	}
	db.Create(&serverEntry)

	// Client tries to delete entry but server has newer version
	lastSyncTime := serverTime.Add(-1 * time.Hour)
	syncReq := &SyncRequest{
		LastSyncTime: lastSyncTime.Format(time.RFC3339),
		Entries:      []SyncDiaryEntry{},
		DeletedIDs:   []uuid.UUID{entryID},
	}

	// Perform sync
	response, err := service.SyncDiaryEntries(user.ID, syncReq)
	require.NoError(t, err)
	assert.NotNil(t, response)
	assert.Len(t, response.Conflicts, 1)
	assert.Equal(t, "delete_conflict", response.Conflicts[0].ConflictType)
	assert.Equal(t, entryID, response.Conflicts[0].EntryID)
}

func TestSyncDiaryEntries_SafeDelete(t *testing.T) {
	db, cleanup := setupTestDBForSync(t)
	defer cleanup()

	service := NewService(db)

	// Create test user
	user := database.User{
		ID:       uuid.New(),
		Email:    "test@example.com",
		FullName: "Test User",
	}
	db.Create(&user)

	// Create existing entry on server with older update
	entryID := uuid.New()
	serverTime := time.Now().Add(-2 * time.Hour)
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
		UpdatedAt:   serverTime,
	}
	db.Create(&serverEntry)

	// Client deletes entry after last sync
	lastSyncTime := serverTime.Add(1 * time.Hour)
	syncReq := &SyncRequest{
		LastSyncTime: lastSyncTime.Format(time.RFC3339),
		Entries:      []SyncDiaryEntry{},
		DeletedIDs:   []uuid.UUID{entryID},
	}

	// Perform sync
	response, err := service.SyncDiaryEntries(user.ID, syncReq)
	require.NoError(t, err)
	assert.NotNil(t, response)
	assert.Empty(t, response.Conflicts)

	// Verify entry was soft deleted
	var deletedEntry database.DiaryEntry
	err = db.Unscoped().Where("id = ?", entryID).First(&deletedEntry).Error
	require.NoError(t, err)
	assert.NotNil(t, deletedEntry.DeletedAt)
}

func TestSyncDiaryEntries_GetServerChanges(t *testing.T) {
	db, cleanup := setupTestDBForSync(t)
	defer cleanup()

	service := NewService(db)

	// Create test user
	user := database.User{
		ID:       uuid.New(),
		Email:    "test@example.com",
		FullName: "Test User",
	}
	db.Create(&user)

	// Create entries on server
	lastSyncTime := time.Now().Add(-1 * time.Hour)
	
	// Entry created before last sync (should not be returned)
	oldEntry := database.DiaryEntry{
		ID:          uuid.New(),
		UserID:      user.ID,
		ProfileType: "baby",
		ServingSize: 100,
		MealTime:    "breakfast",
		Calories:    150,
		Protein:     5,
		Carbs:       20,
		Fat:         3,
		EntryDate:   time.Date(2024, 1, 15, 0, 0, 0, 0, time.UTC),
		UpdatedAt:   lastSyncTime.Add(-30 * time.Minute),
	}
	db.Create(&oldEntry)

	// Entry created after last sync (should be returned)
	newEntry := database.DiaryEntry{
		ID:          uuid.New(),
		UserID:      user.ID,
		ProfileType: "mother",
		ServingSize: 200,
		MealTime:    "lunch",
		Calories:    300,
		Protein:     10,
		Carbs:       40,
		Fat:         8,
		EntryDate:   time.Date(2024, 1, 15, 0, 0, 0, 0, time.UTC),
		UpdatedAt:   lastSyncTime.Add(30 * time.Minute),
	}
	db.Create(&newEntry)

	// Perform sync
	syncReq := &SyncRequest{
		LastSyncTime: lastSyncTime.Format(time.RFC3339),
		Entries:      []SyncDiaryEntry{},
		DeletedIDs:   []uuid.UUID{},
	}

	response, err := service.SyncDiaryEntries(user.ID, syncReq)
	require.NoError(t, err)
	assert.NotNil(t, response)
	assert.Len(t, response.Entries, 1)
	assert.Equal(t, newEntry.ID, response.Entries[0].ID)
}

func TestResolveConflict_UseServer(t *testing.T) {
	db, cleanup := setupTestDBForSync(t)
	defer cleanup()

	service := NewService(db)

	// Create test user
	user := database.User{
		ID:       uuid.New(),
		Email:    "test@example.com",
		FullName: "Test User",
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
	}
	db.Create(&serverEntry)

	// Resolve conflict - use server version
	req := &ResolveConflictRequest{
		EntryID:    entryID,
		Resolution: "use_server",
	}

	result, err := service.ResolveConflict(user.ID, req)
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, serverEntry.Calories, result.Calories)
}

func TestResolveConflict_UseClient(t *testing.T) {
	db, cleanup := setupTestDBForSync(t)
	defer cleanup()

	service := NewService(db)

	// Create test user
	user := database.User{
		ID:       uuid.New(),
		Email:    "test@example.com",
		FullName: "Test User",
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
	}
	db.Create(&serverEntry)

	// Resolve conflict - use client version
	clientEntry := &SyncDiaryEntry{
		ID:          entryID,
		ProfileType: "baby",
		ServingSize: 120,
		MealTime:    "breakfast",
		Calories:    180,
		Protein:     6,
		Carbs:       22,
		Fat:         4,
		EntryDate:   "2024-01-15",
		UpdatedAt:   time.Now().Format(time.RFC3339),
	}

	req := &ResolveConflictRequest{
		EntryID:    entryID,
		Resolution: "use_client",
		Entry:      clientEntry,
	}

	result, err := service.ResolveConflict(user.ID, req)
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, clientEntry.Calories, result.Calories)
	assert.Equal(t, clientEntry.ServingSize, result.ServingSize)

	// Verify server entry was updated
	var updatedEntry database.DiaryEntry
	err = db.Where("id = ?", entryID).First(&updatedEntry).Error
	require.NoError(t, err)
	assert.Equal(t, clientEntry.Calories, updatedEntry.Calories)
}

func TestResolveConflict_InvalidResolution(t *testing.T) {
	db, cleanup := setupTestDBForSync(t)
	defer cleanup()

	service := NewService(db)

	// Create test user
	user := database.User{
		ID:       uuid.New(),
		Email:    "test@example.com",
		FullName: "Test User",
	}
	db.Create(&user)

	// Try invalid resolution
	req := &ResolveConflictRequest{
		EntryID:    uuid.New(),
		Resolution: "invalid",
	}

	_, err := service.ResolveConflict(user.ID, req)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "invalid resolution")
}
