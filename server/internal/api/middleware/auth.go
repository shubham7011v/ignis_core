package middleware

import (
	"context"
	"net/http"
	"strings"

	"ignis_server/internal/services"

	"github.com/gin-gonic/gin"
)

type AuthMiddleware struct {
	firebaseService *services.FirebaseService
}

func NewAuthMiddleware(firebaseService *services.FirebaseService) *AuthMiddleware {
	return &AuthMiddleware{
		firebaseService: firebaseService,
	}
}

// RequireAuth middleware verifies Firebase ID token
func (m *AuthMiddleware) RequireAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			c.Abort()
			return
		}

		// Remove "Bearer " prefix
		idToken := strings.TrimPrefix(authHeader, "Bearer ")
		if idToken == authHeader {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization format"})
			c.Abort()
			return
		}

		// Verify token with Firebase
		token, err := m.firebaseService.VerifyIDToken(context.Background(), idToken)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			c.Abort()
			return
		}

		// Attach Firebase UID to context
		c.Set("firebaseUid", token.UID)
		c.Set("userEmail", token.Claims["email"])
		c.Next()
	}
}
