package config

import (
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	Port                         string
	DBHost                       string
	DBPort                       string
	DBUser                       string
	DBPassword                   string
	DBName                       string
	FirebaseCredentialsPath      string
	FirebaseCredentialsJSON      string
	AllowedOrigins               string
	TemplatesDir                 string
	RenderOutputDir              string
	GooglePlayPackageName        string
	GoogleApplicationCredentials string
	GoogleSheetsID               string
	SyncSecretToken              string
	SuperAdminEmail              string
}

func Load() *Config {
	// Load .env file (ignore error in production where env vars are set directly)
	_ = godotenv.Load()

	return &Config{
		Port:                         getEnv("PORT", "8080"),
		DBHost:                       getEnv("DB_HOST", "localhost"),
		DBPort:                       getEnv("DB_PORT", "5432"),
		DBUser:                       getEnv("DB_USER", "vites_user"),
		DBPassword:                   getEnv("DB_PASSWORD", "vites_secure_pass_2026"),
		DBName:                       getEnv("DB_NAME", "vites_db"),
		FirebaseCredentialsPath:      getEnv("FIREBASE_CREDENTIALS_PATH", ""),
		FirebaseCredentialsJSON:      getEnv("FIREBASE_CREDENTIALS_JSON", ""),
		AllowedOrigins:               getEnv("ALLOWED_ORIGINS", "*"),
		TemplatesDir:                 getEnv("TEMPLATES_DIR", "./storage/templates"),
		RenderOutputDir:              getEnv("RENDER_OUTPUT_DIR", "./storage/renders"),
		GooglePlayPackageName:        getEnv("GOOGLE_PLAY_PACKAGE_NAME", "com.iamsorry.vites"),
		GoogleApplicationCredentials: getEnv("GOOGLE_APPLICATION_CREDENTIALS", ""),
		GoogleSheetsID:               getEnv("GOOGLE_SHEETS_ID", ""),
		SyncSecretToken:              getEnv("SYNC_SECRET_TOKEN", "vites_sync_secret_2026"),
		SuperAdminEmail:              getEnv("SUPER_ADMIN_EMAIL", ""),
	}
}

func getEnv(key, defaultVal string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return defaultVal
}

func (c *Config) GetDBConnectionString() string {
	return "host=" + c.DBHost + " port=" + c.DBPort + " user=" + c.DBUser +
		" password=" + c.DBPassword + " dbname=" + c.DBName + " sslmode=disable"
}
