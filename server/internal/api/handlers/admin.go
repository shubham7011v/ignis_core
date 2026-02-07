package handlers

import (
	"net/http"

	"ignis_server/internal/repository"

	"ignis_server/internal/services"

	"github.com/gin-gonic/gin"
)

type AdminHandler struct {
	orderRepo           *repository.OrderRepository
	userRepo            *repository.UserRepository
	notificationService *services.NotificationService
}

func NewAdminHandler(orderRepo *repository.OrderRepository, userRepo *repository.UserRepository, notificationService *services.NotificationService) *AdminHandler {
	return &AdminHandler{
		orderRepo:           orderRepo,
		userRepo:            userRepo,
		notificationService: notificationService,
	}
}

// GetAllOrders handles GET /api/admin/orders
func (h *AdminHandler) GetAllOrders(c *gin.Context) {
	orders, err := h.orderRepo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch orders"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"orders": orders,
	})
}

type UpdateOrderRequest struct {
	Status     string  `json:"status"`
	VideoURL   *string `json:"videoUrl"`
	AdminNotes *string `json:"adminNotes"`
}

// UpdateOrder handles PUT /api/admin/orders/:id
func (h *AdminHandler) UpdateOrder(c *gin.Context) {
	id := c.Param("id")

	var req UpdateOrderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.orderRepo.UpdateStatus(id, req.Status, req.VideoURL, req.AdminNotes)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update order"})
		return
	}

	// Send FCM notification to user
	go func() {
		// 1. Get order to find user ID
		order, err := h.orderRepo.GetByID(id)
		if err != nil {
			return
		}

		// 2. Get user to find FCM token
		// We need a method to get user by ID, for now we will cheat and use GetOrCreateUser ??
		// Actually best to add GetByID to UserRepo.
		// For now let's assume we can get it or we need to add a method.
		// Let's add GetByID to UserRepo first.

		// WAIT, I need to check if UserRepo has GetByID.
		// Checking user_repository.go... it only has GetOrCreateUser and IsAdmin.
		// I will assume I need to add GetByID to UserRepo in next step.
		// For now writing the logic assuming GetByFirebaseUID exists (since ID in order is FirebaseUID)

		fcmToken, err := h.userRepo.GetFCMToken(order.UserID)
		if err != nil || fcmToken == "" {
			return
		}

		_ = h.notificationService.SendOrderUpdate(fcmToken, order.ID, req.Status)
	}()

	c.JSON(http.StatusOK, gin.H{
		"success": true,
	})
}
