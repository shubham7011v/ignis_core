package handlers

import (
	"net/http"

	"ignis_server/internal/repository"

	"github.com/gin-gonic/gin"
)

type TemplatesHandler struct {
	templateRepo *repository.TemplateRepository
}

func NewTemplatesHandler(templateRepo *repository.TemplateRepository) *TemplatesHandler {
	return &TemplatesHandler{
		templateRepo: templateRepo,
	}
}

// GetTemplates handles GET /api/templates
func (h *TemplatesHandler) GetTemplates(c *gin.Context) {
	templates, err := h.templateRepo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch templates"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"templates": templates,
	})
}

// GetTemplate handles GET /api/templates/:id
func (h *TemplatesHandler) GetTemplate(c *gin.Context) {
	id := c.Param("id")

	template, err := h.templateRepo.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Template not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"template": template,
	})
}
