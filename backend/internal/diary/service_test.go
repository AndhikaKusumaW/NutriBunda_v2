package diary

import (
	"nutribunda-backend/internal/database"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func setupTestDB(t *testing.T) *gorm.DB {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	require.NoError(t, err)

	// Run migrations
	err = db.AutoMigrate(&database.User{}, &database.Food{}, &database.DiaryEntry{})
	require.NoError(t, err)

	return db
}

func createTestUser(t *testing.T, db *gorm.DB) uuid.UUID {
	user := database.User{
		Email:        "test@example.com",
		PasswordHash: "hashedpassword",
		FullName:     "Test User",
	}
	err := db.Create(&user).Error
	require.NoError(t, err)
	return user.ID
}

func createTestFood(t *testing.T, db *gorm.DB) uuid.UUID {
	food := database.Food{
		Name:            "Test Food",
		Category:        "mpasi",
		CaloriesPer100g: 100.0,
		ProteinPer100g:  10.0,
		CarbsPer100g:    20.0,
		FatPer100g:      5.0,
	}
	err := db.Create(&food).Error
	require.NoError(t, err)
	return food.ID
}

func TestCreateEntry_WithFoodID(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)
	foodID := createTestFood(t, db)

	req := &CreateEntryRequest{
		ProfileType: "baby",
		FoodID:      &foodID,
		ServingSize: 150.0, // 150 grams
		MealTime:    "breakfast",
		EntryDate:   "2024-01-15",
	}

	entry, err := service.CreateEntry(userID, req)

	require.NoError(t, err)
	assert.NotNil(t, entry)
	assert.Equal(t, userID, entry.UserID)
	assert.Equal(t, "baby", entry.ProfileType)
	assert.Equal(t, foodID, *entry.FoodID)
	assert.Equal(t, 150.0, entry.ServingSize)
	assert.Equal(t, "breakfast", entry.MealTime)

	// Verify nutrition calculation: 100 cal/100g * 150g / 100 = 150 cal
	assert.Equal(t, 150.0, entry.Calories)
	assert.Equal(t, 15.0, entry.Protein)  // 10g/100g * 150g / 100 = 15g
	assert.Equal(t, 30.0, entry.Carbs)    // 20g/100g * 150g / 100 = 30g
	assert.Equal(t, 7.5, entry.Fat)       // 5g/100g * 150g / 100 = 7.5g
}

func TestCreateEntry_WithCustomFood(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)

	customName := "Custom Food"
	calories := 200.0
	protein := 15.0
	carbs := 25.0
	fat := 8.0

	req := &CreateEntryRequest{
		ProfileType:    "mother",
		CustomFoodName: &customName,
		ServingSize:    100.0,
		MealTime:       "lunch",
		EntryDate:      "2024-01-15",
		Calories:       &calories,
		Protein:        &protein,
		Carbs:          &carbs,
		Fat:            &fat,
	}

	entry, err := service.CreateEntry(userID, req)

	require.NoError(t, err)
	assert.NotNil(t, entry)
	assert.Equal(t, "mother", entry.ProfileType)
	assert.Equal(t, "Custom Food", *entry.CustomFoodName)
	assert.Equal(t, 200.0, entry.Calories)
	assert.Equal(t, 15.0, entry.Protein)
	assert.Equal(t, 25.0, entry.Carbs)
	assert.Equal(t, 8.0, entry.Fat)
}

func TestCreateEntry_InvalidProfileType(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)
	foodID := createTestFood(t, db)

	req := &CreateEntryRequest{
		ProfileType: "invalid",
		FoodID:      &foodID,
		ServingSize: 100.0,
		MealTime:    "breakfast",
		EntryDate:   "2024-01-15",
	}

	_, err := service.CreateEntry(userID, req)

	assert.Error(t, err)
	assert.Equal(t, ErrInvalidProfileType, err)
}

func TestCreateEntry_InvalidMealTime(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)
	foodID := createTestFood(t, db)

	req := &CreateEntryRequest{
		ProfileType: "baby",
		FoodID:      &foodID,
		ServingSize: 100.0,
		MealTime:    "invalid",
		EntryDate:   "2024-01-15",
	}

	_, err := service.CreateEntry(userID, req)

	assert.Error(t, err)
	assert.Equal(t, ErrInvalidMealTime, err)
}

func TestCreateEntry_FoodNotFound(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)
	nonExistentFoodID := uuid.New()

	req := &CreateEntryRequest{
		ProfileType: "baby",
		FoodID:      &nonExistentFoodID,
		ServingSize: 100.0,
		MealTime:    "breakfast",
		EntryDate:   "2024-01-15",
	}

	_, err := service.CreateEntry(userID, req)

	assert.Error(t, err)
	assert.Equal(t, ErrFoodNotFound, err)
}

