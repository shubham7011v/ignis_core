package services

import (
	"fmt"
	"ignis_server/internal/models"
)

type SharingService struct {
	BaseURL string
}

func NewSharingService(baseURL string) *SharingService {
	return &SharingService{
		BaseURL: baseURL,
	}
}

// GetShortMetadata returns metadata for social previews for a Short
func (s *SharingService) GetShortMetadata(short *models.Short) map[string]string {
	return map[string]string{
		"og:title":       fmt.Sprintf("Check out this %s", short.Title),
		"og:description": fmt.Sprintf("A beautiful wedding invitation in the %s category.", short.Category),
		"og:image":       short.ThumbnailURL,
		"og:url":         fmt.Sprintf("%s/s/%s", s.BaseURL, short.ID),
		"og:type":        "video.other",
		"twitter:card":   "summary_large_image",
	}
}

// GetTemplateMetadata returns metadata for social previews for a Template
func (s *SharingService) GetTemplateMetadata(template *models.Template) map[string]string {
	return map[string]string{
		"og:title":       template.Title,
		"og:description": template.Description,
		"og:image":       template.ThumbnailURL,
		"og:url":         fmt.Sprintf("%s/v/%s", s.BaseURL, template.ID),
		"og:type":        "website",
		"twitter:card":   "summary_large_image",
	}
}
