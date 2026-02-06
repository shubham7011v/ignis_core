package handlers

import (
	"fmt"
	"net/http"
	"strings"

	"ignis_server/internal/repository"
	"ignis_server/internal/services"

	"github.com/gin-gonic/gin"
)

type SharingHandler struct {
	sharingService *services.SharingService
	shortsRepo     *repository.ShortsRepository
	templateRepo   *repository.TemplateRepository
}

func NewSharingHandler(
	sharingService *services.SharingService,
	shortsRepo *repository.ShortsRepository,
	templateRepo *repository.TemplateRepository,
) *SharingHandler {
	return &SharingHandler{
		sharingService: sharingService,
		shortsRepo:     shortsRepo,
		templateRepo:   templateRepo,
	}
}

// HandleShortLink handles GET /s/:id
func (h *SharingHandler) HandleShortLink(c *gin.Context) {
	// HandleShortLink typically resolves /s/:id
	// Since we unified templates, we might look up by ID using templateRepo.
	// For now, let's just use a placeholder to pass compilation.
	// In the real implementation, we'd do:
	// id := c.Param("id")
	// template, err := h.templateRepo.GetByID(id) ...

	// Assuming success for placeholder:
	h.renderPreviewPage(c, "Wedding Invitation", "https://via.placeholder.com/600x400", "A beautiful wedding invitation")

	// We'll need a way to fetch a specific short. Let's stick to the plan and assume we implement the lookup.
	h.renderPreviewPage(c, "Short Title", "https://via.placeholder.com/600x400", "Wedding Short Preview")
}

func (h *SharingHandler) renderPreviewPage(c *gin.Context, title, image, description string) {
	userAgent := c.GetHeader("User-Agent")
	isBot := strings.Contains(strings.ToLower(userAgent), "whatsapp") ||
		strings.Contains(strings.ToLower(userAgent), "facebook") ||
		strings.Contains(strings.ToLower(userAgent), "instagram") ||
		strings.Contains(strings.ToLower(userAgent), "twitter") ||
		strings.Contains(strings.ToLower(userAgent), "telegram")

	if isBot {
		html := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <meta property="og:title" content="%s" />
    <meta property="og:description" content="%s" />
    <meta property="og:image" content="%s" />
    <meta property="og:type" content="website" />
    <meta name="twitter:card" content="summary_large_image">
    <title>%s</title>
</head>
<body>
    <p>Redirecting to Vivaah app...</p>
</body>
</html>`, title, description, image, title)
		c.Data(http.StatusOK, "text/html; charset=utf-8", []byte(html))
		return
	}

	// For real users, redirect to the app or app store
	// In production, this would be a deep link URL
	c.Redirect(http.StatusFound, "https://iamsorry.in")
}

// HandleAppleAppSiteAssociation handles /.well-known/apple-app-site-association
func (h *SharingHandler) HandleAppleAppSiteAssociation(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"applinks": gin.H{
			"apps": []string{},
			"details": []gin.H{
				{
					"appID": "YOUR_TEAM_ID.com.vivaah.app",
					"paths": []string{"/s/*", "/v/*"},
				},
			},
		},
	})
}

// HandleAssetLinks handles /.well-known/assetlinks.json
func (h *SharingHandler) HandleAssetLinks(c *gin.Context) {
	c.JSON(http.StatusOK, []gin.H{
		{
			"relation": []string{"delegate_permission/common.handle_all_urls"},
			"target": gin.H{
				"namespace":                "android_app",
				"package_name":             "com.vivaah.app",
				"sha256_cert_fingerprints": []string{"YOUR_SHA256_FINGERPRINT"},
			},
		},
	})
}
