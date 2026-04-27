package diary

import (
	"errors"
	"nutribunda-backend/internal/database"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrDiaryEntryNotFound = errors.New("diary entry not found")
	ErrUnauthorized       = errors.New("unauthorized access to diary entry")
	ErrInvalidProfileType = errors.New("invalid profile type, must be 'baby' or 'mother'")
	ErrInvalidMealTime    = errors.New("invalid meal time, must be 'breakfast', 'lunch', 'dinner', or 'snack'")
	ErrFoodNotFound       = errors.New("food not found")
	ErrConflict           = errors.New("sync conflict detected")
)

// Service handles diary operations
type Service struct {
	db *gorm.DB
}

// NewService creates a new diary service
func NewService(db *gorm.DB) *Service {
	return &Service{
		db: db,
	}
}

// CreateEntryRequest represents a request to create a diary entry
type CreateEntryRequest struct {
	ProfileType    string     `json:"profile_type" binding:"required"`
	FoodID         *uuid.UUID `json:"food_id"`
	CustomFoodName *string    `json:"custom_food_name"`
	ServingSize    float64    `json:"serving_size" binding:"required,gt=0"`
	MealTime       string     `json:"meal_time" binding:"required"`
	EntryDate      string     `json:"entry_date" binding:"required"` // YYYY-MM-DD format
	// Manual nutrition entry (optional, used when custom_food_name is provided)
	Calories *float64 `json:"calories"`
	Protein  *float64 `json:"protein"`
	Carbs    *float64 `json:"carbs"`
	Fat      *float64 `json:"fat"`
}

// GetEntriesRequest represents a request to get diary entries
type GetEntriesRequest struct {
	ProfileType string `form:"profile" binding:"required"`
	Date        string `form:"date" binding:"required"` // YYYY-MM-DD format
}

// NutritionSummary represents daily nutrition summary
type NutritionSummary struct {
	Calories float64 `json:"calories"`
	Protein  float64 `json:"protein"`
	Carbs    float64 `json:"carbs"`
	Fat      float64 `json:"fat"`
}

// GetEntriesResponse represents the response for getting diary entries
type GetEntriesResponse struct {
	Entries          []database.DiaryEntry `json:"entries"`
	NutritionSummary NutritionSummary      `json:"nutrition_summary"`
}

// CreateEntry creates a new diary entry
func (s *Service) CreateEntry(userID uuid.UUID, req *CreateEntryRequest) (*database.DiaryEntry, error) {
	// Validate profile type
	if req.ProfileType != "baby" && req.ProfileType != "mother" {
		return nil, ErrInvalidProfileType
	}

	// Validate meal time
	validMealTimes := map[string]bool{
		"breakfast": true,
		"lunch":     true,
		"dinner":    true,
		"snack":     true,
	}
	if !validMealTimes[req.MealTime] {
		return nil, ErrInvalidMealTime
	}

	// Parse entry date
	entryDate, err := time.Parse("2006-01-02", req.EntryDate)
	if err != nil {
		return nil, errors.New("invalid date format, expected YYYY-MM-DD")
	}

	// Create diary entry
	entry := &database.DiaryEntry{
		UserID:         userID,
		ProfileType:    req.ProfileType,
		FoodID:         req.FoodID,
		CustomFoodName: req.CustomFoodName,
		ServingSize:    req.ServingSize,
		MealTime:       req.MealTime,
		EntryDate:      entryDate,
	}

	// Calculate nutrition based on food_id or manual entry
	if req.FoodID != nil {
		// Get food from database
		var food database.Food
		if err := s.db.Where("id = ?", req.FoodID).First(&food).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return nil, ErrFoodNotFound
			}
			return nil, err
		}

		// Calculate nutrition based on serving size
		// Nutrition per 100g * serving_size / 100
		entry.Calories = food.CaloriesPer100g * req.ServingSize / 100
		entry.Protein = food.ProteinPer100g * req.ServingSize / 100
		entry.Carbs = food.CarbsPer100g * req.ServingSize / 100
		entry.Fat = food.FatPer100g * req.ServingSize / 100
	} else if req.CustomFoodName != nil {
		// Manual entry - use provided nutrition values
		if req.Calories == nil || req.Protein == nil || req.Carbs == nil || req.Fat == nil {
			return nil, errors.New("nutrition values are required for manual entry")
		}
		entry.Calories = *req.Calories
		entry.Protein = *req.Protein
		entry.Carbs = *req.Carbs
		entry.Fat = *req.Fat
	} else {
		return nil, errors.New("either food_id or custom_food_name must be provided")
	}

	// Save to database
	if err := s.db.Create(entry).Error; err != nil {
		return nil, err
	}

	// Preload food if food_id is provided
	if entry.FoodID != nil {
		s.db.Preload("Food").First(entry, entry.ID)
	}

	return entry, nil
}

