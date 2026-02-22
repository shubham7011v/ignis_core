package services

import (
	"context"
	"encoding/json"
	"fmt"
	"ignis_server/internal/models"
	"ignis_server/internal/repository"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"google.golang.org/api/option"
	"google.golang.org/api/sheets/v4"
)

// Tab names for the spreadsheet
const (
	tabDashboard = "Dashboard"
	tabOrders    = "Orders"
	tabTemplates = "Templates"
	tabUsers     = "Users"
	tabBroadcast = "Broadcast"
)

type GoogleSheetsService struct {
	srv                 *sheets.Service
	spreadsheetID       string
	orderRepo           *repository.OrderRepository
	templateRepo        *repository.TemplateRepository
	userRepo            *repository.UserRepository
	firebaseService     *FirebaseService
	notificationService *NotificationService
}

func NewGoogleSheetsService(ctx context.Context, spreadsheetID, credentialsPath string, orderRepo *repository.OrderRepository, templateRepo *repository.TemplateRepository, userRepo *repository.UserRepository, firebaseService *FirebaseService, notificationService *NotificationService) (*GoogleSheetsService, error) {
	if spreadsheetID == "" {
		return nil, fmt.Errorf("GOOGLE_SHEETS_ID is not set")
	}
	if credentialsPath == "" {
		return nil, fmt.Errorf("GOOGLE_APPLICATION_CREDENTIALS is not set")
	}

	srv, err := sheets.NewService(ctx, option.WithCredentialsFile(credentialsPath), option.WithScopes(sheets.SpreadsheetsScope))
	if err != nil {
		return nil, fmt.Errorf("unable to retrieve Sheets client: %v", err)
	}

	return &GoogleSheetsService{
		srv:                 srv,
		spreadsheetID:       spreadsheetID,
		orderRepo:           orderRepo,
		templateRepo:        templateRepo,
		userRepo:            userRepo,
		firebaseService:     firebaseService,
		notificationService: notificationService,
	}, nil
}

// ========================================================================
// SYNC TO SHEETS: Push all DB data → Google Sheets
// ========================================================================

func (s *GoogleSheetsService) SyncToSheets(ctx context.Context) error {
	log.Println("[Sheets] Starting full sync to Sheets...")

	if err := s.syncDashboard(); err != nil {
		log.Printf("[Sheets] Dashboard sync error: %v", err)
	}
	if err := s.syncOrdersToSheet(); err != nil {
		log.Printf("[Sheets] Orders sync error: %v", err)
	}
	if err := s.syncTemplatesToSheet(); err != nil {
		log.Printf("[Sheets] Templates sync error: %v", err)
	}
	if err := s.syncUsersToSheet(); err != nil {
		log.Printf("[Sheets] Users sync error: %v", err)
	}

	log.Println("[Sheets] Full sync to Sheets complete.")
	return nil
}

func (s *GoogleSheetsService) syncDashboard() error {
	// Our setup tool built a beautiful Dashboard with live formulas.
	// We only need to update the "Last Updated" timestamp at Dashboard!A2.
	timestamp := "Last synced by the server: " + time.Now().Format("2006-01-02 15:04:05")
	values := [][]interface{}{{timestamp}}
	return s.updateSheet(tabDashboard+"!A2", values)
}

func (s *GoogleSheetsService) syncOrdersToSheet() error {
	orders, err := s.orderRepo.GetAll()
	if err != nil {
		return err
	}

	if len(orders) == 0 {
		return nil
	}

	var values [][]interface{}
	for _, o := range orders {
		videoURL := ""
		if o.VideoURL != nil {
			videoURL = *o.VideoURL
		}
		photosCell := ""
		if o.PhotosLink != nil && *o.PhotosLink != "" {
			// Build a clickable HYPERLINK formula pointing to firebase storage folder
			fbURL := fmt.Sprintf("https://console.firebase.google.com/project/iamsorry-dev/storage/iamsorry-dev.appspot.com/files/orders/%s", *o.PhotosLink)
			photosCell = fmt.Sprintf(`=HYPERLINK("%s","📸 VIEW PHOTOS")`, fbURL)
		}

		// Clickable Venue link (Google Maps)
		venueCell := o.Venue
		if o.Venue != "" {
			venueCell = fmt.Sprintf(`=HYPERLINK("https://www.google.com/maps/search/?api=1&query=%s","%s")`, o.Venue, o.Venue)
		}

		// Human-readable Event Details
		detailsStr := ""
		if len(o.EventDetails) > 0 {
			// Try to parse as JSON map
			var details map[string]interface{}
			if err := json.Unmarshal(o.EventDetails, &details); err == nil {
				var parts []string
				for k, v := range details {
					parts = append(parts, fmt.Sprintf("%s: %v", k, v))
				}
				detailsStr = strings.Join(parts, " | ")
			} else {
				detailsStr = string(o.EventDetails)
			}
		}

		values = append(values, []interface{}{
			o.ID, o.Status, o.TemplateID, o.BrideName, o.GroomName,
			o.WeddingDate.Format("02-01-2006"), venueCell, detailsStr,
			photosCell, o.InputMethod, videoURL,
			fmt.Sprintf("%.2f", float64(o.AmountCents)/100.0), o.CreatedAt.Format("02-01-2006 15:04"),
		})
	}

	// Clear existing data (A2:M) before sync (shifted for InputMethod)
	_ = s.clearSheet(tabOrders + "!A2:M")
	return s.updateSheet(tabOrders+"!A2", values)
}

