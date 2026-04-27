package recipe

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
	err = db.AutoMigrate(
		&database.User{},
		&database.Recipe{},
		&database.FavoriteRecipe{},
	)
	require.NoError(t, err)

	return db
}

func createTestRecipes(t *testing.T, db *gorm.DB) []database.Recipe {
	recipes := []database.Recipe{
		{
			Name:          "Bubur Ayam Wortel",
			Ingredients:   `["50g beras", "100g ayam giling", "50g wortel"]`,
			Instructions:  "1. Masak beras\n2. Tumis ayam\n3. Kukus wortel",
			NutritionInfo: `{"calories": 180, "protein": 12, "carbs": 25, "fat": 4}`,
			Category:      "mpasi",
		},
		{
			Name:          "Pure Alpukat Pisang",
			Ingredients:   `["1/2 buah alpukat", "1 buah pisang"]`,
			Instructions:  "1. Kerok alpukat\n2. Haluskan pisang\n3. Campurkan",
			NutritionInfo: `{"calories": 150, "protein": 2, "carbs": 20, "fat": 8}`,
			Category:      "mpasi",
		},
		{
			Name:          "Bubur Kentang Brokoli",
			Ingredients:   `["100g kentang", "50g brokoli", "1 butir telur"]`,
			Instructions:  "1. Kukus kentang\n2. Kukus brokoli\n3. Rebus telur",
			NutritionInfo: `{"calories": 160, "protein": 8, "carbs": 22, "fat": 5}`,
			Category:      "mpasi",
		},
	}

	for i := range recipes {
		err := db.Create(&recipes[i]).Error
		require.NoError(t, err)
	}

	return recipes
}

func createTestUser(t *testing.T, db *gorm.DB) database.User {
	user := database.User{
		Email:        "test@example.com",
		PasswordHash: "hashedpassword",
		FullName:     "Test User",
	}

	err := db.Create(&user).Error
	require.NoError(t, err)

	return user
}

func TestSearchRecipes(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	createTestRecipes(t, db)

	t.Run("search all recipes", func(t *testing.T) {
		req := &SearchRequest{
			Category: "",
			Limit:    10,
		}

		response, err := service.SearchRecipes(req)
		require.NoError(t, err)
		assert.Equal(t, int64(3), response.Total)
		assert.Len(t, response.Recipes, 3)
	})

	t.Run("search with category filter", func(t *testing.T) {
		req := &SearchRequest{
			Category: "mpasi",
			Limit:    10,
		}

		response, err := service.SearchRecipes(req)
		require.NoError(t, err)
		assert.Equal(t, int64(3), response.Total)
		assert.Len(t, response.Recipes, 3)
	})

	t.Run("search with limit", func(t *testing.T) {
		req := &SearchRequest{
			Category: "",
			Limit:    2,
		}

		response, err := service.SearchRecipes(req)
		require.NoError(t, err)
		assert.Equal(t, int64(3), response.Total)
		assert.Len(t, response.Recipes, 2)
	})
}

func TestGetRecipeByID(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	recipes := createTestRecipes(t, db)

	t.Run("get existing recipe", func(t *testing.T) {
		recipe, err := service.GetRecipeByID(recipes[0].ID)
		require.NoError(t, err)
		assert.Equal(t, recipes[0].Name, recipe.Name)
		assert.Equal(t, recipes[0].Category, recipe.Category)
	})

	t.Run("get non-existent recipe", func(t *testing.T) {
		nonExistentID := uuid.New()
		recipe, err := service.GetRecipeByID(nonExistentID)
		assert.Error(t, err)
		assert.Equal(t, ErrRecipeNotFound, err)
		assert.Nil(t, recipe)
	})
}

func TestGetRandomRecipe(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	createTestRecipes(t, db)

	t.Run("get random recipe without category", func(t *testing.T) {
		recipe, err := service.GetRandomRecipe("")
		require.NoError(t, err)
		assert.NotNil(t, recipe)
		assert.NotEmpty(t, recipe.Name)
	})

	t.Run("get random recipe with category", func(t *testing.T) {
		recipe, err := service.GetRandomRecipe("mpasi")
		require.NoError(t, err)
		assert.NotNil(t, recipe)
		assert.Equal(t, "mpasi", recipe.Category)
	})

	t.Run("get random recipe with non-existent category", func(t *testing.T) {
		recipe, err := service.GetRandomRecipe("nonexistent")
		assert.Error(t, err)
		assert.Equal(t, ErrRecipeNotFound, err)
		assert.Nil(t, recipe)
	})
}