func TestGetEntries(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)
	foodID := createTestFood(t, db)

	// Create multiple entries for the same date
	date := "2024-01-15"
	entries := []CreateEntryRequest{
		{
			ProfileType: "baby",
			FoodID:      &foodID,
			ServingSize: 100.0,
			MealTime:    "breakfast",
			EntryDate:   date,
		},
		{
			ProfileType: "baby",
			FoodID:      &foodID,
			ServingSize: 150.0,
			MealTime:    "lunch",
			EntryDate:   date,
		},
	}

	for _, req := range entries {
		_, err := service.CreateEntry(userID, &req)
		require.NoError(t, err)
	}

	// Get entries
	getReq := &GetEntriesRequest{
		ProfileType: "baby",
		Date:        date,
	}

	response, err := service.GetEntries(userID, getReq)

	require.NoError(t, err)
	assert.Len(t, response.Entries, 2)
	
	// Verify nutrition summary
	// Entry 1: 100g * 100cal/100g = 100 cal
	// Entry 2: 150g * 100cal/100g = 150 cal
	// Total: 250 cal
	assert.Equal(t, 250.0, response.NutritionSummary.Calories)
	assert.Equal(t, 25.0, response.NutritionSummary.Protein)  // 10 + 15
	assert.Equal(t, 50.0, response.NutritionSummary.Carbs)    // 20 + 30
	assert.Equal(t, 12.5, response.NutritionSummary.Fat)      // 5 + 7.5
}

func TestGetEntries_DifferentProfiles(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)
	foodID := createTestFood(t, db)

	date := "2024-01-15"

	// Create entries for both profiles
	babyReq := &CreateEntryRequest{
		ProfileType: "baby",
		FoodID:      &foodID,
		ServingSize: 100.0,
		MealTime:    "breakfast",
		EntryDate:   date,
	}
	_, err := service.CreateEntry(userID, babyReq)
	require.NoError(t, err)

	motherReq := &CreateEntryRequest{
		ProfileType: "mother",
		FoodID:      &foodID,
		ServingSize: 200.0,
		MealTime:    "breakfast",
		EntryDate:   date,
	}
	_, err = service.CreateEntry(userID, motherReq)
	require.NoError(t, err)

	// Get baby entries
	babyGetReq := &GetEntriesRequest{
		ProfileType: "baby",
		Date:        date,
	}
	babyResponse, err := service.GetEntries(userID, babyGetReq)
	require.NoError(t, err)
	assert.Len(t, babyResponse.Entries, 1)
	assert.Equal(t, 100.0, babyResponse.NutritionSummary.Calories)

	// Get mother entries
	motherGetReq := &GetEntriesRequest{
		ProfileType: "mother",
		Date:        date,
	}
	motherResponse, err := service.GetEntries(userID, motherGetReq)
	require.NoError(t, err)
	assert.Len(t, motherResponse.Entries, 1)
	assert.Equal(t, 200.0, motherResponse.NutritionSummary.Calories)
}

func TestDeleteEntry(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)
	foodID := createTestFood(t, db)

	// Create an entry
	req := &CreateEntryRequest{
		ProfileType: "baby",
		FoodID:      &foodID,
		ServingSize: 100.0,
		MealTime:    "breakfast",
		EntryDate:   "2024-01-15",
	}
	entry, err := service.CreateEntry(userID, req)
	require.NoError(t, err)

	// Delete the entry
	err = service.DeleteEntry(userID, entry.ID)
	assert.NoError(t, err)

	// Verify entry is deleted
	var deletedEntry database.DiaryEntry
	err = db.Where("id = ?", entry.ID).First(&deletedEntry).Error
	assert.Error(t, err)
	assert.Equal(t, gorm.ErrRecordNotFound, err)
}

func TestDeleteEntry_Unauthorized(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)
	foodID := createTestFood(t, db)

	// Create an entry
	req := &CreateEntryRequest{
		ProfileType: "baby",
		FoodID:      &foodID,
		ServingSize: 100.0,
		MealTime:    "breakfast",
		EntryDate:   "2024-01-15",
	}
	entry, err := service.CreateEntry(userID, req)
	require.NoError(t, err)

	// Try to delete with different user ID
	differentUserID := uuid.New()
	err = service.DeleteEntry(differentUserID, entry.ID)

	assert.Error(t, err)
	assert.Equal(t, ErrUnauthorized, err)
}

func TestDeleteEntry_NotFound(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)

	// Try to delete non-existent entry
	nonExistentID := uuid.New()
	err := service.DeleteEntry(userID, nonExistentID)

	assert.Error(t, err)
	assert.Equal(t, ErrDiaryEntryNotFound, err)
}

