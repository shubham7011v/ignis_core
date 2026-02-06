package handlers

import (
	"net/http"

	"ignis_server/internal/repository"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	userRepo *repository.UserRepository
}

func NewAuthHandler(userRepo *repository.UserRepository) *AuthHandler {
	return &AuthHandler{
		userRepo: userRepo,
	}
}

type VerifyTokenRequest struct {
	// Token is already verified by middleware, we just need to sync user
}

// VerifyToken handles POST /api/auth/verify
// This endpoint syncs the Firebase user to PostgreSQL and returns user data
func (h *AuthHandler) VerifyToken(c *gin.Context) {
	// Get Firebase UID from context (set by auth middleware)
	firebaseUID, exists := c.Get("firebaseUid")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	email, _ := c.Get("userEmail")

	// For now, we'll use email as display name if not provided
	displayName := ""
	photoURL := ""

	if emailStr, ok := email.(string); ok {
		displayName = emailStr
	}

	// Sync user to database
	user, err := h.userRepo.GetOrCreateUser(
		firebaseUID.(string),
		displayName,
		displayName,
		photoURL,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to sync user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"user": user,
	})
}
