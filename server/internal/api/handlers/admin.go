package handlers

import (
	"net/http"

	"ignis_server/internal/repository"

	"github.com/gin-gonic/gin"
)

type AdminHandler struct {
	orderRepo *repository.OrderRepository
}

func NewAdminHandler(orderRepo *repository.OrderRepository) *AdminHandler {
	return &AdminHandler{
		orderRepo: orderRepo,
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

	// TODO: Sync to Firestore
	// TODO: Send FCM notification to user

	c.JSON(http.StatusOK, gin.H{
		"success": true,
	})
}
