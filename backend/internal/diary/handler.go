package diary

import (
	"net/http"
	"nutribunda-backend/internal/auth"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// Handler handles HTTP requests for diary operations
type Handler struct {
	service *Service
}

// NewHandler creates a new diary handler
func NewHandler(service *Service) *Handler {
	return &Handler{
		service: service,
	}
}

// CreateEntry handles creating a new diary entry
// @Summary Create diary entry
// @Description Create a new food diary entry for baby or mother profile
// @Tags diary
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param entry body CreateEntryRequest true "Diary entry data"
// @Success 201 {object} database.DiaryEntry
// @Failure 400 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/diary [post]
func (h *Handler) CreateEntry(c *gin.Context) {
	// Get user ID from context
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	// Bind request
	var req CreateEntryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	// Create entry
	entry, err := h.service.CreateEntry(userID, &req)
	if err != nil {
		switch err {
		case ErrInvalidProfileType:
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Invalid profile type, must be 'baby' or 'mother'",
			})
		case ErrInvalidMealTime:
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Invalid meal time, must be 'breakfast', 'lunch', 'dinner', or 'snack'",
			})
		case ErrFoodNotFound:
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Food not found",
			})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   "Failed to create diary entry",
				"details": err.Error(),
			})
		}
		return
	}

	c.JSON(http.StatusCreated, entry)
}

// GetEntries handles retrieving diary entries for a specific profile and date
// @Summary Get diary entries
// @Description Get all diary entries for a specific profile and date with nutrition summary
// @Tags diary
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param profile query string true "Profile type (baby or mother)"
// @Param date query string true "Entry date (YYYY-MM-DD)"
// @Success 200 {object} GetEntriesResponse
// @Failure 400 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/diary [get]
func (h *Handler) GetEntries(c *gin.Context) {
	// Get user ID from context
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	// Bind query parameters
	var req GetEntriesRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid query parameters",
			"details": err.Error(),
		})
		return
	}

	// Get entries
	response, err := h.service.GetEntries(userID, &req)
	if err != nil {
		if err == ErrInvalidProfileType {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Invalid profile type, must be 'baby' or 'mother'",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to retrieve diary entries",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, response)
}

// DeleteEntry handles deleting a diary entry
// @Summary Delete diary entry
// @Description Delete a diary entry by ID
// @Tags diary
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Entry ID"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/diary/{id} [delete]
func (h *Handler) DeleteEntry(c *gin.Context) {
	// Get user ID from context
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	// Parse entry ID
	idParam := c.Param("id")
	entryID, err := uuid.Parse(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid entry ID",
		})
		return
	}

	// Delete entry
	if err := h.service.DeleteEntry(userID, entryID); err != nil {
		switch err {
		case ErrDiaryEntryNotFound:
			c.JSON(http.StatusNotFound, gin.H{
				"error": "Diary entry not found",
			})
		case ErrUnauthorized:
			c.JSON(http.StatusForbidden, gin.H{
				"error": "You don't have permission to delete this entry",
			})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "Failed to delete diary entry",
			})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Diary entry deleted successfully",
	})
}

// SyncEntries handles synchronizing diary entries between client and server
// @Summary Sync diary entries
// @Description Synchronize diary entries with conflict detection and resolution
// @Tags diary
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param sync body SyncRequest true "Sync data"
// @Success 200 {object} SyncResponse
// @Failure 400 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/diary/sync [post]
func (h *Handler) SyncEntries(c *gin.Context) {
	// Get user ID from context
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	// Bind request
	var req SyncRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	// Perform sync
	response, err := h.service.SyncDiaryEntries(userID, &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to sync diary entries",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, response)
}

// ResolveConflict handles resolving a sync conflict
// @Summary Resolve sync conflict
// @Description Resolve a sync conflict by choosing client or server version
// @Tags diary
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param conflict body ResolveConflictRequest true "Conflict resolution data"
// @Success 200 {object} database.DiaryEntry
// @Failure 400 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/diary/resolve-conflict [post]
func (h *Handler) ResolveConflict(c *gin.Context) {
	// Get user ID from context
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	// Bind request
	var req ResolveConflictRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	// Resolve conflict
	entry, err := h.service.ResolveConflict(userID, &req)
	if err != nil {
		switch err {
		case ErrDiaryEntryNotFound:
			c.JSON(http.StatusNotFound, gin.H{
				"error": "Diary entry not found",
			})
		default:
			c.JSON(http.StatusBadRequest, gin.H{
				"error":   "Failed to resolve conflict",
				"details": err.Error(),
			})
		}
		return
	}

	c.JSON(http.StatusOK, entry)
}
