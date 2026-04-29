package diary

import (
	"math/rand"
	"nutribunda-backend/internal/database"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// Property 3: Nutrition Tracking Consistency
// Validates Requirements 4.3, 4.5
//
// This property test ensures that the nutrition tracking system maintains consistency
// when entries are added and removed. Specifically:
// - Adding an entry should increase nutrition totals by the entry's values
// - Removing the same entry should decrease nutrition totals by the entry's values
// - Adding and then removing an entry should result in the original nutrition state
//
// This validates:
// - Requirement 4.3: Nutrition calculation accuracy when entries are added
// - Requirement 4.5: Nutrition calculation accuracy when entries are removed

// setupPropertyTestDB creates an in-memory database for property testing
func setupPropertyTestDB(t *testing.T) *gorm.DB {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{
		DisableForeignKeyConstraintWhenMigrating: true,
	})
	require.NoError(t, err)

	// Manually create tables with SQLite-compatible schema
	err = db.Exec(`
		CREATE TABLE IF NOT EXISTS users (
			id TEXT PRIMARY KEY,
			email VARCHAR(255) UNIQUE NOT NULL,
			password_hash VARCHAR(255) NOT NULL,
			full_name VARCHAR(255) NOT NULL,
			weight DECIMAL(5,2),
			height DECIMAL(5,2),
			age INTEGER,
			is_breastfeeding BOOLEAN DEFAULT 0,
			activity_level VARCHAR(20) DEFAULT 'sedentary',
			profile_image_url TEXT,
			timezone VARCHAR(10) DEFAULT 'WIB',
			created_at DATETIME,
			updated_at DATETIME
		)
	`).Error
	require.NoError(t, err)

	err = db.Exec(`
		CREATE TABLE IF NOT EXISTS foods (
			id TEXT PRIMARY KEY,
			name VARCHAR(255) NOT NULL,
			category VARCHAR(50) NOT NULL,
			calories_per100g DECIMAL(6,2) NOT NULL,
			protein_per100g DECIMAL(5,2) NOT NULL,
			carbs_per100g DECIMAL(5,2) NOT NULL,
			fat_per100g DECIMAL(5,2) NOT NULL,
			created_at DATETIME
		)
	`).Error
	require.NoError(t, err)

	err = db.Exec(`
		CREATE TABLE IF NOT EXISTS diary_entries (
			id TEXT PRIMARY KEY,
			user_id TEXT NOT NULL,
			profile_type VARCHAR(10) NOT NULL,
			food_id TEXT,
			custom_food_name VARCHAR(255),
			serving_size DECIMAL(6,2) NOT NULL,
			meal_time VARCHAR(20) NOT NULL,
			calories DECIMAL(6,2) NOT NULL,
			protein DECIMAL(5,2) NOT NULL,
			carbs DECIMAL(5,2) NOT NULL,
			fat DECIMAL(5,2) NOT NULL,
			entry_date DATE NOT NULL,
			created_at DATETIME,
			updated_at DATETIME,
			deleted_at DATETIME
		)
	`).Error
	require.NoError(t, err)

	return db
}

// createPropertyTestUser creates a test user for property testing
func createPropertyTestUser(t *testing.T, db *gorm.DB) uuid.UUID {
	user := database.User{
		Email:        "property-test@example.com",
		PasswordHash: "hashedpassword",
		FullName:     "Property Test User",
	}
	err := db.Create(&user).Error
	require.NoError(t, err)
	return user.ID
}

// generateRandomFood creates a random food item for property testing
func generateRandomFood(t *testing.T, db *gorm.DB, seed int64) database.Food {
	r := rand.New(rand.NewSource(seed))
	
	food := database.Food{
		Name:            "Random Food " + uuid.New().String()[:8],
		Category:        []string{"mpasi", "ibu"}[r.Intn(2)],
		CaloriesPer100g: float64(r.Intn(500)) + r.Float64()*100, // 0-600 kcal
		ProteinPer100g:  float64(r.Intn(50)) + r.Float64()*10,   // 0-60g
		CarbsPer100g:    float64(r.Intn(80)) + r.Float64()*20,   // 0-100g
		FatPer100g:      float64(r.Intn(40)) + r.Float64()*10,   // 0-50g
	}
	
	err := db.Create(&food).Error
	require.NoError(t, err)
	
	return food
}

// generateRandomDiaryEntry creates a random diary entry request
func generateRandomDiaryEntry(foodID uuid.UUID, seed int64) *CreateEntryRequest {
	r := rand.New(rand.NewSource(seed))
	
	profileTypes := []string{"baby", "mother"}
	mealTimes := []string{"breakfast", "lunch", "dinner", "snack"}
	
	// Generate random date within last 30 days
	daysAgo := r.Intn(30)
	date := time.Now().AddDate(0, 0, -daysAgo).Format("2006-01-02")
	
	return &CreateEntryRequest{
		ProfileType: profileTypes[r.Intn(len(profileTypes))],
		FoodID:      &foodID,
		ServingSize: float64(r.Intn(300)) + 50.0, // 50-350 grams
		MealTime:    mealTimes[r.Intn(len(mealTimes))],
		EntryDate:   date,
	}
}

