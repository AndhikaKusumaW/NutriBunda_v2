package user

import (
	"net/http"
	"nutribunda-backend/internal/auth"

	"github.com/gin-gonic/gin"
)

// Handler handles HTTP requests for user profile
type Handler struct {
	service *Service
}

// NewHandler creates a new user handler
func NewHandler(service *Service) *Handler {
	return &Handler{
		service: service,
	}
}

// GetProfile retrieves the current user's profile
// @Summary Get user profile
// @Description Get the authenticated user's profile information
// @Tags profile
// @Security BearerAuth
// @Produce json
// @Success 200 {object} database.User
// @Failure 401 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Router /api/profile [get]
func (h *Handler) GetProfile(c *gin.Context) {
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	user, err := h.service.GetProfile(userID)
	if err != nil {
		if err == ErrUserNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "User not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to retrieve profile",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"user": user,
	})
}

// UpdateProfile updates the current user's profile
// @Summary Update user profile
// @Description Update the authenticated user's profile information
// @Tags profile
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param request body UpdateProfileRequest true "Profile update data"
// @Success 200 {object} database.User
// @Failure 400 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Router /api/profile [put]
func (h *Handler) UpdateProfile(c *gin.Context) {
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	var req UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request data",
			"details": err.Error(),
		})
		return
	}

	user, err := h.service.UpdateProfile(userID, &req)
	if err != nil {
		switch err {
		case ErrInvalidWeight:
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Weight must be between 30 and 200 kg",
			})
		case ErrInvalidHeight:
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Height must be between 100 and 250 cm",
			})
		case ErrUserNotFound:
			c.JSON(http.StatusNotFound, gin.H{
				"error": "User not found",
			})
		default:
			c.JSON(http.StatusBadRequest, gin.H{
				"error":   "Failed to update profile",
				"details": err.Error(),
			})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Profile updated successfully",
		"user":    user,
	})
}

// UploadProfileImage uploads a profile image
// @Summary Upload profile image
// @Description Upload and compress a profile image for the authenticated user
// @Tags profile
// @Security BearerAuth
// @Accept multipart/form-data
// @Produce json
// @Param image formData file true "Profile image (JPEG or PNG, max 10MB)"
// @Success 200 {object} database.User
// @Failure 400 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Router /api/profile/upload-image [post]
func (h *Handler) UploadProfileImage(c *gin.Context) {
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	// Get uploaded file
	fileHeader, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Image file is required",
		})
		return
	}

	user, err := h.service.UploadProfileImage(userID, fileHeader)
	if err != nil {
		switch err {
		case ErrImageTooLarge:
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Image size exceeds 10MB limit",
			})
		case ErrInvalidImageFormat:
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Invalid image format, only JPEG and PNG are supported",
			})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   "Failed to upload image",
				"details": err.Error(),
			})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Profile image uploaded successfully",
		"user":    user,
	})
}

// DeleteProfileImage deletes the user's profile image
// @Summary Delete profile image
// @Description Delete the authenticated user's profile image
// @Tags profile
// @Security BearerAuth
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Router /api/profile/image [delete]
func (h *Handler) DeleteProfileImage(c *gin.Context) {
	userID, err := auth.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	if err := h.service.DeleteProfileImage(userID); err != nil {
		if err == ErrUserNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "User not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to delete profile image",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Profile image deleted successfully",
	})
}
