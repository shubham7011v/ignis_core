package config

import (
	"os"
)

// FeatureFlags defines the state of various high-level features
type FeatureFlags struct {
	EnableAdminDashboard  bool `json:"enableAdminDashboard"`
	EnableVideoGeneration bool `json:"enableVideoGeneration"`
}

// GetFeatureFlags returns the current feature state, potentially from env vars
func GetFeatureFlags() FeatureFlags {
	return FeatureFlags{
		EnableAdminDashboard:  getEnvBool("ENABLE_ADMIN_DASHBOARD", true),
		EnableVideoGeneration: getEnvBool("ENABLE_VIDEO_GENERATION", true),
	}
}

func getEnvBool(key string, defaultVal bool) bool {
	val, exists := os.LookupEnv(key)
	if !exists {
		return defaultVal
	}
	return val == "true" || val == "1"
}
