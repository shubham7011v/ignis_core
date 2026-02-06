package repository

import (
	"database/sql"
	"ignis_server/internal/models"
	"time"
)

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// GetOrCreateUser syncs a user from Firebase to PostgreSQL
func (r *UserRepository) GetOrCreateUser(firebaseUID, email, displayName, photoURL string) (*models.User, error) {
	var user models.User

	// Try to get existing user
	query := `SELECT id, firebase_uid, email, display_name, photo_url, is_admin, created_at, last_login
	          FROM users WHERE firebase_uid = $1`

	err := r.db.QueryRow(query, firebaseUID).Scan(
		&user.ID,
		&user.FirebaseUID,
		&user.Email,
		&user.DisplayName,
		&user.PhotoURL,
		&user.IsAdmin,
		&user.CreatedAt,
		&user.LastLogin,
	)

	if err == sql.ErrNoRows {
		// User doesn't exist, create new
		insertQuery := `INSERT INTO users (firebase_uid, email, display_name, photo_url, last_login)
		                VALUES ($1, $2, $3, $4, $5)
		                RETURNING id, firebase_uid, email, display_name, photo_url, is_admin, created_at, last_login`

		err = r.db.QueryRow(insertQuery, firebaseUID, email, displayName, photoURL, time.Now()).Scan(
			&user.ID,
			&user.FirebaseUID,
			&user.Email,
			&user.DisplayName,
			&user.PhotoURL,
			&user.IsAdmin,
			&user.CreatedAt,
			&user.LastLogin,
		)

		if err != nil {
			return nil, err
		}

		return &user, nil
	}

	if err != nil {
		return nil, err
	}

	// Update last login
	_, err = r.db.Exec("UPDATE users SET last_login = $1 WHERE firebase_uid = $2", time.Now(), firebaseUID)
	if err != nil {
		return nil, err
	}

	user.LastLogin = time.Now()
	return &user, nil
}

// IsAdmin checks if a user is an admin
func (r *UserRepository) IsAdmin(firebaseUID string) (bool, error) {
	var isAdmin bool
	err := r.db.QueryRow("SELECT is_admin FROM users WHERE firebase_uid = $1", firebaseUID).Scan(&isAdmin)
	if err != nil {
		return false, err
	}
	return isAdmin, nil
}