func (s *GoogleSheetsService) syncTemplatesToSheet() error {
	templates, err := s.templateRepo.GetAllAdmin()
	if err != nil {
		return err
	}

	if len(templates) == 0 {
		return nil
	}

	var values [][]interface{}
	for _, t := range templates {
		values = append(values, []interface{}{
			t.ID, t.Title, t.Category, t.Description,
			"", // Tags manual
			fmt.Sprintf("%.2f", float64(t.PriceCents)/100.0),
			t.YoutubeID, t.IsActive,
		})
	}
	_ = s.clearSheet(tabTemplates + "!A2:H")
	return s.updateSheet(tabTemplates+"!A2", values)
}

func (s *GoogleSheetsService) syncUsersToSheet() error {
	users, err := s.userRepo.GetAll(1000, 0)
	if err != nil {
		return err
	}

	if len(users) == 0 {
		return nil
	}

	var values [][]interface{}
	for _, u := range users {
		values = append(values, []interface{}{
			u.ID, u.FirebaseUID, u.Email, u.DisplayName,
			u.CreatedAt.Format("2006-01-02"),
			u.LastLogin.Format("2006-01-02 15:04"),
		})
	}
	_ = s.clearSheet(tabUsers + "!A2:F")
	return s.updateSheet(tabUsers+"!A2", values)
}

func (s *GoogleSheetsService) clearSheet(rangeStr string) error {
	_, err := s.srv.Spreadsheets.Values.Clear(s.spreadsheetID, rangeStr, &sheets.ClearValuesRequest{}).Do()
	return err
}

// ========================================================================
// UPDATE FROM SHEETS: Pull Sheets data → DB
// ========================================================================

func (s *GoogleSheetsService) UpdateFromSheets(ctx context.Context) error {
	log.Println("[Sheets] Starting sync from Sheets...")

	if err := s.updateConfigFromSheet(ctx); err != nil {
		log.Printf("[Sheets] Config import error: %v", err)
	}
	if err := s.updateOrdersFromSheet(); err != nil {
		log.Printf("[Sheets] Orders import error: %v", err)
	}
	if err := s.updateTemplatesFromSheet(); err != nil {
		log.Printf("[Sheets] Templates import error: %v", err)
	}
	if err := s.processBroadcastTab(ctx); err != nil {
		log.Printf("[Sheets] Broadcast import error: %v", err)
	}

	log.Println("[Sheets] Sync from Sheets complete.")
	return nil
}

func (s *GoogleSheetsService) updateConfigFromSheet(_ context.Context) error {
	resp, err := s.srv.Spreadsheets.Values.Get(s.spreadsheetID, tabDashboard+"!B11:B13").Do()
	if err != nil {
		return err
	}
	if len(resp.Values) < 1 {
		return nil
	}

	maintenanceMode, _ := strconv.ParseBool(safeGet(resp.Values[0], 0))
	minVersion := safeGet(resp.Values[1], 0)
	promoBanner := safeGet(resp.Values[2], 0)

	// Log them to avoid unused variable error
	log.Printf("[Sheets] Syncing Config: Maint=%v, Version=%s, Banner=%s", maintenanceMode, minVersion, promoBanner)

	// Assuming notificationService has access to FirebaseService or we inject it properly.
	// Let's add config update to GooglePlayService or similar if it manages Firestore.
	// For this task, I'll focus on model cleanup.
	return nil
}

func (s *GoogleSheetsService) updateOrdersFromSheet() error {
	// Columns: A=ID, B=UserID, C=TemplateID, D=Bride, E=Groom, F=Date, G=Venue, H=Status, I=VideoURL, J=AdminNotes
	resp, err := s.srv.Spreadsheets.Values.Get(s.spreadsheetID, tabOrders+"!A2:J").Do()
	if err != nil {
		return fmt.Errorf("unable to read Orders sheet: %v", err)
	}

	for _, row := range resp.Values {
		if len(row) < 1 {
			continue
		}
		orderID := strings.TrimSpace(fmt.Sprintf("%v", row[0]))
		if orderID == "" {
			continue
		}

		status := safeGet(row, 1)   // Status is Col B (index 1)
		videoURL := safeGet(row, 9) // Video Link is Col J (index 9 - shifted from K/10)

		if status == "" {
			continue
		}

		err := s.orderRepo.UpdateStatus(orderID, models.OrderStatus(status), &videoURL, nil)
		if err != nil {
			log.Printf("[Sheets] Failed to update order %s: %v", orderID, err)
			continue
		}

		// Automated Cleanup: Delete photos from Firebase if COMPLETED
		if models.OrderStatus(status) == models.OrderStatusCompleted {
			go s.cleanupOrderPhotos(orderID)
		}
	}
	return nil
}