// GetEntries retrieves diary entries for a specific profile and date
func (s *Service) GetEntries(userID uuid.UUID, req *GetEntriesRequest) (*GetEntriesResponse, error) {
	// Validate profile type
	if req.ProfileType != "baby" && req.ProfileType != "mother" {
		return nil, ErrInvalidProfileType
	}

	// Parse date
	entryDate, err := time.Parse("2006-01-02", req.Date)
	if err != nil {
		return nil, errors.New("invalid date format, expected YYYY-MM-DD")
	}

	// Query entries
	var entries []database.DiaryEntry
	if err := s.db.
		Preload("Food").
		Where("user_id = ? AND profile_type = ? AND entry_date = ?", userID, req.ProfileType, entryDate).
		Order("created_at ASC").
		Find(&entries).Error; err != nil {
		return nil, err
	}

	// Calculate nutrition summary
	summary := s.CalculateNutritionSummary(entries)

	return &GetEntriesResponse{
		Entries:          entries,
		NutritionSummary: summary,
	}, nil
}

// DeleteEntry deletes a diary entry
func (s *Service) DeleteEntry(userID uuid.UUID, entryID uuid.UUID) error {
	// First, check if the entry exists and belongs to the user
	var entry database.DiaryEntry
	if err := s.db.Where("id = ?", entryID).First(&entry).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return ErrDiaryEntryNotFound
		}
		return err
	}

	// Check if the entry belongs to the user
	if entry.UserID != userID {
		return ErrUnauthorized
	}

	// Delete the entry
	if err := s.db.Delete(&entry).Error; err != nil {
		return err
	}

	return nil
}

// CalculateNutritionSummary calculates the total nutrition for a list of entries
func (s *Service) CalculateNutritionSummary(entries []database.DiaryEntry) NutritionSummary {
	summary := NutritionSummary{}

	for _, entry := range entries {
		summary.Calories += entry.Calories
		summary.Protein += entry.Protein
		summary.Carbs += entry.Carbs
		summary.Fat += entry.Fat
	}

	return summary
}

// SyncRequest represents a request to sync diary entries
type SyncRequest struct {
	LastSyncTime string                  `json:"last_sync_time"` // RFC3339 format
	Entries      []SyncDiaryEntry        `json:"entries"`        // Entries to upload from client
	DeletedIDs   []uuid.UUID             `json:"deleted_ids"`    // IDs deleted on client
}

// SyncDiaryEntry represents a diary entry for sync
type SyncDiaryEntry struct {
	ID             uuid.UUID  `json:"id"`
	ProfileType    string     `json:"profile_type"`
	FoodID         *uuid.UUID `json:"food_id"`
	CustomFoodName *string    `json:"custom_food_name"`
	ServingSize    float64    `json:"serving_size"`
	MealTime       string     `json:"meal_time"`
	Calories       float64    `json:"calories"`
	Protein        float64    `json:"protein"`
	Carbs          float64    `json:"carbs"`
	Fat            float64    `json:"fat"`
	EntryDate      string     `json:"entry_date"` // YYYY-MM-DD format
	UpdatedAt      string     `json:"updated_at"` // RFC3339 format
}

// SyncResponse represents the response for sync operation
type SyncResponse struct {
	Entries    []database.DiaryEntry `json:"entries"`     // New/updated entries from server
	DeletedIDs []uuid.UUID           `json:"deleted_ids"` // IDs deleted on server
	Conflicts  []SyncConflict        `json:"conflicts"`   // Conflicts that need resolution
}

