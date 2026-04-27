package food

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// Handler handles HTTP requests for food operations
type Handler struct {
	service *Service
}

// NewHandler creates a new food handler
func NewHandler(service *Service) *Handler {
	return &Handler{
		service: service,
	}
}

// SearchFoods handles food search requests
// @Summary Search foods
// @Description Search for foods by name and category
// @Tags foods
// @Accept json
// @Produce json
// @Param search query string false "Search term"
// @Param category query string false "Category filter (mpasi or ibu)"
// @Param limit query int false "Result limit"
// @Success 200 {object} SearchResponse
// @Failure 400 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/foods [get]
func (h *Handler) SearchFoods(c *gin.Context) {
	var req SearchRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request parameters",
			"details": err.Error(),
		})
		return
	}

	response, err := h.service.SearchFoods(&req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to search foods",
		})
		return
	}

	c.JSON(http.StatusOK, response)
}

// GetFoodByID handles retrieving a single food by ID
// @Summary Get food by ID
// @Description Retrieve a single food item by its ID
// @Tags foods
// @Accept json
// @Produce json
// @Param id path string true "Food ID"
// @Success 200 {object} database.Food
// @Failure 400 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/foods/{id} [get]
func (h *Handler) GetFoodByID(c *gin.Context) {
	idParam := c.Param("id")
	foodID, err := uuid.Parse(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid food ID",
		})
		return
	}

	food, err := h.service.GetFoodByID(foodID)
	if err != nil {
		if err == ErrFoodNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "Food not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to retrieve food",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"food": food,
	})
}

// SyncFoods handles food synchronization requests
// @Summary Sync foods
// @Description Get foods updated after a given timestamp for offline sync
// @Tags foods
// @Accept json
// @Produce json
// @Param last_sync query string false "Last sync timestamp (ISO 8601)"
// @Success 200 {object} SyncResponse
// @Failure 500 {object} map[string]interface{}
// @Router /api/foods/sync [get]
func (h *Handler) SyncFoods(c *gin.Context) {
	lastSync := c.Query("last_sync")

	response, err := h.service.GetFoodsForSync(lastSync)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to sync foods",
		})
		return
	}

	c.JSON(http.StatusOK, response)
}
