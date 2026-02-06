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
