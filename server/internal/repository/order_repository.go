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
	          venue, custom_message, status, payment_status, amount_cents, transaction_id)
	          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
	          RETURNING id, created_at`

	err := r.db.QueryRow(
		query,
		order.UserID, order.TemplateID, order.BrideName, order.GroomName, order.WeddingDate,
		order.Venue, order.CustomMessage, order.Status, order.PaymentStatus,
		order.AmountCents, order.TransactionID,
	).Scan(&order.ID, &order.CreatedAt)

	if err != nil {
		return nil, err
	}

	return order, nil
}

// GetByUser returns all orders for a user
func (r *OrderRepository) GetByUser(userID string) ([]models.Order, error) {
	query := `SELECT id, user_id, template_id, bride_name, groom_name, wedding_date,
	          venue, custom_message, status, video_url, payment_status, amount_cents,
	          transaction_id, created_at, delivered_at, downloaded_at, admin_notes
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
		err := rows.Scan(
			&o.ID, &o.UserID, &o.TemplateID, &o.BrideName, &o.GroomName, &o.WeddingDate,
			&o.Venue, &o.CustomMessage, &o.Status, &o.VideoURL, &o.PaymentStatus,
			&o.AmountCents, &o.TransactionID, &o.CreatedAt, &o.DeliveredAt, &o.DownloadedAt, &o.AdminNotes,
		)
		if err != nil {
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
	          transaction_id, created_at, delivered_at, downloaded_at, admin_notes
	          FROM orders WHERE id = $1`

	var o models.Order
	err := r.db.QueryRow(query, id).Scan(
		&o.ID, &o.UserID, &o.TemplateID, &o.BrideName, &o.GroomName, &o.WeddingDate,
		&o.Venue, &o.CustomMessage, &o.Status, &o.VideoURL, &o.PaymentStatus,
		&o.AmountCents, &o.TransactionID, &o.CreatedAt, &o.DeliveredAt, &o.DownloadedAt, &o.AdminNotes,
	)

	if err != nil {
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
	          transaction_id, created_at, delivered_at, downloaded_at, admin_notes
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
		err := rows.Scan(
			&o.ID, &o.UserID, &o.TemplateID, &o.BrideName, &o.GroomName, &o.WeddingDate,
			&o.Venue, &o.CustomMessage, &o.Status, &o.VideoURL, &o.PaymentStatus,
			&o.AmountCents, &o.TransactionID, &o.CreatedAt, &o.DeliveredAt, &o.DownloadedAt, &o.AdminNotes,
		)
		if err != nil {
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
	          transaction_id, created_at, delivered_at, downloaded_at, admin_notes
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
		err := rows.Scan(
			&o.ID, &o.UserID, &o.TemplateID, &o.BrideName, &o.GroomName, &o.WeddingDate,
			&o.Venue, &o.CustomMessage, &o.Status, &o.VideoURL, &o.PaymentStatus,
			&o.AmountCents, &o.TransactionID, &o.CreatedAt, &o.DeliveredAt, &o.DownloadedAt, &o.AdminNotes,
		)
		if err != nil {
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