// TestProperty_NutritionTrackingConsistency_AddRemove tests that adding and removing
// the same entry results in the original nutrition state
func TestProperty_NutritionTrackingConsistency_AddRemove(t *testing.T) {
	const numIterations = 100
	
	for i := 0; i < numIterations; i++ {
		t.Run("Iteration_"+string(rune(i)), func(t *testing.T) {
			// Setup
			db := setupPropertyTestDB(t)
			service := NewService(db)
			userID := createPropertyTestUser(t, db)
			
			// Generate random food and entry
			seed := time.Now().UnixNano() + int64(i)
			food := generateRandomFood(t, db, seed)
			entryReq := generateRandomDiaryEntry(food.ID, seed+1)
			
			// Get initial nutrition state (should be empty)
			getReq := &GetEntriesRequest{
				ProfileType: entryReq.ProfileType,
				Date:        entryReq.EntryDate,
			}
			
			initialResponse, err := service.GetEntries(userID, getReq)
			require.NoError(t, err)
			initialSummary := initialResponse.NutritionSummary
			
			// Add entry
			entry, err := service.CreateEntry(userID, entryReq)
			require.NoError(t, err)
			
			// Get nutrition state after adding
			afterAddResponse, err := service.GetEntries(userID, getReq)
			require.NoError(t, err)
			afterAddSummary := afterAddResponse.NutritionSummary
			
			// Verify nutrition increased by entry values
			expectedCalories := initialSummary.Calories + entry.Calories
			expectedProtein := initialSummary.Protein + entry.Protein
			expectedCarbs := initialSummary.Carbs + entry.Carbs
			expectedFat := initialSummary.Fat + entry.Fat
			
			assert.InDelta(t, expectedCalories, afterAddSummary.Calories, 0.01,
				"Calories should increase by entry value after adding")
			assert.InDelta(t, expectedProtein, afterAddSummary.Protein, 0.01,
				"Protein should increase by entry value after adding")
			assert.InDelta(t, expectedCarbs, afterAddSummary.Carbs, 0.01,
				"Carbs should increase by entry value after adding")
			assert.InDelta(t, expectedFat, afterAddSummary.Fat, 0.01,
				"Fat should increase by entry value after adding")
			
			// Remove entry
			err = service.DeleteEntry(userID, entry.ID)
			require.NoError(t, err)
			
			// Get nutrition state after removing
			afterRemoveResponse, err := service.GetEntries(userID, getReq)
			require.NoError(t, err)
			afterRemoveSummary := afterRemoveResponse.NutritionSummary
			
			// PROPERTY: Adding and removing the same entry should result in original state
			assert.InDelta(t, initialSummary.Calories, afterRemoveSummary.Calories, 0.01,
				"Calories should return to initial value after add+remove")
			assert.InDelta(t, initialSummary.Protein, afterRemoveSummary.Protein, 0.01,
				"Protein should return to initial value after add+remove")
			assert.InDelta(t, initialSummary.Carbs, afterRemoveSummary.Carbs, 0.01,
				"Carbs should return to initial value after add+remove")
			assert.InDelta(t, initialSummary.Fat, afterRemoveSummary.Fat, 0.01,
				"Fat should return to initial value after add+remove")
		})
	}
}

// TestProperty_NutritionTrackingConsistency_MultipleEntries tests consistency
// with multiple entries added and removed in various orders
func TestProperty_NutritionTrackingConsistency_MultipleEntries(t *testing.T) {
	const numIterations = 50
	const entriesPerIteration = 5
	
	for i := 0; i < numIterations; i++ {
		t.Run("Iteration_"+string(rune(i)), func(t *testing.T) {
			// Setup
			db := setupPropertyTestDB(t)
			service := NewService(db)
			userID := createPropertyTestUser(t, db)
			
			seed := time.Now().UnixNano() + int64(i)
			r := rand.New(rand.NewSource(seed))
			
			// Use same date and profile for all entries in this iteration
			date := time.Now().AddDate(0, 0, -r.Intn(30)).Format("2006-01-02")
			profileType := []string{"baby", "mother"}[r.Intn(2)]
			
			// Get initial state
			getReq := &GetEntriesRequest{
				ProfileType: profileType,
				Date:        date,
			}
			
			initialResponse, err := service.GetEntries(userID, getReq)
			require.NoError(t, err)
			initialSummary := initialResponse.NutritionSummary
			
			// Create multiple entries
			var entries []*database.DiaryEntry
			var expectedDelta NutritionSummary
			
			for j := 0; j < entriesPerIteration; j++ {
				food := generateRandomFood(t, db, seed+int64(j))
				
				entryReq := &CreateEntryRequest{
					ProfileType: profileType,
					FoodID:      &food.ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					EntryDate:   date,
				}
				
				entry, err := service.CreateEntry(userID, entryReq)
				require.NoError(t, err)
				entries = append(entries, entry)
				
				// Track expected delta
				expectedDelta.Calories += entry.Calories
				expectedDelta.Protein += entry.Protein
				expectedDelta.Carbs += entry.Carbs
				expectedDelta.Fat += entry.Fat
			}
			
			// Verify nutrition after all additions
			afterAddResponse, err := service.GetEntries(userID, getReq)
			require.NoError(t, err)
			afterAddSummary := afterAddResponse.NutritionSummary
			
			assert.InDelta(t, initialSummary.Calories+expectedDelta.Calories, afterAddSummary.Calories, 0.01)
			assert.InDelta(t, initialSummary.Protein+expectedDelta.Protein, afterAddSummary.Protein, 0.01)
			assert.InDelta(t, initialSummary.Carbs+expectedDelta.Carbs, afterAddSummary.Carbs, 0.01)
			assert.InDelta(t, initialSummary.Fat+expectedDelta.Fat, afterAddSummary.Fat, 0.01)
			
			// Remove all entries in random order
			r.Shuffle(len(entries), func(i, j int) {
				entries[i], entries[j] = entries[j], entries[i]
			})
			
			for _, entry := range entries {
				err := service.DeleteEntry(userID, entry.ID)
				require.NoError(t, err)
			}
			
			// PROPERTY: After removing all entries, should return to initial state
			afterRemoveResponse, err := service.GetEntries(userID, getReq)
			require.NoError(t, err)
			afterRemoveSummary := afterRemoveResponse.NutritionSummary
			
			assert.InDelta(t, initialSummary.Calories, afterRemoveSummary.Calories, 0.01,
				"Calories should return to initial after removing all entries")
			assert.InDelta(t, initialSummary.Protein, afterRemoveSummary.Protein, 0.01,
				"Protein should return to initial after removing all entries")
			assert.InDelta(t, initialSummary.Carbs, afterRemoveSummary.Carbs, 0.01,
				"Carbs should return to initial after removing all entries")
			assert.InDelta(t, initialSummary.Fat, afterRemoveSummary.Fat, 0.01,
				"Fat should return to initial after removing all entries")
		})
	}
}

