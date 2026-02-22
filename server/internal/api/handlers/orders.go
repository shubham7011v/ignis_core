package handlers

import (
	"net/http"
	"path/filepath"
	"strings"
	"time"

	"ignis_server/internal/models"
	"ignis_server/internal/repository"
	"ignis_server/internal/services"

	"github.com/gin-gonic/gin"
)

type OrdersHandler struct {
	orderRepo       *repository.OrderRepository
	templateRepo    *repository.TemplateRepository
	googlePlay      *services.GooglePlayService
	renderOutputDir string
}

func NewOrdersHandler(orderRepo *repository.OrderRepository, templateRepo *repository.TemplateRepository, googlePlay *services.GooglePlayService, renderOutputDir string) *OrdersHandler {
	return &OrdersHandler{
		orderRepo:       orderRepo,
		templateRepo:    templateRepo,
		googlePlay:      googlePlay,
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
	AmountCents   int    `json:"amountCents"` // Optional as server can verify from template
	PurchaseToken string `json:"purchaseToken" binding:"required"`
	ProductID     string `json:"productId" binding:"required"`
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

	// Verify purchase with Google Play
	var transactionID string
	if h.googlePlay != nil {
		playPurchase, err := h.googlePlay.VerifyAndConsumePurchase(c.Request.Context(), req.ProductID, req.PurchaseToken)
		if err != nil {
			c.JSON(http.StatusPaymentRequired, gin.H{"error": "Payment verification failed: " + err.Error()})
			return
		}
		// If verification succeeds, we use the OrderID from Play as the TransactionID
		transactionID = playPurchase.OrderId
	} else {
		// If Google Play Service is not initialized (dev/local), allow mock transaction
		transactionID = "mock_" + time.Now().String()
	}

	// Fetch template to get delivery time SLA
	template, err := h.templateRepo.GetByID(req.TemplateID)
	var dueAt *time.Time
	if err == nil && template != nil {
		d := time.Now().Add(time.Duration(template.DeliveryTimeDays) * 24 * time.Hour)
		dueAt = &d
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
		TransactionID: transactionID,
		DueAt:         dueAt,
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
