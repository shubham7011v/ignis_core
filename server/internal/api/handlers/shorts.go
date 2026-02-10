package handlers

import (
	"net/http"

	"ignis_server/internal/repository"

	"github.com/gin-gonic/gin"
)

type ShortsHandler struct {
	shortsRepo *repository.ShortsRepository
}

func NewShortsHandler(shortsRepo *repository.ShortsRepository) *ShortsHandler {
	return &ShortsHandler{
		shortsRepo: shortsRepo,
	}
}

// GetShorts handles GET /api/shorts
// Returns templates formatted for the shorts feed
func (h *ShortsHandler) GetShorts(c *gin.Context) {
	// Get user ID from context (set by auth middleware)
	firebaseUID, exists := c.Get("firebaseUid")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	templates, err := h.shortsRepo.GetRandomShorts(firebaseUID.(string), 50)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch shorts: " + err.Error()})
		return
	}

	// Increment view count for each template (async would be better in production)
	for _, template := range templates {
		_ = h.shortsRepo.IncrementViewCount(template.ID)
	}

	c.JSON(http.StatusOK, gin.H{
		"shorts": templates, // Flutter will map this to Short entities
	})
}

// GetFavorites handles GET /api/shorts/favorites
func (h *ShortsHandler) GetFavorites(c *gin.Context) {
	firebaseUID, exists := c.Get("firebaseUid")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	templates, err := h.shortsRepo.GetFavorites(firebaseUID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch favorites"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"shorts": templates,
	})
}

// ToggleFavorite handles POST/DELETE /api/shorts/:id/favorite
func (h *ShortsHandler) ToggleFavorite(c *gin.Context) {
	firebaseUID, exists := c.Get("firebaseUid")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	templateID := c.Param("id") // Now expecting template ID

	err := h.shortsRepo.ToggleFavorite(firebaseUID.(string), templateID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to toggle favorite"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
	})
}