// TestProperty_NutritionTrackingConsistency_Commutativity tests that the order
// of adding entries doesn't affect the final nutrition summary
func TestProperty_NutritionTrackingConsistency_Commutativity(t *testing.T) {
	const numIterations = 30
	const entriesPerIteration = 4
	
	for i := 0; i < numIterations; i++ {
		t.Run("Iteration_"+string(rune(i)), func(t *testing.T) {
			seed := time.Now().UnixNano() + int64(i)
			r := rand.New(rand.NewSource(seed))
			
			date := time.Now().AddDate(0, 0, -r.Intn(30)).Format("2006-01-02")
			profileType := []string{"baby", "mother"}[r.Intn(2)]
			
			// Create entry requests
			var entryReqs []*CreateEntryRequest
			var foods []database.Food
			
			// Setup first database and create foods
			db1 := setupPropertyTestDB(t)
			for j := 0; j < entriesPerIteration; j++ {
				food := generateRandomFood(t, db1, seed+int64(j))
				foods = append(foods, food)
			}
			
			// Create entry requests
			for j := 0; j < entriesPerIteration; j++ {
				entryReq := &CreateEntryRequest{
					ProfileType: profileType,
					FoodID:      &foods[j].ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					EntryDate:   date,
				}
				entryReqs = append(entryReqs, entryReq)
			}
			
			// Test 1: Add entries in original order
			service1 := NewService(db1)
			userID1 := createPropertyTestUser(t, db1)
			
			for _, req := range entryReqs {
				_, err := service1.CreateEntry(userID1, req)
				require.NoError(t, err)
			}
			
			getReq := &GetEntriesRequest{
				ProfileType: profileType,
				Date:        date,
			}
			
			response1, err := service1.GetEntries(userID1, getReq)
			require.NoError(t, err)
			summary1 := response1.NutritionSummary
			
			// Test 2: Add entries in shuffled order
			db2 := setupPropertyTestDB(t)
			service2 := NewService(db2)
			userID2 := createPropertyTestUser(t, db2)
			
			// Recreate foods in second database
			for j := 0; j < entriesPerIteration; j++ {
				food := foods[j]
				food.ID = uuid.New() // New ID for second database
				err := db2.Create(&food).Error
				require.NoError(t, err)
				entryReqs[j].FoodID = &food.ID
			}
			
			// Shuffle the order
			shuffledReqs := make([]*CreateEntryRequest, len(entryReqs))
			copy(shuffledReqs, entryReqs)
			r.Shuffle(len(shuffledReqs), func(i, j int) {
				shuffledReqs[i], shuffledReqs[j] = shuffledReqs[j], shuffledReqs[i]
			})
			
			for _, req := range shuffledReqs {
				_, err := service2.CreateEntry(userID2, req)
				require.NoError(t, err)
			}
			
			response2, err := service2.GetEntries(userID2, getReq)
			require.NoError(t, err)
			summary2 := response2.NutritionSummary
			
			// PROPERTY: Order of adding entries should not affect final nutrition summary
			assert.InDelta(t, summary1.Calories, summary2.Calories, 0.01,
				"Calories should be same regardless of entry order")
			assert.InDelta(t, summary1.Protein, summary2.Protein, 0.01,
				"Protein should be same regardless of entry order")
			assert.InDelta(t, summary1.Carbs, summary2.Carbs, 0.01,
				"Carbs should be same regardless of entry order")
			assert.InDelta(t, summary1.Fat, summary2.Fat, 0.01,
				"Fat should be same regardless of entry order")
		})
	}
}

