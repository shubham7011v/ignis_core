package repository

import (
	"database/sql"
	"ignis_server/internal/models"

	"github.com/lib/pq"
)

type TemplateRepository struct {
	db *sql.DB
}

func NewTemplateRepository(db *sql.DB) *TemplateRepository {
	return &TemplateRepository{db: db}
}

// GetAll returns all active templates
func (r *TemplateRepository) GetAll() ([]models.Template, error) {
	query := `SELECT id, youtube_id, thumbnail_url, placeholder_color, view_count,
	          title, description, price_cents, category, tags, overlay_config, is_active, created_at, updated_at
	          FROM templates WHERE is_active = true
	          ORDER BY created_at DESC`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var templates []models.Template
	for rows.Next() {
		var t models.Template
		err := rows.Scan(
			&t.ID, &t.YoutubeID, &t.ThumbnailURL, &t.PlaceholderColor, &t.ViewCount,
			&t.Title, &t.Description, &t.PriceCents, &t.Category, (*pq.StringArray)(&t.Tags),
			&t.OverlayConfig, &t.IsActive, &t.CreatedAt, &t.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		templates = append(templates, t)
	}

	return templates, nil
}

// GetByID returns a single template by ID
func (r *TemplateRepository) GetByID(id string) (*models.Template, error) {
	query := `SELECT id, youtube_id, thumbnail_url, placeholder_color, view_count,
              title, description, price_cents, category, tags, overlay_config, is_active, created_at, updated_at
              FROM templates WHERE id = $1`

	var t models.Template
	err := r.db.QueryRow(query, id).Scan(
		&t.ID, &t.YoutubeID, &t.ThumbnailURL, &t.PlaceholderColor, &t.ViewCount,
		&t.Title, &t.Description, &t.PriceCents, &t.Category, (*pq.StringArray)(&t.Tags),
		&t.OverlayConfig, &t.IsActive, &t.CreatedAt, &t.UpdatedAt,
	)

	if err != nil {
		return nil, err
	}

	return &t, nil
}

// Create adds a new template
func (r *TemplateRepository) Create(t *models.Template) error {
	query := `INSERT INTO templates (youtube_id, thumbnail_url, placeholder_color,
	          title, description, price_cents, category, tags, overlay_config, is_active)
	          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	          RETURNING id, created_at, updated_at`

	return r.db.QueryRow(
		query,
		t.YoutubeID, t.ThumbnailURL, t.PlaceholderColor,
		t.Title, t.Description, t.PriceCents, t.Category, pq.StringArray(t.Tags),
		t.OverlayConfig, t.IsActive,
	).Scan(&t.ID, &t.CreatedAt, &t.UpdatedAt)
}

// Update modifies an existing template
func (r *TemplateRepository) Update(t *models.Template) error {
	query := `UPDATE templates SET youtube_id = $1, thumbnail_url = $2, placeholder_color = $3,
	          title = $4, description = $5, price_cents = $6, category = $7, tags = $8, overlay_config = $9,
	          is_active = $10, updated_at = NOW()
	          WHERE id = $11
	          RETURNING updated_at`

	return r.db.QueryRow(
		query,
		t.YoutubeID, t.ThumbnailURL, t.PlaceholderColor,
		t.Title, t.Description, t.PriceCents, t.Category, pq.StringArray(t.Tags),
		t.OverlayConfig, t.IsActive, t.ID,
	).Scan(&t.UpdatedAt)
}

// SoftDelete marks a template as inactive
func (r *TemplateRepository) SoftDelete(id string) error {
	_, err := r.db.Exec("UPDATE templates SET is_active = false WHERE id = $1", id)
	return err
}

// GetAllAdmin returns all templates (including inactive) for admin dashboard
func (r *TemplateRepository) GetAllAdmin() ([]models.Template, error) {
	query := `SELECT id, youtube_id, thumbnail_url, placeholder_color, view_count,
	          title, description, price_cents, category, tags, overlay_config, is_active, created_at, updated_at
	          FROM templates
	          ORDER BY created_at DESC`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var templates []models.Template
	for rows.Next() {
		var t models.Template
		err := rows.Scan(
			&t.ID, &t.YoutubeID, &t.ThumbnailURL, &t.PlaceholderColor, &t.ViewCount,
			&t.Title, &t.Description, &t.PriceCents, &t.Category, (*pq.StringArray)(&t.Tags),
			&t.OverlayConfig, &t.IsActive, &t.CreatedAt, &t.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		templates = append(templates, t)
	}

	return templates, nil
}
