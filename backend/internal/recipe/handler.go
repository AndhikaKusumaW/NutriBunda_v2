package recipe

import (
	"net/http"
	"nutribunda-backend/internal/auth"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// Handler handles HTTP requests for recipe operations
type Handler struct {
	service *Service
}

// NewHandler creates a new recipe handler
func NewHandler(service *Service) *Handler {
	return &Handler{
		service: service,
	}
}

// SearchRecipes handles recipe search requests
// @Summary Search recipes
// @Description Search for recipes by category
// @Tags recipes
// @Accept json
// @Produce json
// @Param category query string false "Category filter (mpasi)"
// @Param limit query int false "Result limit"
// @Success 200 {object} SearchResponse
// @Failure 400 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/recipes [get]
func (h *Handler) SearchRecipes(c *gin.Context) {
	var req SearchRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request parameters",
			"details": err.Error(),
		})
		return
	}

	response, err := h.service.SearchRecipes(&req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to search recipes",
		})
		return
	}

	c.JSON(http.StatusOK, response)
}

// GetRecipeByID handles retrieving a single recipe by ID
// @Summary Get recipe by ID
// @Description Retrieve a single recipe by its ID
// @Tags recipes
// @Accept json
// @Produce json
// @Param id path string true "Recipe ID"
// @Success 200 {object} database.Recipe
// @Failure 400 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/recipes/{id} [get]
func (h *Handler) GetRecipeByID(c *gin.Context) {
	idParam := c.Param("id")
	recipeID, err := uuid.Parse(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid recipe ID",
		})
		return
	}

	recipe, err := h.service.GetRecipeByID(recipeID)
	if err != nil {
		if err == ErrRecipeNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "Recipe not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to retrieve recipe",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"recipe": recipe,
	})
}

// GetRandomRecipe handles retrieving a random recipe for shake-to-recipe feature
// @Summary Get random recipe
// @Description Retrieve a random recipe, optionally filtered by category
// @Tags recipes
// @Accept json
// @Produce json
// @Param category query string false "Category filter (mpasi)"
// @Success 200 {object} database.Recipe
// @Failure 404 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/recipes/random [get]
func (h *Handler) GetRandomRecipe(c *gin.Context) {
	category := c.Query("category")

	recipe, err := h.service.GetRandomRecipe(category)
	if err != nil {
		if err == ErrRecipeNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "No recipes found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to retrieve random recipe",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"recipe": recipe,
	})
}

// AddFavorite handles adding a recipe to user's favorites
// @Summary Add recipe to favorites
// @Description Add a recipe to the authenticated user's favorites
// @Tags recipes
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Recipe ID"
// @Success 201 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Failure 409 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/recipes/{id}/favorite [post]
func (h *Handler) AddFavorite(c *gin.Context) {
	// Get user ID from context (set by JWT middleware)
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	// Parse recipe ID
	idParam := c.Param("id")
	recipeID, err := uuid.Parse(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid recipe ID",
		})
		return
	}

	// Add to favorites
	if err := h.service.AddFavorite(userID, recipeID); err != nil {
		if err == ErrRecipeNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "Recipe not found",
			})
			return
		}
		if err == ErrFavoriteAlreadyExists {
			c.JSON(http.StatusConflict, gin.H{
				"error": "Recipe already in favorites",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to add recipe to favorites",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Recipe added to favorites",
	})
}

// RemoveFavorite handles removing a recipe from user's favorites
// @Summary Remove recipe from favorites
// @Description Remove a recipe from the authenticated user's favorites
// @Tags recipes
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param id path string true "Recipe ID"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/recipes/{id}/favorite [delete]
func (h *Handler) RemoveFavorite(c *gin.Context) {
	// Get user ID from context (set by JWT middleware)
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	// Parse recipe ID
	idParam := c.Param("id")
	recipeID, err := uuid.Parse(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid recipe ID",
		})
		return
	}

	// Remove from favorites
	if err := h.service.RemoveFavorite(userID, recipeID); err != nil {
		if err == ErrFavoriteNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "Favorite recipe not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to remove recipe from favorites",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Recipe removed from favorites",
	})
}

// GetFavorites handles retrieving all favorite recipes for the authenticated user
// @Summary Get favorite recipes
// @Description Retrieve all favorite recipes for the authenticated user
// @Tags recipes
// @Accept json
// @Produce json
// @Security BearerAuth
// @Success 200 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Failure 500 {object} map[string]interface{}
// @Router /api/recipes/favorites [get]
func (h *Handler) GetFavorites(c *gin.Context) {
	// Get user ID from context (set by JWT middleware)
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	// Get favorites
	recipes, err := h.service.GetUserFavorites(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to retrieve favorite recipes",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"recipes": recipes,
	})
}