// TestProperty_NutritionTrackingConsistency_Associativity tests that grouping
// of nutrition calculations doesn't affect the result
func TestProperty_NutritionTrackingConsistency_Associativity(t *testing.T) {
	const numIterations = 50
	
	for i := 0; i < numIterations; i++ {
		t.Run("Iteration_"+string(rune(i)), func(t *testing.T) {
			// Setup
			db := setupPropertyTestDB(t)
			service := NewService(db)
			userID := createPropertyTestUser(t, db)
			
			seed := time.Now().UnixNano() + int64(i)
			r := rand.New(rand.NewSource(seed))
			
			date := time.Now().AddDate(0, 0, -r.Intn(30)).Format("2006-01-02")
			profileType := []string{"baby", "mother"}[r.Intn(2)]
			
			// Create three entries
			var entries []*database.DiaryEntry
			for j := 0; j < 3; j++ {
				food := generateRandomFood(t, db, seed+int64(j))
				entryReq := &CreateEntryRequest{
					ProfileType: profileType,
					FoodID:      &food.ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					EntryDate:   date,
				}
				
				entry, err := service.CreateEntry(userID, entryReq)
				require.NoError(t, err)
				entries = append(entries, entry)
			}
			
			// Calculate (entry1 + entry2) + entry3
			sum12 := NutritionSummary{
				Calories: entries[0].Calories + entries[1].Calories,
				Protein:  entries[0].Protein + entries[1].Protein,
				Carbs:    entries[0].Carbs + entries[1].Carbs,
				Fat:      entries[0].Fat + entries[1].Fat,
			}
			
			sum123_left := NutritionSummary{
				Calories: sum12.Calories + entries[2].Calories,
				Protein:  sum12.Protein + entries[2].Protein,
				Carbs:    sum12.Carbs + entries[2].Carbs,
				Fat:      sum12.Fat + entries[2].Fat,
			}
			
			// Calculate entry1 + (entry2 + entry3)
			sum23 := NutritionSummary{
				Calories: entries[1].Calories + entries[2].Calories,
				Protein:  entries[1].Protein + entries[2].Protein,
				Carbs:    entries[1].Carbs + entries[2].Carbs,
				Fat:      entries[1].Fat + entries[2].Fat,
			}
			
			sum123_right := NutritionSummary{
				Calories: entries[0].Calories + sum23.Calories,
				Protein:  entries[0].Protein + sum23.Protein,
				Carbs:    entries[0].Carbs + sum23.Carbs,
				Fat:      entries[0].Fat + sum23.Fat,
			}
			
			// Get actual summary from service
			getReq := &GetEntriesRequest{
				ProfileType: profileType,
				Date:        date,
			}
			
			response, err := service.GetEntries(userID, getReq)
			require.NoError(t, err)
			actualSummary := response.NutritionSummary
			
			// PROPERTY: (a + b) + c = a + (b + c) = actual_summary
			assert.InDelta(t, sum123_left.Calories, sum123_right.Calories, 0.01,
				"Associativity: (a+b)+c should equal a+(b+c) for calories")
			assert.InDelta(t, sum123_left.Protein, sum123_right.Protein, 0.01,
				"Associativity: (a+b)+c should equal a+(b+c) for protein")
			assert.InDelta(t, sum123_left.Carbs, sum123_right.Carbs, 0.01,
				"Associativity: (a+b)+c should equal a+(b+c) for carbs")
			assert.InDelta(t, sum123_left.Fat, sum123_right.Fat, 0.01,
				"Associativity: (a+b)+c should equal a+(b+c) for fat")
			
			assert.InDelta(t, sum123_left.Calories, actualSummary.Calories, 0.01,
				"Manual calculation should match service calculation for calories")
			assert.InDelta(t, sum123_left.Protein, actualSummary.Protein, 0.01,
				"Manual calculation should match service calculation for protein")
			assert.InDelta(t, sum123_left.Carbs, actualSummary.Carbs, 0.01,
				"Manual calculation should match service calculation for carbs")
			assert.InDelta(t, sum123_left.Fat, actualSummary.Fat, 0.01,
				"Manual calculation should match service calculation for fat")
		})
	}
}

// TestProperty_NutritionTrackingConsistency_NonNegativity tests that nutrition
// values never become negative
func TestProperty_NutritionTrackingConsistency_NonNegativity(t *testing.T) {
	const numIterations = 100
	
	for i := 0; i < numIterations; i++ {
		t.Run("Iteration_"+string(rune(i)), func(t *testing.T) {
			// Setup
			db := setupPropertyTestDB(t)
			service := NewService(db)
			userID := createPropertyTestUser(t, db)
			
			seed := time.Now().UnixNano() + int64(i)
			r := rand.New(rand.NewSource(seed))
			
			date := time.Now().AddDate(0, 0, -r.Intn(30)).Format("2006-01-02")
			profileType := []string{"baby", "mother"}[r.Intn(2)]
			
			// Add random number of entries
			numEntries := r.Intn(10) + 1
			for j := 0; j < numEntries; j++ {
				food := generateRandomFood(t, db, seed+int64(j))
				entryReq := &CreateEntryRequest{
					ProfileType: profileType,
					FoodID:      &food.ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					EntryDate:   date,
				}
				
				_, err := service.CreateEntry(userID, entryReq)
				require.NoError(t, err)
			}
			
			// Get nutrition summary
			getReq := &GetEntriesRequest{
				ProfileType: profileType,
				Date:        date,
			}
			
			response, err := service.GetEntries(userID, getReq)
			require.NoError(t, err)
			summary := response.NutritionSummary
			
			// PROPERTY: Nutrition values should never be negative
			assert.GreaterOrEqual(t, summary.Calories, 0.0,
				"Calories should never be negative")
			assert.GreaterOrEqual(t, summary.Protein, 0.0,
				"Protein should never be negative")
			assert.GreaterOrEqual(t, summary.Carbs, 0.0,
				"Carbs should never be negative")
			assert.GreaterOrEqual(t, summary.Fat, 0.0,
				"Fat should never be negative")
		})
	}
}