func TestCalculateNutritionSummary(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)

	entries := []database.DiaryEntry{
		{
			Calories: 100.0,
			Protein:  10.0,
			Carbs:    20.0,
			Fat:      5.0,
		},
		{
			Calories: 150.0,
			Protein:  15.0,
			Carbs:    25.0,
			Fat:      7.5,
		},
		{
			Calories: 200.0,
			Protein:  20.0,
			Carbs:    30.0,
			Fat:      10.0,
		},
	}

	summary := service.CalculateNutritionSummary(entries)

	assert.Equal(t, 450.0, summary.Calories)
	assert.Equal(t, 45.0, summary.Protein)
	assert.Equal(t, 75.0, summary.Carbs)
	assert.Equal(t, 22.5, summary.Fat)
}

func TestCalculateNutritionSummary_EmptyEntries(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)

	entries := []database.DiaryEntry{}
	summary := service.CalculateNutritionSummary(entries)

	assert.Equal(t, 0.0, summary.Calories)
	assert.Equal(t, 0.0, summary.Protein)
	assert.Equal(t, 0.0, summary.Carbs)
	assert.Equal(t, 0.0, summary.Fat)
}

func TestNutritionCalculation_Accuracy(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)

	// Create a food with specific nutrition values
	food := database.Food{
		Name:            "Precise Food",
		Category:        "mpasi",
		CaloriesPer100g: 123.45,
		ProteinPer100g:  12.34,
		CarbsPer100g:    23.45,
		FatPer100g:      6.78,
	}
	err := db.Create(&food).Error
	require.NoError(t, err)

	// Create entry with 75 grams
	req := &CreateEntryRequest{
		ProfileType: "baby",
		FoodID:      &food.ID,
		ServingSize: 75.0,
		MealTime:    "breakfast",
		EntryDate:   "2024-01-15",
	}

	entry, err := service.CreateEntry(userID, req)
	require.NoError(t, err)

	// Verify calculations: nutrition_per_100g * 75 / 100
	expectedCalories := 123.45 * 75.0 / 100.0
	expectedProtein := 12.34 * 75.0 / 100.0
	expectedCarbs := 23.45 * 75.0 / 100.0
	expectedFat := 6.78 * 75.0 / 100.0

	assert.InDelta(t, expectedCalories, entry.Calories, 0.01)
	assert.InDelta(t, expectedProtein, entry.Protein, 0.01)
	assert.InDelta(t, expectedCarbs, entry.Carbs, 0.01)
	assert.InDelta(t, expectedFat, entry.Fat, 0.01)
}

func TestGetEntries_DifferentDates(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)
	foodID := createTestFood(t, db)

	// Create entries for different dates
	dates := []string{"2024-01-15", "2024-01-16", "2024-01-17"}
	for _, date := range dates {
		req := &CreateEntryRequest{
			ProfileType: "baby",
			FoodID:      &foodID,
			ServingSize: 100.0,
			MealTime:    "breakfast",
			EntryDate:   date,
		}
		_, err := service.CreateEntry(userID, req)
		require.NoError(t, err)
	}

	// Get entries for specific date
	getReq := &GetEntriesRequest{
		ProfileType: "baby",
		Date:        "2024-01-16",
	}

	response, err := service.GetEntries(userID, getReq)
	require.NoError(t, err)
	assert.Len(t, response.Entries, 1)

	// Verify the entry is for the correct date
	entryDate := response.Entries[0].EntryDate.Format("2006-01-02")
	assert.Equal(t, "2024-01-16", entryDate)
}

func TestCreateEntry_InvalidDateFormat(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)
	foodID := createTestFood(t, db)

	req := &CreateEntryRequest{
		ProfileType: "baby",
		FoodID:      &foodID,
		ServingSize: 100.0,
		MealTime:    "breakfast",
		EntryDate:   "15-01-2024", // Invalid format
	}

	_, err := service.CreateEntry(userID, req)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "invalid date format")
}

func TestCreateEntry_MissingNutritionForCustomFood(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)

	customName := "Custom Food"
	req := &CreateEntryRequest{
		ProfileType:    "baby",
		CustomFoodName: &customName,
		ServingSize:    100.0,
		MealTime:       "breakfast",
		EntryDate:      "2024-01-15",
		// Missing nutrition values
	}

	_, err := service.CreateEntry(userID, req)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "nutrition values are required")
}

func TestCreateEntry_NeitherFoodIDNorCustomName(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	userID := createTestUser(t, db)

	req := &CreateEntryRequest{
		ProfileType: "baby",
		ServingSize: 100.0,
		MealTime:    "breakfast",
		EntryDate:   "2024-01-15",
		// Neither FoodID nor CustomFoodName provided
	}

	_, err := service.CreateEntry(userID, req)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "either food_id or custom_food_name must be provided")
}