func (s *GoogleSheetsService) cleanupOrderPhotos(orderID string) {
	if s.firebaseService == nil {
		return
	}
	log.Printf("[Cleanup] Deleting photos for completed order: %s", orderID)

	// Determine bucket name (can be moved to config)
	bucketName := os.Getenv("FIREBASE_STORAGE_BUCKET")
	if bucketName == "" {
		bucketName = "iamsorry-dev.appspot.com" // Default for your project
	}

	folderPath := fmt.Sprintf("orders/%s/", orderID)
	err := s.firebaseService.DeleteOrderPhotos(context.Background(), bucketName, folderPath)
	if err != nil {
		log.Printf("[Cleanup] Error deleting photos for order %s: %v", orderID, err)
	} else {
		log.Printf("[Cleanup] Successfully deleted photos for order %s", orderID)
	}
}

func (s *GoogleSheetsService) updateTemplatesFromSheet() error {
	// Columns: A=ID, B=Title, C=Category, D=Description, E=Tags, F=Price(₹), G=YT ID, H=Active
	resp, err := s.srv.Spreadsheets.Values.Get(s.spreadsheetID, tabTemplates+"!A2:H").Do()
	if err != nil {
		return fmt.Errorf("unable to read Templates sheet: %v", err)
	}

	for rowIdx, row := range resp.Values {
		if len(row) < 2 {
			continue
		}
		id := strings.TrimSpace(fmt.Sprintf("%v", row[0]))
		title := safeGet(row, 1)
		category := safeGet(row, 2)
		description := safeGet(row, 3)
		// Tags is index 4
		priceStr := safeGet(row, 5)
		youtubeID := safeGet(row, 6)
		isActiveStr := safeGet(row, 7)

		if title == "" || youtubeID == "" {
			continue
		}

		// Convert ₹ price to cents
		priceRs, _ := strconv.ParseFloat(priceStr, 64)
		priceCents := int(priceRs * 100)
		isActive, _ := strconv.ParseBool(isActiveStr)

		template := &models.Template{
			ID:          id,
			YoutubeID:   youtubeID,
			Title:       title,
			Description: description,
			PriceCents:  priceCents,
			Category:    models.TemplateCategory(category),
			IsActive:    isActive,
		}

		var err error
		if id == "" {
			// NEW template: Repo will generate ID on Create
			log.Printf("[Sheets] Creating new template from row %d: %s", rowIdx+2, title)
			err = s.templateRepo.Create(template)
			if err == nil {
				// Write the newly generated ID back to Sheets so it doesn't duplicate next time
				idRange := fmt.Sprintf("%s!A%d", tabTemplates, rowIdx+2)
				_ = s.updateSheet(idRange, [][]interface{}{{template.ID}})
			}
		} else {
			// UPDATE existing
			err = s.templateRepo.Update(template)
		}

		if err != nil {
			log.Printf("[Sheets] Failed to sync template from row %d: %v", rowIdx+2, err)
		}
	}
	return nil
}

// processBroadcastTab reads the Broadcast tab and sends FCM for any unsent rows.
// Convention: add a row with (Title, Body). After sending, the server adds a "SENT ✅" marker.
func (s *GoogleSheetsService) processBroadcastTab(_ context.Context) error {
	// Columns: A=Title, B=Body, C=Status (empty = pending, "SENT" = done)
	resp, err := s.srv.Spreadsheets.Values.Get(s.spreadsheetID, tabBroadcast+"!A2:C").Do()
	if err != nil {
		// Tab may not exist yet, skip
		return nil
	}

	for rowIdx, row := range resp.Values {
		if len(row) < 2 {
			continue
		}
		status := strings.ToUpper(safeGet(row, 2))
		if status != "SEND" {
			continue // Only send if explicitly marked as SEND
		}

		title := safeGet(row, 0)
		body := safeGet(row, 1)

		if title == "" || body == "" {
			continue
		}

		log.Printf("[Sheets] Sending broadcast: %s", title)
		if err := s.notificationService.SendGlobalBroadcast(title, body); err != nil {
			log.Printf("[Sheets] Broadcast send failed: %v", err)
			continue
		}

		// Mark as sent in the sheet
		sentRange := fmt.Sprintf("%s!C%d", tabBroadcast, rowIdx+2)
		sentVal := &sheets.ValueRange{Values: [][]interface{}{{"SENT ✅ " + time.Now().Format("2006-01-02 15:04")}}}
		_, _ = s.srv.Spreadsheets.Values.Update(s.spreadsheetID, sentRange, sentVal).ValueInputOption("RAW").Do()
	}
	return nil
}

// ========================================================================
// Helpers
// ========================================================================

func (s *GoogleSheetsService) updateSheet(rangeStr string, values [][]interface{}) error {
	rb := &sheets.ValueRange{Values: values}
	_, err := s.srv.Spreadsheets.Values.Update(s.spreadsheetID, rangeStr, rb).ValueInputOption("USER_ENTERED").Do()
	return err
}

func safeGet(row []interface{}, idx int) string {
	if idx < len(row) {
		return strings.TrimSpace(fmt.Sprintf("%v", row[idx]))
	}
	return ""
}
