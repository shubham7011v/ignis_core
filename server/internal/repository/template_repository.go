package repository

import (
	"database/sql"
	"ignis_server/internal/models"
)

type TemplateRepository struct {
	db *sql.DB
}

func NewTemplateRepository(db *sql.DB) *TemplateRepository {
	return &TemplateRepository{db: db}
}

// GetAll returns all active templates
func (r *TemplateRepository) GetAll() ([]models.Template, error) {
	query := `SELECT id, youtube_id, video_url, thumbnail_url, placeholder_color, view_count,
	          title, description, price_cents, category, tags, is_active, created_at, updated_at
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
			&t.ID, &t.YoutubeID, &t.VideoURL, &t.ThumbnailURL, &t.PlaceholderColor, &t.ViewCount,
			&t.Title, &t.Description, &t.PriceCents, &t.Category, &t.Tags,
			&t.IsActive, &t.CreatedAt, &t.UpdatedAt,
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
	query := `SELECT id, youtube_id, video_url, thumbnail_url, placeholder_color, view_count,
              title, description, price_cents, category, tags, is_active, created_at, updated_at
              FROM templates WHERE id = $1`

	var t models.Template
	err := r.db.QueryRow(query, id).Scan(
		&t.ID, &t.YoutubeID, &t.VideoURL, &t.ThumbnailURL, &t.PlaceholderColor, &t.ViewCount,
		&t.Title, &t.Description, &t.PriceCents, &t.Category, &t.Tags,
		&t.IsActive, &t.CreatedAt, &t.UpdatedAt,
	)

	if err != nil {
		return nil, err
	}

	return &t, nil
}