// SyncConflict represents a sync conflict
type SyncConflict struct {
	EntryID       uuid.UUID             `json:"entry_id"`
	ClientEntry   SyncDiaryEntry        `json:"client_entry"`
	ServerEntry   database.DiaryEntry   `json:"server_entry"`
	ConflictType  string                `json:"conflict_type"` // "update_conflict", "delete_conflict"
}

// SyncDiaryEntries synchronizes diary entries between client and server
func (s *Service) SyncDiaryEntries(userID uuid.UUID, req *SyncRequest) (*SyncResponse, error) {
	response := &SyncResponse{
		Entries:    []database.DiaryEntry{},
		DeletedIDs: []uuid.UUID{},
		Conflicts:  []SyncConflict{},
	}

	// Parse last sync time
	var lastSyncTime time.Time
	var err error
	if req.LastSyncTime != "" {
		lastSyncTime, err = time.Parse(time.RFC3339, req.LastSyncTime)
		if err != nil {
			return nil, errors.New("invalid last_sync_time format, expected RFC3339")
		}
	}

	// Step 1: Process client deletions
	for _, deletedID := range req.DeletedIDs {
		// Check if entry exists on server
		var serverEntry database.DiaryEntry
		err := s.db.Unscoped().Where("id = ? AND user_id = ?", deletedID, userID).First(&serverEntry).Error
		
		if err == nil {
			// Entry exists on server
			if serverEntry.DeletedAt != nil {
				// Already deleted on server, skip
				continue
			}
			
			// Check if server entry was updated after client's last sync
			if serverEntry.UpdatedAt.After(lastSyncTime) {
				// Conflict: server has newer version
				response.Conflicts = append(response.Conflicts, SyncConflict{
					EntryID:      deletedID,
					ServerEntry:  serverEntry,
					ConflictType: "delete_conflict",
				})
				continue
			}
			
			// Safe to delete - soft delete
			now := time.Now()
			serverEntry.DeletedAt = &now
			s.db.Save(&serverEntry)
		}
	}

	// Step 2: Process client entries (create or update)
	for _, clientEntry := range req.Entries {
		// Parse entry date
		entryDate, err := time.Parse("2006-01-02", clientEntry.EntryDate)
		if err != nil {
			return nil, errors.New("invalid entry_date format in sync entry")
		}

		// Parse client updated_at
		clientUpdatedAt, err := time.Parse(time.RFC3339, clientEntry.UpdatedAt)
		if err != nil {
			return nil, errors.New("invalid updated_at format in sync entry")
		}

		// Check if entry exists on server
		var serverEntry database.DiaryEntry
		err = s.db.Unscoped().Where("id = ? AND user_id = ?", clientEntry.ID, userID).First(&serverEntry).Error

		if errors.Is(err, gorm.ErrRecordNotFound) {
			// Entry doesn't exist on server - create new
			newEntry := database.DiaryEntry{
				ID:             clientEntry.ID,
				UserID:         userID,
				ProfileType:    clientEntry.ProfileType,
				FoodID:         clientEntry.FoodID,
				CustomFoodName: clientEntry.CustomFoodName,
				ServingSize:    clientEntry.ServingSize,
				MealTime:       clientEntry.MealTime,
				Calories:       clientEntry.Calories,
				Protein:        clientEntry.Protein,
				Carbs:          clientEntry.Carbs,
				Fat:            clientEntry.Fat,
				EntryDate:      entryDate,
				UpdatedAt:      clientUpdatedAt,
			}
			
			if err := s.db.Create(&newEntry).Error; err != nil {
				return nil, err
			}
		} else if err == nil {
			// Entry exists on server - check for conflicts
			if serverEntry.UpdatedAt.After(clientUpdatedAt) {
				// Server has newer version - conflict
				response.Conflicts = append(response.Conflicts, SyncConflict{
					EntryID:      clientEntry.ID,
					ClientEntry:  clientEntry,
					ServerEntry:  serverEntry,
					ConflictType: "update_conflict",
				})
				continue
			}

			// Client has newer or same version - update server
			serverEntry.ProfileType = clientEntry.ProfileType
			serverEntry.FoodID = clientEntry.FoodID
			serverEntry.CustomFoodName = clientEntry.CustomFoodName
			serverEntry.ServingSize = clientEntry.ServingSize
			serverEntry.MealTime = clientEntry.MealTime
			serverEntry.Calories = clientEntry.Calories
			serverEntry.Protein = clientEntry.Protein
			serverEntry.Carbs = clientEntry.Carbs
			serverEntry.Fat = clientEntry.Fat
			serverEntry.EntryDate = entryDate
			serverEntry.UpdatedAt = clientUpdatedAt
			serverEntry.DeletedAt = nil // Restore if was soft deleted

			if err := s.db.Unscoped().Save(&serverEntry).Error; err != nil {
				return nil, err
			}
		} else {
			return nil, err
		}
	}

	// Step 3: Get all entries modified on server since last sync
	var serverEntries []database.DiaryEntry
	query := s.db.Where("user_id = ?", userID)
	
	if !lastSyncTime.IsZero() {
		query = query.Where("updated_at > ?", lastSyncTime)
	}
	
	if err := query.Preload("Food").Find(&serverEntries).Error; err != nil {
		return nil, err
	}
	response.Entries = serverEntries

	// Step 4: Get all entries deleted on server since last sync
	var deletedEntries []database.DiaryEntry
	deletedQuery := s.db.Unscoped().
		Where("user_id = ? AND deleted_at IS NOT NULL", userID)
	
	if !lastSyncTime.IsZero() {
		deletedQuery = deletedQuery.Where("deleted_at > ?", lastSyncTime)
	}
	
	if err := deletedQuery.Find(&deletedEntries).Error; err != nil {
		return nil, err
	}
	
	for _, entry := range deletedEntries {
		response.DeletedIDs = append(response.DeletedIDs, entry.ID)
	}

	return response, nil
}