// TestProperty_NutritionTrackingConsistency_ProfileIsolation tests that
// nutrition tracking for baby and mother profiles are completely isolated
func TestProperty_NutritionTrackingConsistency_ProfileIsolation(t *testing.T) {
	const numIterations = 50
	
	for i := 0; i < numIterations; i++ {
		t.Run("Iteration_"+string(rune(i)), func(t *testing.T) {
			// Setup
			db := setupPropertyTestDB(t)
			service := NewService(db)
			userID := createPropertyTestUser(t, db)
			
			seed := time.Now().UnixNano() + int64(i)
			r := rand.New(rand.NewSource(seed))
			
			date := time.Now().AddDate(0, 0, -r.Intn(30)).Format("2006-01-02")
			
			// Add entries for baby profile
			var babyEntries []*database.DiaryEntry
			numBabyEntries := r.Intn(5) + 1
			for j := 0; j < numBabyEntries; j++ {
				food := generateRandomFood(t, db, seed+int64(j))
				entryReq := &CreateEntryRequest{
					ProfileType: "baby",
					FoodID:      &food.ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					EntryDate:   date,
				}
				
				entry, err := service.CreateEntry(userID, entryReq)
				require.NoError(t, err)
				babyEntries = append(babyEntries, entry)
			}
			
			// Add entries for mother profile
			var motherEntries []*database.DiaryEntry
			numMotherEntries := r.Intn(5) + 1
			for j := 0; j < numMotherEntries; j++ {
				food := generateRandomFood(t, db, seed+int64(j+100))
				entryReq := &CreateEntryRequest{
					ProfileType: "mother",
					FoodID:      &food.ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					EntryDate:   date,
				}
				
				entry, err := service.CreateEntry(userID, entryReq)
				require.NoError(t, err)
				motherEntries = append(motherEntries, entry)
			}
			
			// Get baby nutrition summary
			babyGetReq := &GetEntriesRequest{
				ProfileType: "baby",
				Date:        date,
			}
			babyResponse, err := service.GetEntries(userID, babyGetReq)
			require.NoError(t, err)
			babySummary := babyResponse.NutritionSummary
			
			// Get mother nutrition summary
			motherGetReq := &GetEntriesRequest{
				ProfileType: "mother",
				Date:        date,
			}
			motherResponse, err := service.GetEntries(userID, motherGetReq)
			require.NoError(t, err)
			motherSummary := motherResponse.NutritionSummary
			
			// Calculate expected summaries
			var expectedBabySummary NutritionSummary
			for _, entry := range babyEntries {
				expectedBabySummary.Calories += entry.Calories
				expectedBabySummary.Protein += entry.Protein
				expectedBabySummary.Carbs += entry.Carbs
				expectedBabySummary.Fat += entry.Fat
			}
			
			var expectedMotherSummary NutritionSummary
			for _, entry := range motherEntries {
				expectedMotherSummary.Calories += entry.Calories
				expectedMotherSummary.Protein += entry.Protein
				expectedMotherSummary.Carbs += entry.Carbs
				expectedMotherSummary.Fat += entry.Fat
			}
			
			// PROPERTY: Baby and mother profiles should be completely isolated
			assert.InDelta(t, expectedBabySummary.Calories, babySummary.Calories, 0.01,
				"Baby profile should only include baby entries")
			assert.InDelta(t, expectedMotherSummary.Calories, motherSummary.Calories, 0.01,
				"Mother profile should only include mother entries")
			
			// Verify they are different (unless by extreme coincidence they're equal)
			if numBabyEntries != numMotherEntries {
				assert.NotEqual(t, babySummary.Calories, motherSummary.Calories,
					"Baby and mother profiles should have different nutrition values")
			}
		})
	}
}

// Property 8: Sync Consistency
// Validates Requirements 3.4, 3.5
//
// This property test ensures that the synchronization mechanism maintains data consistency
// between client and server regardless of:
// - The order of sync operations
// - Network interruptions (simulated by multiple sync cycles)
// - Concurrent modifications on client and server
// - Conflict resolution strategies
//
// This validates:
// - Requirement 3.4: Initial download and storage of Food_Database to SQLite
// - Requirement 3.5: Synchronization of local copy with server updates

// TestProperty_SyncConsistency_Idempotency tests that syncing the same data
// multiple times produces the same result
func TestProperty_SyncConsistency_Idempotency(t *testing.T) {
	const numIterations = 50

	for i := 0; i < numIterations; i++ {
		t.Run("Iteration_"+string(rune(i)), func(t *testing.T) {
			// Setup
			db := setupPropertyTestDB(t)
			service := NewService(db)
			userID := createPropertyTestUser(t, db)

			seed := time.Now().UnixNano() + int64(i)
			r := rand.New(rand.NewSource(seed))

			// Create some entries on server
			var serverEntries []SyncDiaryEntry
			numEntries := r.Intn(5) + 1
			for j := 0; j < numEntries; j++ {
				food := generateRandomFood(t, db, seed+int64(j))
				entryDate := time.Now().AddDate(0, 0, -r.Intn(30)).Format("2006-01-02")
				
				entry := SyncDiaryEntry{
					ID:          uuid.New(),
					ProfileType: []string{"baby", "mother"}[r.Intn(2)],
					FoodID:      &food.ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					Calories:    food.CaloriesPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Protein:     food.ProteinPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Carbs:       food.CarbsPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Fat:         food.FatPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					EntryDate:   entryDate,
					UpdatedAt:   time.Now().Format(time.RFC3339),
				}
				serverEntries = append(serverEntries, entry)
			}

			// First sync
			syncReq1 := &SyncRequest{
				LastSyncTime: "",
				Entries:      serverEntries,
				DeletedIDs:   []uuid.UUID{},
			}

			response1, err := service.SyncDiaryEntries(userID, syncReq1)
			require.NoError(t, err)
			assert.Empty(t, response1.Conflicts)

			// Get state after first sync
			var entriesAfterSync1 []database.DiaryEntry
			err = db.Where("user_id = ?", userID).Find(&entriesAfterSync1).Error
			require.NoError(t, err)

			// Second sync with same data (idempotency test)
			syncReq2 := &SyncRequest{
				LastSyncTime: time.Now().Add(-1 * time.Hour).Format(time.RFC3339),
				Entries:      serverEntries,
				DeletedIDs:   []uuid.UUID{},
			}

			response2, err := service.SyncDiaryEntries(userID, syncReq2)
			require.NoError(t, err)
			assert.Empty(t, response2.Conflicts)

			// Get state after second sync
			var entriesAfterSync2 []database.DiaryEntry
			err = db.Where("user_id = ?", userID).Find(&entriesAfterSync2).Error
			require.NoError(t, err)

			// PROPERTY: Syncing same data multiple times should produce same result
			assert.Equal(t, len(entriesAfterSync1), len(entriesAfterSync2),
				"Number of entries should be same after idempotent sync")

			// Verify each entry is identical
			for _, entry1 := range entriesAfterSync1 {
				found := false
				for _, entry2 := range entriesAfterSync2 {
					if entry1.ID == entry2.ID {
						found = true
						assert.Equal(t, entry1.Calories, entry2.Calories)
						assert.Equal(t, entry1.Protein, entry2.Protein)
						assert.Equal(t, entry1.Carbs, entry2.Carbs)
						assert.Equal(t, entry1.Fat, entry2.Fat)
						assert.Equal(t, entry1.ServingSize, entry2.ServingSize)
						break
					}
				}
				assert.True(t, found, "Entry should exist after idempotent sync")
			}
		})
	}
}

