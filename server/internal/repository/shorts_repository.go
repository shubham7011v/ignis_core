package repository

import (
	"database/sql"
	"ignis_server/internal/models"

	"github.com/lib/pq"
)

type ShortsRepository struct {
	db *sql.DB
}

func NewShortsRepository(db *sql.DB) *ShortsRepository {
	return &ShortsRepository{db: db}
}

// GetRandomShorts returns random templates for the shorts feed
func (r *ShortsRepository) GetRandomShorts(userID string, limit int) ([]models.Template, error) {
	query := `SELECT t.id, t.youtube_id, t.video_url, t.thumbnail_url, t.placeholder_color,
	          t.view_count, t.title, t.description, t.price_cents, t.category, t.tags,
	          t.is_active, t.created_at, t.updated_at,
	          EXISTS(SELECT 1 FROM user_favorites WHERE user_id = $1 AND template_id = t.id) as is_favorited
	          FROM templates t
	          WHERE t.is_active = true
	          ORDER BY RANDOM()
	          LIMIT $2`

	rows, err := r.db.Query(query, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var templates []models.Template
	for rows.Next() {
		var t models.Template
		err := rows.Scan(
			&t.ID, &t.YoutubeID, &t.VideoURL, &t.ThumbnailURL, &t.PlaceholderColor,
			&t.ViewCount, &t.Title, &t.Description, &t.PriceCents, &t.Category, (*pq.StringArray)(&t.Tags),
			&t.IsActive, &t.CreatedAt, &t.UpdatedAt, &t.IsFavorited,
		)
		if err != nil {
			return nil, err
		}
		templates = append(templates, t)
	}

	return templates, nil
}

// GetFavorites returns user's favorited templates
func (r *ShortsRepository) GetFavorites(userID string) ([]models.Template, error) {
	query := `SELECT t.id, t.youtube_id, t.video_url, t.thumbnail_url, t.placeholder_color,
	          t.view_count, t.title, t.description, t.price_cents, t.category, t.tags,
	          t.is_active, t.created_at, t.updated_at, true as is_favorited
	          FROM templates t
	          JOIN user_favorites uf ON t.id = uf.template_id
	          WHERE uf.user_id = $1
	          ORDER BY uf.created_at DESC`

	rows, err := r.db.Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var templates []models.Template
	for rows.Next() {
		var t models.Template
		err := rows.Scan(
			&t.ID, &t.YoutubeID, &t.VideoURL, &t.ThumbnailURL, &t.PlaceholderColor,
			&t.ViewCount, &t.Title, &t.Description, &t.PriceCents, &t.Category, (*pq.StringArray)(&t.Tags),
			&t.IsActive, &t.CreatedAt, &t.UpdatedAt, &t.IsFavorited,
		)
		if err != nil {
			return nil, err
		}
		templates = append(templates, t)
	}

	return templates, nil
}

// ToggleFavorite adds or removes a favorite
func (r *ShortsRepository) ToggleFavorite(userID, templateID string) error {
	// Check if already favorited
	var exists bool
	err := r.db.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM user_favorites WHERE user_id = $1 AND template_id = $2)",
		userID, templateID,
	).Scan(&exists)

	if err != nil {
		return err
	}

	if exists {
		// Remove favorite
		_, err = r.db.Exec("DELETE FROM user_favorites WHERE user_id = $1 AND template_id = $2", userID, templateID)
	} else {
		// Add favorite
		_, err = r.db.Exec(
			"INSERT INTO user_favorites (user_id, template_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
			userID, templateID,
		)
	}

	return err
}

// IncrementViewCount increments the view count for a template
func (r *ShortsRepository) IncrementViewCount(templateID string) error {
	_, err := r.db.Exec("UPDATE templates SET view_count = view_count + 1 WHERE id = $1", templateID)
	return err
}