func TestAddFavorite(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	user := createTestUser(t, db)
	recipes := createTestRecipes(t, db)

	t.Run("add favorite successfully", func(t *testing.T) {
		err := service.AddFavorite(user.ID, recipes[0].ID)
		require.NoError(t, err)

		// Verify favorite was added
		var count int64
		db.Model(&database.FavoriteRecipe{}).
			Where("user_id = ? AND recipe_id = ?", user.ID, recipes[0].ID).
			Count(&count)
		assert.Equal(t, int64(1), count)
	})

	t.Run("add duplicate favorite", func(t *testing.T) {
		// Add first time
		err := service.AddFavorite(user.ID, recipes[1].ID)
		require.NoError(t, err)

		// Try to add again
		err = service.AddFavorite(user.ID, recipes[1].ID)
		assert.Error(t, err)
		assert.Equal(t, ErrFavoriteAlreadyExists, err)
	})

	t.Run("add favorite with non-existent recipe", func(t *testing.T) {
		nonExistentID := uuid.New()
		err := service.AddFavorite(user.ID, nonExistentID)
		assert.Error(t, err)
		assert.Equal(t, ErrRecipeNotFound, err)
	})
}

func TestRemoveFavorite(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	user := createTestUser(t, db)
	recipes := createTestRecipes(t, db)

	t.Run("remove existing favorite", func(t *testing.T) {
		// Add favorite first
		err := service.AddFavorite(user.ID, recipes[0].ID)
		require.NoError(t, err)

		// Remove favorite
		err = service.RemoveFavorite(user.ID, recipes[0].ID)
		require.NoError(t, err)

		// Verify favorite was removed
		var count int64
		db.Model(&database.FavoriteRecipe{}).
			Where("user_id = ? AND recipe_id = ?", user.ID, recipes[0].ID).
			Count(&count)
		assert.Equal(t, int64(0), count)
	})

	t.Run("remove non-existent favorite", func(t *testing.T) {
		err := service.RemoveFavorite(user.ID, recipes[1].ID)
		assert.Error(t, err)
		assert.Equal(t, ErrFavoriteNotFound, err)
	})
}

func TestGetUserFavorites(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	user := createTestUser(t, db)
	recipes := createTestRecipes(t, db)

	t.Run("get favorites for user with no favorites", func(t *testing.T) {
		favorites, err := service.GetUserFavorites(user.ID)
		require.NoError(t, err)
		assert.Empty(t, favorites)
	})

	t.Run("get favorites for user with multiple favorites", func(t *testing.T) {
		// Add multiple favorites
		err := service.AddFavorite(user.ID, recipes[0].ID)
		require.NoError(t, err)
		err = service.AddFavorite(user.ID, recipes[1].ID)
		require.NoError(t, err)

		// Get favorites
		favorites, err := service.GetUserFavorites(user.ID)
		require.NoError(t, err)
		assert.Len(t, favorites, 2)

		// Verify recipes are in favorites
		recipeIDs := []uuid.UUID{favorites[0].ID, favorites[1].ID}
		assert.Contains(t, recipeIDs, recipes[0].ID)
		assert.Contains(t, recipeIDs, recipes[1].ID)
	})
}

func TestIsFavorite(t *testing.T) {
	db := setupTestDB(t)
	service := NewService(db)
	user := createTestUser(t, db)
	recipes := createTestRecipes(t, db)

	t.Run("check non-favorite recipe", func(t *testing.T) {
		isFav, err := service.IsFavorite(user.ID, recipes[0].ID)
		require.NoError(t, err)
		assert.False(t, isFav)
	})

	t.Run("check favorite recipe", func(t *testing.T) {
		// Add favorite
		err := service.AddFavorite(user.ID, recipes[0].ID)
		require.NoError(t, err)

		// Check if favorite
		isFav, err := service.IsFavorite(user.ID, recipes[0].ID)
		require.NoError(t, err)
		assert.True(t, isFav)
	})
}