// ResolveConflictRequest represents a request to resolve a sync conflict
type ResolveConflictRequest struct {
	EntryID    uuid.UUID `json:"entry_id" binding:"required"`
	Resolution string    `json:"resolution" binding:"required"` // "use_client", "use_server"
	Entry      *SyncDiaryEntry `json:"entry"` // Required if resolution is "use_client"
}

// ResolveConflict resolves a sync conflict
func (s *Service) ResolveConflict(userID uuid.UUID, req *ResolveConflictRequest) (*database.DiaryEntry, error) {
	// Validate resolution type
	if req.Resolution != "use_client" && req.Resolution != "use_server" {
		return nil, errors.New("invalid resolution, must be 'use_client' or 'use_server'")
	}

	// Get server entry
	var serverEntry database.DiaryEntry
	if err := s.db.Where("id = ? AND user_id = ?", req.EntryID, userID).First(&serverEntry).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrDiaryEntryNotFound
		}
		return nil, err
	}

	if req.Resolution == "use_server" {
		// Keep server version - just return it
		if serverEntry.FoodID != nil {
			s.db.Preload("Food").First(&serverEntry, serverEntry.ID)
		}
		return &serverEntry, nil
	}

	// Use client version - update server
	if req.Entry == nil {
		return nil, errors.New("entry data required when resolution is 'use_client'")
	}

	entryDate, err := time.Parse("2006-01-02", req.Entry.EntryDate)
	if err != nil {
		return nil, errors.New("invalid entry_date format")
	}

	serverEntry.ProfileType = req.Entry.ProfileType
	serverEntry.FoodID = req.Entry.FoodID
	serverEntry.CustomFoodName = req.Entry.CustomFoodName
	serverEntry.ServingSize = req.Entry.ServingSize
	serverEntry.MealTime = req.Entry.MealTime
	serverEntry.Calories = req.Entry.Calories
	serverEntry.Protein = req.Entry.Protein
	serverEntry.Carbs = req.Entry.Carbs
	serverEntry.Fat = req.Entry.Fat
	serverEntry.EntryDate = entryDate
	serverEntry.UpdatedAt = time.Now()

	if err := s.db.Save(&serverEntry).Error; err != nil {
		return nil, err
	}

	if serverEntry.FoodID != nil {
		s.db.Preload("Food").First(&serverEntry, serverEntry.ID)
	}

	return &serverEntry, nil
}
