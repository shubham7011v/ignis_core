package repository

import (
	"database/sql"
	"ignis_server/internal/models"
	"time"
)

type OrderRepository struct {
	db *sql.DB
}

func NewOrderRepository(db *sql.DB) *OrderRepository {
	return &OrderRepository{db: db}
}

// Create creates a new order
func (r *OrderRepository) Create(order *models.Order) (*models.Order, error) {
	query := `INSERT INTO orders (user_id, template_id, bride_name, groom_name, wedding_date,
	          venue, custom_message, status, payment_status, amount_cents, transaction_id, photos_link, input_method, event_details, due_at)
	          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
	          RETURNING id, created_at`

	err := r.db.QueryRow(
		query,
		order.UserID, order.TemplateID, order.BrideName, order.GroomName, order.WeddingDate,
		order.Venue, order.CustomMessage, order.Status, order.PaymentStatus,
		order.AmountCents, order.TransactionID, order.PhotosLink, order.InputMethod, order.EventDetails, order.DueAt,
	).Scan(&order.ID, &order.CreatedAt)

	if err != nil {
		return nil, err
	}

	return order, nil
}

// scanOrder reduces duplication for scanning rows
func scanOrder(row interface {
	Scan(dest ...interface{}) error
}, o *models.Order) error {
	return row.Scan(
		&o.ID, &o.UserID, &o.TemplateID, &o.BrideName, &o.GroomName, &o.WeddingDate,
		&o.Venue, &o.CustomMessage, &o.Status, &o.VideoURL, &o.PaymentStatus,
		&o.AmountCents, &o.TransactionID, &o.CreatedAt, &o.DeliveredAt, &o.DownloadedAt, &o.AdminNotes,
		&o.DueAt, &o.PhotosLink, &o.InputMethod, &o.EventDetails,
	)
}

// GetByUser returns all orders for a user
func (r *OrderRepository) GetByUser(userID string) ([]models.Order, error) {
	query := `SELECT id, user_id, template_id, bride_name, groom_name, wedding_date,
	          venue, custom_message, status, video_url, payment_status, amount_cents,
	          transaction_id, created_at, delivered_at, downloaded_at, admin_notes, due_at, photos_link, input_method, event_details
	          FROM orders WHERE user_id = $1
	          ORDER BY created_at DESC`

	rows, err := r.db.Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	orders := []models.Order{}
	for rows.Next() {
		var o models.Order
		if err := scanOrder(rows, &o); err != nil {
			return nil, err
		}
		orders = append(orders, o)
	}

	return orders, nil
}

// GetByID returns a single order by ID
func (r *OrderRepository) GetByID(id string) (*models.Order, error) {
	query := `SELECT id, user_id, template_id, bride_name, groom_name, wedding_date,
	          venue, custom_message, status, video_url, payment_status, amount_cents,
	          transaction_id, created_at, delivered_at, downloaded_at, admin_notes, due_at, photos_link, input_method, event_details
	          FROM orders WHERE id = $1`

	var o models.Order
	if err := scanOrder(r.db.QueryRow(query, id), &o); err != nil {
		return nil, err
	}

	return &o, nil
}

// UpdateStatus updates order status and optional video URL (for admin fulfillment)
func (r *OrderRepository) UpdateStatus(id, status string, videoURL *string, adminNotes *string) error {
	query := `UPDATE orders SET status = $1, video_url = $2, admin_notes = $3, 
	          delivered_at = CASE WHEN $1 = 'completed' THEN $4 ELSE delivered_at END
	          WHERE id = $5`

	now := time.Now()
	_, err := r.db.Exec(query, status, videoURL, adminNotes, now, id)
	return err
}

// GetAll returns all orders (admin only)
func (r *OrderRepository) GetAll() ([]models.Order, error) {
	query := `SELECT id, user_id, template_id, bride_name, groom_name, wedding_date,
	          venue, custom_message, status, video_url, payment_status, amount_cents,
	          transaction_id, created_at, delivered_at, downloaded_at, admin_notes, due_at, photos_link, input_method, event_details
	          FROM orders
	          ORDER BY created_at DESC`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []models.Order
	for rows.Next() {
		var o models.Order
		if err := scanOrder(rows, &o); err != nil {
			return nil, err
		}
		orders = append(orders, o)
	}

	return orders, nil
}

// GetByStatus returns all orders with a specific status
func (r *OrderRepository) GetByStatus(status string) ([]models.Order, error) {
	query := `SELECT id, user_id, template_id, bride_name, groom_name, wedding_date,
	          venue, custom_message, status, video_url, payment_status, amount_cents,
	          transaction_id, created_at, delivered_at, downloaded_at, admin_notes, due_at, photos_link, input_method, event_details
	          FROM orders WHERE status = $1
	          ORDER BY created_at ASC`

	rows, err := r.db.Query(query, status)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []models.Order
	for rows.Next() {
		var o models.Order
		if err := scanOrder(rows, &o); err != nil {
			return nil, err
		}
		orders = append(orders, o)
	}

	return orders, nil
}

// MarkAsDownloaded updates the downloaded_at timestamp for an order
func (r *OrderRepository) MarkAsDownloaded(id string) error {
	query := `UPDATE orders SET downloaded_at = $1 WHERE id = $2`
	_, err := r.db.Exec(query, time.Now(), id)
	return err
}

// OrderStats holds aggregated order statistics
type OrderStats struct {
	TotalOrders     int `json:"totalOrders"`
	PendingOrders   int `json:"pendingOrders"`
	CompletedOrders int `json:"completedOrders"`
	TotalRevenue    int `json:"totalRevenue"`
}

// GetStats returns aggregated order statistics
func (r *OrderRepository) GetStats() (OrderStats, error) {
	var stats OrderStats

	// 1. Total Orders
	err := r.db.QueryRow("SELECT COUNT(*) FROM orders").Scan(&stats.TotalOrders)
	if err != nil {
		return stats, err
	}

	// 2. Pending Orders
	err = r.db.QueryRow("SELECT COUNT(*) FROM orders WHERE status = 'pending'").Scan(&stats.PendingOrders)
	if err != nil {
		return stats, err
	}

	// 3. Completed Orders
	err = r.db.QueryRow("SELECT COUNT(*) FROM orders WHERE status = 'completed'").Scan(&stats.CompletedOrders)
	if err != nil {
		return stats, err
	}

	// 4. Total Revenue (sum of amount_cents for paid/completed orders)
	err = r.db.QueryRow("SELECT COALESCE(SUM(amount_cents), 0) FROM orders WHERE payment_status = 'paid' OR status = 'completed'").Scan(&stats.TotalRevenue)
	if err != nil {
		return stats, err
	}

	return stats, nil
}
