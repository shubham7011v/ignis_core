package services

import (
	"encoding/json"
	"fmt"
	"ignis_server/internal/models"
	"os/exec"
	"path/filepath"
	"strings"
)

type RenderService struct {
	TemplatesDir string
	OutputDir    string
}

func NewRenderService(templatesDir, outputDir string) *RenderService {
	return &RenderService{
		TemplatesDir: templatesDir,
		OutputDir:    outputDir,
	}
}

type OverlayConfig struct {
	BrideGroom *TextOverlay `json:"bride_groom"`
	Date       *TextOverlay `json:"date"`
	Venue      *TextOverlay `json:"venue"`
}

type TextOverlay struct {
	X      string `json:"x"`
	Y      string `json:"y"`
	Size   int    `json:"size"`
	Color  string `json:"color"`
	Timing Timing `json:"timing"`
}

type Timing struct {
	Start float64 `json:"start"`
	End   float64 `json:"end"`
}

// Render processes an order and generates a personalized video
func (s *RenderService) Render(order *models.Order, template *models.Template) (string, error) {
	// 1. Parse OverlayConfig
	if len(template.OverlayConfig) == 0 {
		return "", fmt.Errorf("template has no overlay configuration")
	}

	var config OverlayConfig
	if err := json.Unmarshal(template.OverlayConfig, &config); err != nil {
		return "", fmt.Errorf("failed to parse overlay config: %v", err)
	}

	// 2. Prepare paths
	// We assume template files are named by their ID in the TemplatesDir
	templatePath := filepath.Join(s.TemplatesDir, template.ID+".mp4")
	outputFileName := fmt.Sprintf("render_%s.mp4", order.ID)
	outputPath := filepath.Join(s.OutputDir, outputFileName)

	// 3. Build Filter Complex
	filters := []string{}

	if config.BrideGroom != nil {
		text := fmt.Sprintf("%s & %s", order.BrideName, order.GroomName)
		filters = append(filters, s.buildDrawText(text, config.BrideGroom))
	}

	if config.Date != nil {
		// Use a nice format for the date
		dateText := order.WeddingDate.Format("02 January 2006")
		filters = append(filters, s.buildDrawText(dateText, config.Date))
	}

	if config.Venue != nil {
		filters = append(filters, s.buildDrawText(order.Venue, config.Venue))
	}

	if len(filters) == 0 {
		return "", fmt.Errorf("no overlays configured to render")
	}

	filterComplex := strings.Join(filters, ",")

	// 4. Build Command
	// Using -y to overwrite if already exists
	args := []string{
		"-i", templatePath,
		"-vf", filterComplex,
		"-c:a", "copy", // Copy audio without re-encoding to save time
		"-preset", "veryfast", // Speed up encoding
		"-y",
		outputPath,
	}

	cmd := exec.Command("ffmpeg", args...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("ffmpeg failed: %v, output: %s", err, string(output))
	}

	return outputPath, nil
}

func (s *RenderService) buildDrawText(text string, overlay *TextOverlay) string {
	// Basic escaping for FFmpeg text
	escapedText := strings.ReplaceAll(text, "'", "\\'")
	escapedText = strings.ReplaceAll(escapedText, ":", "\\:")

	return fmt.Sprintf("drawtext=text='%s':fontcolor=%s:fontsize=%d:x=%s:y=%s:enable='between(t,%f,%f)'",
		escapedText, overlay.Color, overlay.Size, overlay.X, overlay.Y, overlay.Timing.Start, overlay.Timing.End)
}
