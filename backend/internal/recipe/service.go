package recipe

import (
	"errors"
	"math/rand"
	"nutribunda-backend/internal/database"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrRecipeNotFound         = errors.New("recipe not found")
	ErrFavoriteAlreadyExists  = errors.New("recipe already in favorites")
	ErrFavoriteNotFound       = errors.New("favorite recipe not found")
)

// Service handles recipe operations
type Service struct {
	db *gorm.DB
}

// NewService creates a new recipe service
func NewService(db *gorm.DB) *Service {
	return &Service{
		db: db,
	}
}

// SearchRequest represents recipe search request
type SearchRequest struct {
	Category string `form:"category"` // 'mpasi' or empty for all
	Limit    int    `form:"limit"`
}

// SearchResponse represents recipe search response
type SearchResponse struct {
	Recipes []database.Recipe `json:"recipes"`
	Total   int64             `json:"total"`
}

// SearchRecipes searches for recipes based on filters
func (s *Service) SearchRecipes(req *SearchRequest) (*SearchResponse, error) {
	query := s.db.Model(&database.Recipe{})

	// Apply category filter
	if req.Category != "" {
		query = query.Where("category = ?", req.Category)
	}

	// Count total results
	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, err
	}

	// Apply limit
	if req.Limit > 0 {
		query = query.Limit(req.Limit)
	} else {
		query = query.Limit(50) // Default limit
	}

	// Execute query
	var recipes []database.Recipe
	if err := query.Order("name ASC").Find(&recipes).Error; err != nil {
		return nil, err
	}

	return &SearchResponse{
		Recipes: recipes,
		Total:   total,
	}, nil
}

// GetRecipeByID retrieves a recipe by ID
func (s *Service) GetRecipeByID(recipeID uuid.UUID) (*database.Recipe, error) {
	var recipe database.Recipe
	if err := s.db.Where("id = ?", recipeID).First(&recipe).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrRecipeNotFound
		}
		return nil, err
	}
	return &recipe, nil
}

// GetRandomRecipe retrieves a random recipe for shake-to-recipe feature
func (s *Service) GetRandomRecipe(category string) (*database.Recipe, error) {
	query := s.db.Model(&database.Recipe{})

	// Apply category filter if provided
	if category != "" {
		query = query.Where("category = ?", category)
	}

	// Count total recipes
	var count int64
	if err := query.Count(&count).Error; err != nil {
		return nil, err
	}

	if count == 0 {
		return nil, ErrRecipeNotFound
	}

	// Generate random offset
	rand.Seed(time.Now().UnixNano())
	offset := rand.Intn(int(count))

	// Get random recipe
	var recipe database.Recipe
	if err := query.Offset(offset).Limit(1).First(&recipe).Error; err != nil {
		return nil, err
	}

	return &recipe, nil
}

// AddFavorite adds a recipe to user's favorites
func (s *Service) AddFavorite(userID, recipeID uuid.UUID) error {
	// Check if recipe exists
	var recipe database.Recipe
	if err := s.db.Where("id = ?", recipeID).First(&recipe).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return ErrRecipeNotFound
		}
		return err
	}

	// Check if already favorited
	var existing database.FavoriteRecipe
	err := s.db.Where("user_id = ? AND recipe_id = ?", userID, recipeID).First(&existing).Error
	if err == nil {
		return ErrFavoriteAlreadyExists
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return err
	}

	// Create favorite
	favorite := database.FavoriteRecipe{
		UserID:   userID,
		RecipeID: recipeID,
	}

	if err := s.db.Create(&favorite).Error; err != nil {
		return err
	}

	return nil
}

// RemoveFavorite removes a recipe from user's favorites
func (s *Service) RemoveFavorite(userID, recipeID uuid.UUID) error {
	result := s.db.Where("user_id = ? AND recipe_id = ?", userID, recipeID).
		Delete(&database.FavoriteRecipe{})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return ErrFavoriteNotFound
	}

	return nil
}

// GetUserFavorites retrieves all favorite recipes for a user
func (s *Service) GetUserFavorites(userID uuid.UUID) ([]database.Recipe, error) {
	var favorites []database.FavoriteRecipe
	if err := s.db.Where("user_id = ?", userID).
		Preload("Recipe").
		Order("created_at DESC").
		Find(&favorites).Error; err != nil {
		return nil, err
	}

	// Extract recipes from favorites
	recipes := make([]database.Recipe, len(favorites))
	for i, fav := range favorites {
		recipes[i] = fav.Recipe
	}

	return recipes, nil
}

// IsFavorite checks if a recipe is in user's favorites
func (s *Service) IsFavorite(userID, recipeID uuid.UUID) (bool, error) {
	var count int64
	if err := s.db.Model(&database.FavoriteRecipe{}).
		Where("user_id = ? AND recipe_id = ?", userID, recipeID).
		Count(&count).Error; err != nil {
		return false, err
	}

	return count > 0, nil
}