// TestProperty_SyncConsistency_Convergence tests that client and server
// converge to the same state after sync completes without conflicts
func TestProperty_SyncConsistency_Convergence(t *testing.T) {
	const numIterations = 50

	for i := 0; i < numIterations; i++ {
		t.Run("Iteration_"+string(rune(i)), func(t *testing.T) {
			// Setup two databases to simulate client and server
			dbServer := setupPropertyTestDB(t)
			dbClient := setupPropertyTestDB(t)
			
			serviceServer := NewService(dbServer)
			
			userID := createPropertyTestUser(t, dbServer)
			createPropertyTestUser(t, dbClient) // Same user on client

			seed := time.Now().UnixNano() + int64(i)
			r := rand.New(rand.NewSource(seed))

			// Create entries on server
			var serverEntries []SyncDiaryEntry
			numServerEntries := r.Intn(5) + 1
			for j := 0; j < numServerEntries; j++ {
				food := generateRandomFood(t, dbServer, seed+int64(j))
				entryDate := time.Now().AddDate(0, 0, -r.Intn(30)).Format("2006-01-02")
				
				entry := SyncDiaryEntry{
					ID:          uuid.New(),
					ProfileType: []string{"baby", "mother"}[r.Intn(2)],
					FoodID:      &food.ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					Calories:    food.CaloriesPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Protein:     food.ProteinPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Carbs:       food.CarbsPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Fat:         food.FatPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					EntryDate:   entryDate,
					UpdatedAt:   time.Now().Add(-1 * time.Hour).Format(time.RFC3339),
				}
				serverEntries = append(serverEntries, entry)
				
				// Create on server database
				dbEntry := database.DiaryEntry{
					ID:          entry.ID,
					UserID:      userID,
					ProfileType: entry.ProfileType,
					FoodID:      entry.FoodID,
					ServingSize: entry.ServingSize,
					MealTime:    entry.MealTime,
					Calories:    entry.Calories,
					Protein:     entry.Protein,
					Carbs:       entry.Carbs,
					Fat:         entry.Fat,
					EntryDate:   time.Now().AddDate(0, 0, -r.Intn(30)),
					UpdatedAt:   time.Now().Add(-1 * time.Hour),
				}
				dbServer.Create(&dbEntry)
			}

			// Client syncs with server
			syncReq := &SyncRequest{
				LastSyncTime: "",
				Entries:      []SyncDiaryEntry{},
				DeletedIDs:   []uuid.UUID{},
			}

			response, err := serviceServer.SyncDiaryEntries(userID, syncReq)
			require.NoError(t, err)
			assert.Empty(t, response.Conflicts)

			// Apply server entries to client
			for _, serverEntry := range response.Entries {
				clientEntry := database.DiaryEntry{
					ID:          serverEntry.ID,
					UserID:      userID,
					ProfileType: serverEntry.ProfileType,
					FoodID:      serverEntry.FoodID,
					ServingSize: serverEntry.ServingSize,
					MealTime:    serverEntry.MealTime,
					Calories:    serverEntry.Calories,
					Protein:     serverEntry.Protein,
					Carbs:       serverEntry.Carbs,
					Fat:         serverEntry.Fat,
					EntryDate:   serverEntry.EntryDate,
					UpdatedAt:   serverEntry.UpdatedAt,
				}
				dbClient.Create(&clientEntry)
			}

			// Get final state from both databases
			var serverFinalEntries []database.DiaryEntry
			var clientFinalEntries []database.DiaryEntry
			
			dbServer.Where("user_id = ?", userID).Find(&serverFinalEntries)
			dbClient.Where("user_id = ?", userID).Find(&clientFinalEntries)

			// PROPERTY: After sync without conflicts, client and server should have identical data
			assert.Equal(t, len(serverFinalEntries), len(clientFinalEntries),
				"Client and server should have same number of entries after convergence")

			// Verify each entry matches
			for _, serverEntry := range serverFinalEntries {
				found := false
				for _, clientEntry := range clientFinalEntries {
					if serverEntry.ID == clientEntry.ID {
						found = true
						assert.InDelta(t, serverEntry.Calories, clientEntry.Calories, 0.01,
							"Calories should match after convergence")
						assert.InDelta(t, serverEntry.Protein, clientEntry.Protein, 0.01,
							"Protein should match after convergence")
						assert.InDelta(t, serverEntry.Carbs, clientEntry.Carbs, 0.01,
							"Carbs should match after convergence")
						assert.InDelta(t, serverEntry.Fat, clientEntry.Fat, 0.01,
							"Fat should match after convergence")
						break
					}
				}
				assert.True(t, found, "All server entries should exist on client after convergence")
			}
		})
	}
}

