package main

import (
	"log"

	"ignis_server/db"
	"ignis_server/internal/api/handlers"
	"ignis_server/internal/api/middleware"
	"ignis_server/internal/repository"
	"ignis_server/internal/services"
	"ignis_server/pkg/config"

	"github.com/gin-gonic/gin"
)

// Version is injected at build time via ldflags
var Version = "dev"

func main() {
	// Load configuration
	cfg := config.Load()

	// Initialize database
	database, err := db.InitDB(cfg.GetDBConnectionString())
	if err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.Close()

	// Initialize Firebase service (optional)
	firebaseService, err := services.NewFirebaseService(cfg.FirebaseCredentialsPath, cfg.FirebaseCredentialsJSON)
	if err != nil {
		log.Printf("WARNING: Firebase not initialized: %v (continuing without Firebase)", err)
		firebaseService = nil
	}

	// Initialize sharing service
	sharingService := services.NewSharingService("https://iamsorry.in")

	// Initialize repositories
	userRepo := repository.NewUserRepository(database)
	templateRepo := repository.NewTemplateRepository(database)
	shortsRepo := repository.NewShortsRepository(database)
	orderRepo := repository.NewOrderRepository(database)

	// Initialize notification service
	notificationService := services.NewNotificationService(firebaseService)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(userRepo)
	templatesHandler := handlers.NewTemplatesHandler(templateRepo)
	shortsHandler := handlers.NewShortsHandler(shortsRepo)
	ordersHandler := handlers.NewOrdersHandler(orderRepo)
	adminHandler := handlers.NewAdminHandler(orderRepo, userRepo, notificationService)
	sharingHandler := handlers.NewSharingHandler(sharingService, shortsRepo, templateRepo)

	// Initialize middleware
	authMiddleware := middleware.NewAuthMiddleware(firebaseService)
	adminMiddleware := middleware.NewAdminMiddleware(userRepo)

	// Setup Gin router
	router := gin.Default()

	// CORS middleware
	router.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", cfg.AllowedOrigins)
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// Health check
	router.GET("/health", func(c *gin.Context) {
		if err := database.Ping(); err != nil {
			c.JSON(503, gin.H{
				"status":  "error",
				"service": "vites-api",
				"error":   "Database unreachable",
			})
			return
		}
		c.JSON(200, gin.H{
			"status":  "ok",
			"service": "vites-api",
			"version": Version,
		})
	})

	// Version check (for deployment verification)
	router.GET("/api/version", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"service": "vites-api",
			"version": Version,
		})
	})

	// Deep Linking & Domain Association
	router.GET("/.well-known/apple-app-site-association", sharingHandler.HandleAppleAppSiteAssociation)
	router.GET("/apple-app-site-association", sharingHandler.HandleAppleAppSiteAssociation)
	router.GET("/.well-known/assetlinks.json", sharingHandler.HandleAssetLinks)

	// Sharing Redirects
	router.GET("/s/:id", sharingHandler.HandleShortLink)
	router.GET("/v/:id", sharingHandler.HandleShortLink) // Placeholder for template link

	// API routes
	api := router.Group("/api")
	{
		// Auth (protected)
		auth := api.Group("/auth")
		auth.Use(authMiddleware.RequireAuth())
		{
			auth.POST("/verify", authHandler.VerifyToken)
		}

		// Templates (public)
		templates := api.Group("/templates")
		{
			templates.GET("", templatesHandler.GetTemplates)
			templates.GET("/:id", templatesHandler.GetTemplate)
		}

		// Shorts (protected)
		shorts := api.Group("/shorts")
		shorts.Use(authMiddleware.RequireAuth())
		{
			shorts.GET("", shortsHandler.GetShorts)
			shorts.GET("/favorites", shortsHandler.GetFavorites)
			shorts.POST("/:id/favorite", shortsHandler.ToggleFavorite)
			shorts.DELETE("/:id/favorite", shortsHandler.ToggleFavorite)
		}

		// Orders (protected)
		orders := api.Group("/orders")
		orders.Use(authMiddleware.RequireAuth())
		{
			orders.POST("", ordersHandler.CreateOrder)
			orders.GET("", ordersHandler.GetOrders)
			orders.GET("/:id", ordersHandler.GetOrder)
		}

		// Admin (protected + admin only)
		admin := api.Group("/admin")
		admin.Use(authMiddleware.RequireAuth())
		admin.Use(adminMiddleware.RequireAdmin())
		{
			admin.GET("/orders", adminHandler.GetAllOrders)
			admin.PUT("/orders/:id", adminHandler.UpdateOrder)
		}
	}

	// Start server
	log.Printf("Ignis Server %s starting on port %s...", Version, cfg.Port)
	if err := router.Run(":" + cfg.Port); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
