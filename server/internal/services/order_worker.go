package services

import (
	"context"
	"ignis_server/internal/models"
	"ignis_server/internal/repository"
	"log"
	"os"
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

	pollTicker := time.NewTicker(w.interval)
	defer pollTicker.Stop()

	// Cleanup ticker - runs every hour
	cleanupTicker := time.NewTicker(1 * time.Hour)
	defer cleanupTicker.Stop()

	// Initial runs
	w.processPendingOrders()
	w.CleanupOldRenders()

	for {
		select {
		case <-ctx.Done():
			log.Println("Stopping order worker...")
			return
		case <-pollTicker.C:
			w.processPendingOrders()
		case <-cleanupTicker.C:
			w.CleanupOldRenders()
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
	// Since we are using the Zero-Storage model, we provide a local download URL.
	// The file will be cleaned up after 24 hours.
	videoURL := "/api/orders/download/" + filepath.Base(outputPath)

	adminNote := "Automated rendering successful (Available for 1 week)"
	err = w.orderRepo.UpdateStatus(order.ID, "completed", &videoURL, &adminNote)
	if err != nil {
		log.Printf("[Worker] Error: failed to finalize order %s: %v", order.ID, err)
	} else {
		log.Printf("[Worker] Successfully completed order %s", order.ID)
	}
}

// CleanupOldRenders deletes files in the output directory that are older than 1 week
func (w *OrderWorker) CleanupOldRenders() {
	log.Println("[Worker] Running scheduled cleanup of old renders...")

	files, err := os.ReadDir(w.renderService.OutputDir)
	if err != nil {
		log.Printf("[Worker] Cleanup error: failed to read output dir: %v", err)
		return
	}

	now := time.Now()
	count := 0

	for _, f := range files {
		if f.IsDir() {
			continue
		}

		info, err := f.Info()
		if err != nil {
			continue
		}

		// Delete if older than 1 week (168 hours)
		if now.Sub(info.ModTime()) > 7*24*time.Hour {
			path := filepath.Join(w.renderService.OutputDir, f.Name())
			if err := os.Remove(path); err != nil {
				log.Printf("[Worker] Cleanup error: failed to delete %s: %v", path, err)
			} else {
				count++
			}
		}
	}

	if count > 0 {
		log.Printf("[Worker] Cleaned up %d expired render file(s)", count)
	}
}

func (w *OrderWorker) handleFailure(orderID, message string) {
	status := "failed"
	w.orderRepo.UpdateStatus(orderID, status, nil, &message)
}

func stringsPtr(s string) *string {
	return &s
}
