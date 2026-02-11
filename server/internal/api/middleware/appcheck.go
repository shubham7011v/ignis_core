package middleware

import (
	"context"
	"ignis_server/internal/services"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

type AppCheckMiddleware struct {
	firebaseService *services.FirebaseService
}

func NewAppCheckMiddleware(firebaseService *services.FirebaseService) *AppCheckMiddleware {
	return &AppCheckMiddleware{
		firebaseService: firebaseService,
	}
}

// RequireAppCheck enforces that a valid App Check token is present in the request
func (m *AppCheckMiddleware) RequireAppCheck() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Skip if Firebase Service (and thus App Check) is not initialized (e.g. local dev without creds)
		if m.firebaseService == nil || m.firebaseService.AppCheckClient == nil {
			// WARN: In production, this should likely fail-closed, but for now we Log and Allow
			// to prevent breaking existing flows if misconfigured.
			// log.Println("WARNING: App Check verification skipped (AppCheckClient not initialized)")
			c.Next()
			return
		}

		appCheckToken := c.GetHeader("X-Firebase-AppCheck")
		if appCheckToken == "" {
			log.Printf("App Check verification failed: missing X-Firebase-AppCheck header")
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized: Missing App Check token"})
			return
		}

		// Verify the token
		_, err := m.firebaseService.VerifyAppCheckToken(context.Background(), appCheckToken)
		if err != nil {
			// Log specific error for debugging
			log.Printf("App Check verification failed: %v", err)

			// Check if we should enforce or just warn (Soft enforcement during migration)
			// For now, we return 401 Unauthorized
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized: Invalid App Check token"})
			return
		}

		// Token is valid, proceed
		c.Next()
	}
}