// TestProperty_SyncConsistency_ConflictDetection tests that concurrent
// modifications are detected and reported as conflicts
func TestProperty_SyncConsistency_ConflictDetection(t *testing.T) {
	const numIterations = 50

	for i := 0; i < numIterations; i++ {
		t.Run("Iteration_"+string(rune(i)), func(t *testing.T) {
			// Setup
			db := setupPropertyTestDB(t)
			service := NewService(db)
			userID := createPropertyTestUser(t, db)

			seed := time.Now().UnixNano() + int64(i)
			r := rand.New(rand.NewSource(seed))

			// Create entry on server
			food := generateRandomFood(t, db, seed)
			entryID := uuid.New()
			serverTime := time.Now()
			
			serverEntry := database.DiaryEntry{
				ID:          entryID,
				UserID:      userID,
				ProfileType: "baby",
				FoodID:      &food.ID,
				ServingSize: 100.0,
				MealTime:    "breakfast",
				Calories:    150.0,
				Protein:     5.0,
				Carbs:       20.0,
				Fat:         3.0,
				EntryDate:   time.Now().AddDate(0, 0, -r.Intn(30)),
				UpdatedAt:   serverTime,
			}
			db.Create(&serverEntry)

			// Client has older version and tries to update
			clientTime := serverTime.Add(-1 * time.Hour)
			clientEntry := SyncDiaryEntry{
				ID:          entryID,
				ProfileType: "baby",
				FoodID:      &food.ID,
				ServingSize: 120.0, // Different value
				MealTime:    "breakfast",
				Calories:    180.0, // Different value
				Protein:     6.0,
				Carbs:       22.0,
				Fat:         4.0,
				EntryDate:   serverEntry.EntryDate.Format("2006-01-02"),
				UpdatedAt:   clientTime.Format(time.RFC3339),
			}

			syncReq := &SyncRequest{
				LastSyncTime: clientTime.Add(-24 * time.Hour).Format(time.RFC3339),
				Entries:      []SyncDiaryEntry{clientEntry},
				DeletedIDs:   []uuid.UUID{},
			}

			response, err := service.SyncDiaryEntries(userID, syncReq)
			require.NoError(t, err)

			// PROPERTY: Concurrent modifications should be detected as conflicts
			assert.NotEmpty(t, response.Conflicts,
				"Concurrent modification should be detected as conflict")
			
			if len(response.Conflicts) > 0 {
				assert.Equal(t, "update_conflict", response.Conflicts[0].ConflictType,
					"Conflict type should be update_conflict")
				assert.Equal(t, entryID, response.Conflicts[0].EntryID,
					"Conflict should reference correct entry ID")
			}

			// Verify server entry was NOT modified (conflict not auto-resolved)
			var unchangedEntry database.DiaryEntry
			db.Where("id = ?", entryID).First(&unchangedEntry)
			assert.Equal(t, serverEntry.Calories, unchangedEntry.Calories,
				"Server entry should remain unchanged when conflict detected")
		})
	}
}

// TestProperty_SyncConsistency_DataIntegrity tests that no data is lost
// during sync operations
func TestProperty_SyncConsistency_DataIntegrity(t *testing.T) {
	const numIterations = 50

	for i := 0; i < numIterations; i++ {
		t.Run("Iteration_"+string(rune(i)), func(t *testing.T) {
			// Setup
			db := setupPropertyTestDB(t)
			service := NewService(db)
			userID := createPropertyTestUser(t, db)

			seed := time.Now().UnixNano() + int64(i)
			r := rand.New(rand.NewSource(seed))

			// Create initial entries on server
			var initialEntries []database.DiaryEntry
			numInitialEntries := r.Intn(5) + 3 // 3-7 entries
			
			for j := 0; j < numInitialEntries; j++ {
				food := generateRandomFood(t, db, seed+int64(j))
				entry := database.DiaryEntry{
					ID:          uuid.New(),
					UserID:      userID,
					ProfileType: []string{"baby", "mother"}[r.Intn(2)],
					FoodID:      &food.ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					Calories:    food.CaloriesPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Protein:     food.ProteinPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Carbs:       food.CarbsPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Fat:         food.FatPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					EntryDate:   time.Now().AddDate(0, 0, -r.Intn(30)),
					UpdatedAt:   time.Now().Add(-2 * time.Hour),
				}
				db.Create(&entry)
				initialEntries = append(initialEntries, entry)
			}

			// Calculate initial total nutrition
			var initialTotalCalories, initialTotalProtein, initialTotalCarbs, initialTotalFat float64
			for _, entry := range initialEntries {
				initialTotalCalories += entry.Calories
				initialTotalProtein += entry.Protein
				initialTotalCarbs += entry.Carbs
				initialTotalFat += entry.Fat
			}

			// Client adds new entries
			var clientNewEntries []SyncDiaryEntry
			numNewEntries := r.Intn(3) + 1 // 1-3 new entries
			
			for j := 0; j < numNewEntries; j++ {
				food := generateRandomFood(t, db, seed+int64(j+100))
				entry := SyncDiaryEntry{
					ID:          uuid.New(),
					ProfileType: []string{"baby", "mother"}[r.Intn(2)],
					FoodID:      &food.ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					Calories:    food.CaloriesPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Protein:     food.ProteinPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Carbs:       food.CarbsPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Fat:         food.FatPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					EntryDate:   time.Now().AddDate(0, 0, -r.Intn(30)).Format("2006-01-02"),
					UpdatedAt:   time.Now().Format(time.RFC3339),
				}
				clientNewEntries = append(clientNewEntries, entry)
			}

			// Perform sync
			syncReq := &SyncRequest{
				LastSyncTime: time.Now().Add(-3 * time.Hour).Format(time.RFC3339),
				Entries:      clientNewEntries,
				DeletedIDs:   []uuid.UUID{},
			}

			response, err := service.SyncDiaryEntries(userID, syncReq)
			require.NoError(t, err)
			assert.Empty(t, response.Conflicts)

			// Get all entries after sync
			var finalEntries []database.DiaryEntry
			db.Where("user_id = ?", userID).Find(&finalEntries)

			// Calculate final total nutrition
			var finalTotalCalories, finalTotalProtein, finalTotalCarbs, finalTotalFat float64
			for _, entry := range finalEntries {
				finalTotalCalories += entry.Calories
				finalTotalProtein += entry.Protein
				finalTotalCarbs += entry.Carbs
				finalTotalFat += entry.Fat
			}

			// Calculate expected totals (initial + new entries)
			var expectedTotalCalories, expectedTotalProtein, expectedTotalCarbs, expectedTotalFat float64
			expectedTotalCalories = initialTotalCalories
			expectedTotalProtein = initialTotalProtein
			expectedTotalCarbs = initialTotalCarbs
			expectedTotalFat = initialTotalFat
			
			for _, entry := range clientNewEntries {
				expectedTotalCalories += entry.Calories
				expectedTotalProtein += entry.Protein
				expectedTotalCarbs += entry.Carbs
				expectedTotalFat += entry.Fat
			}

			// PROPERTY: No data should be lost during sync
			assert.Equal(t, numInitialEntries+numNewEntries, len(finalEntries),
				"All entries should be preserved after sync")
			
			assert.InDelta(t, expectedTotalCalories, finalTotalCalories, 0.01,
				"Total calories should be preserved (no data loss)")
			assert.InDelta(t, expectedTotalProtein, finalTotalProtein, 0.01,
				"Total protein should be preserved (no data loss)")
			assert.InDelta(t, expectedTotalCarbs, finalTotalCarbs, 0.01,
				"Total carbs should be preserved (no data loss)")
			assert.InDelta(t, expectedTotalFat, finalTotalFat, 0.01,
				"Total fat should be preserved (no data loss)")
		})
	}
}

