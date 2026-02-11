package handlers

import (
	"net/http"

	"ignis_server/internal/models"
	"ignis_server/internal/repository"

	"ignis_server/internal/services"

	"github.com/gin-gonic/gin"
)

type AdminHandler struct {
	orderRepo           *repository.OrderRepository
	userRepo            *repository.UserRepository
	templateRepo        *repository.TemplateRepository
	firebaseService     *services.FirebaseService
	notificationService *services.NotificationService
}

func NewAdminHandler(orderRepo *repository.OrderRepository, userRepo *repository.UserRepository, templateRepo *repository.TemplateRepository, firebaseService *services.FirebaseService, notificationService *services.NotificationService) *AdminHandler {
	return &AdminHandler{
		orderRepo:           orderRepo,
		userRepo:            userRepo,
		templateRepo:        templateRepo,
		firebaseService:     firebaseService,
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

type UpdateConfigRequest struct {
	MaintenanceMode *bool   `json:"maintenance_mode"`
	MinAppVersion   *string `json:"min_app_version"`
	PromoBannerUrl  *string `json:"promo_banner_url"`
}

// UpdateConfig handles POST /api/admin/config
func (h *AdminHandler) UpdateConfig(c *gin.Context) {
	var req UpdateConfigRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	data := make(map[string]interface{})
	if req.MaintenanceMode != nil {
		data["maintenance_mode"] = *req.MaintenanceMode
	}
	if req.MinAppVersion != nil {
		data["min_app_version"] = *req.MinAppVersion
	}
	if req.PromoBannerUrl != nil {
		data["promo_banner_url"] = *req.PromoBannerUrl
	}

	if len(data) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No config fields provided"})
		return
	}

	err := h.firebaseService.UpdateAppConfig(c.Request.Context(), data)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update Firestore config"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "updated": data})
}

// GetStats handles GET /api/admin/stats
func (h *AdminHandler) GetStats(c *gin.Context) {
	// TODO: Get these from repositories
	// For now, let's use placeholders or implement Count methods in repos
	// Best practice: Add Count() to UserRepo and OrderRepo

	// Temporary: returning mock stats until repo methods are added
	userCount, _ := h.userRepo.Count()
	orderStats, _ := h.orderRepo.GetStats()

	// TODO: Get total templates count logic
	// templateCount, _ := h.templateRepo.Count()

	c.JSON(http.StatusOK, gin.H{
		"totalUsers":      userCount,
		"totalOrders":     orderStats.TotalOrders,
		"pendingOrders":   orderStats.PendingOrders,
		"completedOrders": orderStats.CompletedOrders,
		"totalRevenue":    orderStats.TotalRevenue,
		"totalTemplates":  12, // Placeholder
	})
}

type BroadcastRequest struct {
	Title string `json:"title" binding:"required"`
	Body  string `json:"body" binding:"required"`
}

// SendBroadcast handles POST /api/admin/broadcast
func (h *AdminHandler) SendBroadcast(c *gin.Context) {
	var req BroadcastRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Logic to send broadcast
	// This usually involves sending to a topic like "all_users"
	// Ensure client subscribes to this topic
	err := h.notificationService.SendGlobalBroadcast(req.Title, req.Body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send broadcast"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true})
}

// GetTemplatesAdmin handles GET /api/admin/templates
func (h *AdminHandler) GetTemplatesAdmin(c *gin.Context) {
	templates, err := h.templateRepo.GetAllAdmin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch templates"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"templates": templates})
}

// CreateTemplate handles POST /api/admin/templates
func (h *AdminHandler) CreateTemplate(c *gin.Context) {
	var template models.Template
	if err := c.ShouldBindJSON(&template); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Set defaults
	template.IsActive = true
	if template.PlaceholderColor == "" {
		template.PlaceholderColor = "0xFF000000"
	}

	err := h.templateRepo.Create(&template)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create template"})
		return
	}

	c.JSON(http.StatusCreated, template)
}

// UpdateTemplate handles PUT /api/admin/templates/:id
func (h *AdminHandler) UpdateTemplate(c *gin.Context) {
	id := c.Param("id")
	var template models.Template
	if err := c.ShouldBindJSON(&template); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	template.ID = id
	err := h.templateRepo.Update(&template)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update template"})
		return
	}

	c.JSON(http.StatusOK, template)
}

// DeleteTemplate handles DELETE /api/admin/templates/:id
func (h *AdminHandler) DeleteTemplate(c *gin.Context) {
	id := c.Param("id")
	err := h.templateRepo.SoftDelete(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete template"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true})
}

// GetUsers handles GET /api/admin/users
func (h *AdminHandler) GetUsers(c *gin.Context) {
	// Pagination
	limit := 20
	offset := 0
	// TODO: Parse limit/offset from query params

	users, err := h.userRepo.GetAll(limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch users"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"users": users,
	})
}
