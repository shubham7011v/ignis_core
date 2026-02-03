package db

import (
	"database/sql"
	"embed"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/sqlite"
	"github.com/golang-migrate/migrate/v4/source/iofs"

	_ "modernc.org/sqlite"
)

//go:embed migrations/*.sql
var migrationsFS embed.FS

// InitDB initializes the SQLite database and runs migrations
func InitDB(dbPath string) (*sql.DB, error) {
	// Ensure directory exists
	dir := filepath.Dir(dbPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return nil, err
	}

	var err error
	actualPath := dbPath
	if dbPath == ":memory:" {
		actualPath = "file::memory:?cache=shared"
	}
	dbConn, err := sql.Open("sqlite", actualPath)
	if err != nil {
		return nil, err
	}

	if err = dbConn.Ping(); err != nil {
		return nil, err
	}

	log.Println("Database connected at", dbPath)

	// Enable Write-Ahead Logging (WAL) for concurrency
	if _, err := dbConn.Exec("PRAGMA journal_mode=WAL;"); err != nil {
		return nil, fmt.Errorf("failed to enable WAL mode: %v", err)
	}
	// Set busy timeout to prevent "database is locked" errors
	if _, err := dbConn.Exec("PRAGMA busy_timeout=5000;"); err != nil {
		return nil, fmt.Errorf("failed to set busy timeout: %v", err)
	}

	// Run migrations
	if err := runMigrations(dbConn); err != nil {
		return nil, err
	}

	return dbConn, nil
}

func runMigrations(dbConn *sql.DB) error {
	driver, err := sqlite.WithInstance(dbConn, &sqlite.Config{})
	if err != nil {
		return fmt.Errorf("could not setup migration driver: %v", err)
	}

	source, err := iofs.New(migrationsFS, "migrations")
	if err != nil {
		return fmt.Errorf("could not setup migration source: %v", err)
	}

	m, err := migrate.NewWithInstance("iofs", source, "sqlite", driver)
	if err != nil {
		return fmt.Errorf("could not create migration instance: %v", err)
	}

	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("failed to apply migrations: %v", err)
	}

	log.Println("Migrations applied successfully")
	return nil
}
