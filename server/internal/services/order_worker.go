package services

import (
	"context"
	"ignis_server/internal/models"
	"ignis_server/internal/repository"
	"log"
	"path/filepath"
	"time"
)

type OrderWorker struct {
	orderRepo     *repository.OrderRepository
	templateRepo  *repository.TemplateRepository
	renderService *RenderService
	interval      time.Duration
}

func NewOrderWorker(
	orderRepo *repository.OrderRepository,
	templateRepo *repository.TemplateRepository,
	renderService *RenderService,
) *OrderWorker {
	return &OrderWorker{
		orderRepo:     orderRepo,
		templateRepo:  templateRepo,
		renderService: renderService,
		interval:      30 * time.Second, // Poll every 30 seconds
	}
}

// Start runs the background worker loop
func (w *OrderWorker) Start(ctx context.Context) {
	log.Println("Starting automated order fulfillment worker...")
	ticker := time.NewTicker(w.interval)
	defer ticker.Stop()

	// Initial run
	w.processPendingOrders()

	for {
		select {
		case <-ctx.Done():
			log.Println("Stopping order worker...")
			return
		case <-ticker.C:
			w.processPendingOrders()
		}
	}
}

func (w *OrderWorker) processPendingOrders() {
	orders, err := w.orderRepo.GetByStatus("pending")
	if err != nil {
		log.Printf("Worker error: failed to fetch pending orders: %v", err)
		return
	}

	for _, order := range orders {
		log.Printf("[Worker] Processing order %s (template: %s)", order.ID, order.TemplateID)
		w.processOrder(order)
	}
}

func (w *OrderWorker) processOrder(order models.Order) {
	// 1. Fetch template
	template, err := w.templateRepo.GetByID(order.TemplateID)
	if err != nil {
		log.Printf("[Worker] Error: failed to fetch template for order %s: %v", order.ID, err)
		w.handleFailure(order.ID, "Failed to fetch template: "+err.Error())
		return
	}

	// 2. Mark as processing
	err = w.orderRepo.UpdateStatus(order.ID, "processing", nil, nil)
	if err != nil {
		log.Printf("[Worker] Error: failed to update status to processing for order %s: %v", order.ID, err)
		return
	}

	// 3. Render video
	outputPath, err := w.renderService.Render(&order, template)
	if err != nil {
		log.Printf("[Worker] Error: rendering failed for order %s: %v", order.ID, err)
		w.handleFailure(order.ID, "Rendering failed: "+err.Error())
		return
	}

	// 4. Update order with completion
	// In a real app, you'd upload the file to cloud storage here.
	// We'll use the internal file path as a reference for now.
	videoURL := "/api/orders/download/" + filepath.Base(outputPath)

	adminNote := "Automated rendering successful"
	err = w.orderRepo.UpdateStatus(order.ID, "completed", &videoURL, &adminNote)
	if err != nil {
		log.Printf("[Worker] Error: failed to finalize order %s: %v", order.ID, err)
	} else {
		log.Printf("[Worker] Successfully completed order %s", order.ID)
	}
}

func (w *OrderWorker) handleFailure(orderID, message string) {
	status := "failed"
	w.orderRepo.UpdateStatus(orderID, status, nil, &message)
}

func stringsPtr(s string) *string {
	return &s
}
