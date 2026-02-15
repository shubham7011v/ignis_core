package models

import "time"

// Template represents a wedding video template
// This serves BOTH as the browsable product AND the shorts feed item
type Template struct {
	ID string `json:"id" db:"id"`

	// Video fields (for Shorts feed)
	YoutubeID        string `json:"youtubeId" db:"youtube_id"`
	ThumbnailURL     string `json:"thumbnailUrl" db:"thumbnail_url"`
	PlaceholderColor string `json:"placeholderColor" db:"placeholder_color"`
	ViewCount        int    `json:"viewCount" db:"view_count"`

	// Product fields (for template browsing)
	Title       string   `json:"title" db:"title"`
	Description string   `json:"description" db:"description"`
	PriceCents  int      `json:"priceCents" db:"price_cents"`
	Category    string   `json:"category" db:"category"`
	Tags        []string `json:"tags" db:"tags"`

	// Overlay Configuration for automated rendering
	OverlayConfig []byte `json:"overlayConfig" db:"overlay_config"` // JSON data

	// Metadata
	IsActive    bool      `json:"isActive" db:"is_active"`
	IsFavorited bool      `json:"isFavorited" db:"is_favorited"` // Computed field from JOIN
	CreatedAt   time.Time `json:"createdAt" db:"created_at"`
	UpdatedAt   time.Time `json:"updatedAt" db:"updated_at"`
}

type Order struct {
	ID            string     `json:"id" db:"id"`
	UserID        string     `json:"userId" db:"user_id"`
	TemplateID    string     `json:"templateId" db:"template_id"`
	BrideName     string     `json:"brideName" db:"bride_name"`
	GroomName     string     `json:"groomName" db:"groom_name"`
	WeddingDate   time.Time  `json:"weddingDate" db:"wedding_date"`
	Venue         string     `json:"venue" db:"venue"`
	CustomMessage string     `json:"customMessage" db:"custom_message"`
	Status        string     `json:"status" db:"status"`
	VideoURL      *string    `json:"videoUrl" db:"video_url"`
	PaymentStatus string     `json:"paymentStatus" db:"payment_status"`
	AmountCents   int        `json:"amountCents" db:"amount_cents"`
	TransactionID string     `json:"transactionId" db:"transaction_id"`
	CreatedAt     time.Time  `json:"createdAt" db:"created_at"`
	DeliveredAt   *time.Time `json:"deliveredAt" db:"delivered_at"`
	DownloadedAt  *time.Time `json:"downloadedAt" db:"downloaded_at"`
	AdminNotes    *string    `json:"adminNotes" db:"admin_notes"`
}
