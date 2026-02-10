package handlers

import (
	"net/http"
	"path/filepath"
	"strings"
	"time"

	"ignis_server/internal/models"
	"ignis_server/internal/repository"

	"github.com/gin-gonic/gin"
)

type OrdersHandler struct {
	orderRepo       *repository.OrderRepository
	renderOutputDir string
}

func NewOrdersHandler(orderRepo *repository.OrderRepository, renderOutputDir string) *OrdersHandler {
	return &OrdersHandler{
		orderRepo:       orderRepo,
		renderOutputDir: renderOutputDir,
	}
}

// DownloadVideo handles GET /api/orders/download/:filename
func (h *OrdersHandler) DownloadVideo(c *gin.Context) {
	filename := c.Param("filename")
	if filename == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Filename required"})
		return
	}

	// Security check: ensure path is within renderOutputDir and is an mp4
	filePath := filepath.Join(h.renderOutputDir, filename)

	// Basic safety: prevent directory traversal
	if !strings.HasPrefix(filepath.Clean(filePath), filepath.Clean(h.renderOutputDir)) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Invalid path"})
		return
	}

	if !strings.HasSuffix(filename, ".mp4") {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file type"})
		return
	}

	c.File(filePath)
}

type CreateOrderRequest struct {
	TemplateID    string `json:"templateId" binding:"required"`
	BrideName     string `json:"brideName" binding:"required"`
	GroomName     string `json:"groomName" binding:"required"`
	WeddingDate   string `json:"weddingDate" binding:"required"`
	Venue         string `json:"venue"`
	CustomMessage string `json:"customMessage"`
	AmountCents   int    `json:"amountCents" binding:"required"`
	TransactionID string `json:"transactionId" binding:"required"`
}

// CreateOrder handles POST /api/orders
func (h *OrdersHandler) CreateOrder(c *gin.Context) {
	firebaseUID, exists := c.Get("firebaseUid")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req CreateOrderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Parse wedding date
	weddingDate, err := time.Parse("2006-01-02", req.WeddingDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid wedding date format"})
		return
	}

	order := &models.Order{
		UserID:        firebaseUID.(string),
		TemplateID:    req.TemplateID,
		BrideName:     req.BrideName,
		GroomName:     req.GroomName,
		WeddingDate:   weddingDate,
		Venue:         req.Venue,
		CustomMessage: req.CustomMessage,
		Status:        "pending",
		PaymentStatus: "paid",
		AmountCents:   req.AmountCents,
		TransactionID: req.TransactionID,
	}

	createdOrder, err := h.orderRepo.Create(order)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create order"})
		return
	}

	// TODO: Sync to Firestore
	// TODO: Send FCM notification to admins

	c.JSON(http.StatusCreated, gin.H{
		"order": createdOrder,
	})
}

// GetOrders handles GET /api/orders
func (h *OrdersHandler) GetOrders(c *gin.Context) {
	firebaseUID, exists := c.Get("firebaseUid")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	orders, err := h.orderRepo.GetByUser(firebaseUID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch orders"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"orders": orders,
	})
}

// GetOrder handles GET /api/orders/:id
func (h *OrdersHandler) GetOrder(c *gin.Context) {
	id := c.Param("id")

	order, err := h.orderRepo.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Order not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"order": order,
	})
}
