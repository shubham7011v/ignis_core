package middleware

import (
	"net/http"

	"ignis_server/internal/repository"

	"github.com/gin-gonic/gin"
)

type AdminMiddleware struct {
	userRepo *repository.UserRepository
}

func NewAdminMiddleware(userRepo *repository.UserRepository) *AdminMiddleware {
	return &AdminMiddleware{
		userRepo: userRepo,
	}
}

// RequireAdmin checks if the user is an admin
func (m *AdminMiddleware) RequireAdmin() gin.HandlerFunc {
	return func(c *gin.Context) {
		firebaseUID, exists := c.Get("firebaseUid")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
			c.Abort()
			return
		}

		isAdmin, err := m.userRepo.IsAdmin(firebaseUID.(string))
		if err != nil || !isAdmin {
			c.JSON(http.StatusForbidden, gin.H{"error": "Admin access required"})
			c.Abort()
			return
		}

		c.Next()
	}
}