// TestProperty_SyncConsistency_TimestampOrdering tests that sync correctly
// uses timestamps to determine what needs to be synced
func TestProperty_SyncConsistency_TimestampOrdering(t *testing.T) {
	const numIterations = 50

	for i := 0; i < numIterations; i++ {
		t.Run("Iteration_"+string(rune(i)), func(t *testing.T) {
			// Setup
			db := setupPropertyTestDB(t)
			service := NewService(db)
			userID := createPropertyTestUser(t, db)

			seed := time.Now().UnixNano() + int64(i)
			r := rand.New(rand.NewSource(seed))

			baseTime := time.Now().Add(-24 * time.Hour)
			lastSyncTime := baseTime.Add(12 * time.Hour)

			// Create entries with timestamps before last sync (should NOT be returned)
			var oldEntries []database.DiaryEntry
			numOldEntries := r.Intn(3) + 1
			
			for j := 0; j < numOldEntries; j++ {
				food := generateRandomFood(t, db, seed+int64(j))
				entry := database.DiaryEntry{
					ID:          uuid.New(),
					UserID:      userID,
					ProfileType: []string{"baby", "mother"}[r.Intn(2)],
					FoodID:      &food.ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					Calories:    food.CaloriesPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Protein:     food.ProteinPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Carbs:       food.CarbsPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Fat:         food.FatPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					EntryDate:   baseTime.AddDate(0, 0, -r.Intn(30)),
					UpdatedAt:   lastSyncTime.Add(-time.Duration(r.Intn(600)+60) * time.Minute), // Before last sync
				}
				db.Create(&entry)
				oldEntries = append(oldEntries, entry)
			}

			// Create entries with timestamps after last sync (SHOULD be returned)
			var newEntries []database.DiaryEntry
			numNewEntries := r.Intn(3) + 1
			
			for j := 0; j < numNewEntries; j++ {
				food := generateRandomFood(t, db, seed+int64(j+100))
				entry := database.DiaryEntry{
					ID:          uuid.New(),
					UserID:      userID,
					ProfileType: []string{"baby", "mother"}[r.Intn(2)],
					FoodID:      &food.ID,
					ServingSize: float64(r.Intn(300)) + 50.0,
					MealTime:    []string{"breakfast", "lunch", "dinner", "snack"}[r.Intn(4)],
					Calories:    food.CaloriesPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Protein:     food.ProteinPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Carbs:       food.CarbsPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					Fat:         food.FatPer100g * (float64(r.Intn(300)) + 50.0) / 100,
					EntryDate:   baseTime.AddDate(0, 0, -r.Intn(30)),
					UpdatedAt:   lastSyncTime.Add(time.Duration(r.Intn(600)+60) * time.Minute), // After last sync
				}
				db.Create(&entry)
				newEntries = append(newEntries, entry)
			}

			// Perform sync
			syncReq := &SyncRequest{
				LastSyncTime: lastSyncTime.Format(time.RFC3339),
				Entries:      []SyncDiaryEntry{},
				DeletedIDs:   []uuid.UUID{},
			}

			response, err := service.SyncDiaryEntries(userID, syncReq)
			require.NoError(t, err)

			// PROPERTY: Only entries updated after last sync should be returned
			assert.Equal(t, numNewEntries, len(response.Entries),
				"Only entries updated after last sync should be returned")

			// Verify returned entries are the new ones
			returnedIDs := make(map[uuid.UUID]bool)
			for _, entry := range response.Entries {
				returnedIDs[entry.ID] = true
			}

			for _, newEntry := range newEntries {
				assert.True(t, returnedIDs[newEntry.ID],
					"New entry should be in sync response")
			}

			for _, oldEntry := range oldEntries {
				assert.False(t, returnedIDs[oldEntry.ID],
					"Old entry should NOT be in sync response")
			}

			// Verify all returned entries have UpdatedAt > lastSyncTime
			for _, entry := range response.Entries {
				assert.True(t, entry.UpdatedAt.After(lastSyncTime),
					"All returned entries should have UpdatedAt after lastSyncTime")
			}
		})
	}
}
