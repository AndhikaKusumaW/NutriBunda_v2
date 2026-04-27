package food

import (
	"errors"
	"nutribunda-backend/internal/database"
	"strings"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrFoodNotFound = errors.New("food not found")
)

// Service handles food operations
type Service struct {
	db *gorm.DB
}

// NewService creates a new food service
func NewService(db *gorm.DB) *Service {
	return &Service{
		db: db,
	}
}

// SearchRequest represents food search request
type SearchRequest struct {
	Query    string `form:"search"`
	Category string `form:"category"` // 'mpasi', 'ibu', or empty for all
	Limit    int    `form:"limit"`
}

// SearchResponse represents food search response
type SearchResponse struct {
	Foods []database.Food `json:"foods"`
	Total int64           `json:"total"`
}

// SearchFoods searches for foods based on query and filters
func (s *Service) SearchFoods(req *SearchRequest) (*SearchResponse, error) {
	query := s.db.Model(&database.Food{})

	// Apply search filter
	if req.Query != "" {
		searchTerm := "%" + strings.ToLower(req.Query) + "%"
		query = query.Where("LOWER(name) LIKE ?", searchTerm)
	}

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
	var foods []database.Food
	if err := query.Order("name ASC").Find(&foods).Error; err != nil {
		return nil, err
	}

	return &SearchResponse{
		Foods: foods,
		Total: total,
	}, nil
}

// GetFoodByID retrieves a food by ID
func (s *Service) GetFoodByID(foodID uuid.UUID) (*database.Food, error) {
	var food database.Food
	if err := s.db.Where("id = ?", foodID).First(&food).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrFoodNotFound
		}
		return nil, err
	}
	return &food, nil
}

// GetAllFoods retrieves all foods (for sync purposes)
func (s *Service) GetAllFoods() ([]database.Food, error) {
	var foods []database.Food
	if err := s.db.Order("name ASC").Find(&foods).Error; err != nil {
		return nil, err
	}
	return foods, nil
}

// SyncResponse represents sync response with timestamp support
type SyncResponse struct {
	Foods      []database.Food `json:"foods"`
	DeletedIDs []string        `json:"deleted_ids"`
}

// GetFoodsForSync retrieves foods updated after a given timestamp
func (s *Service) GetFoodsForSync(lastSync string) (*SyncResponse, error) {
	var foods []database.Food

	query := s.db.Model(&database.Food{})
	if lastSync != "" {
		query = query.Where("created_at > ?", lastSync)
	}

	if err := query.Order("created_at ASC").Find(&foods).Error; err != nil {
		return nil, err
	}

	// For now, we don't track deletions
	// In a production system, you'd have a soft delete mechanism
	return &SyncResponse{
		Foods:      foods,
		DeletedIDs: []string{},
	}, nil
}
