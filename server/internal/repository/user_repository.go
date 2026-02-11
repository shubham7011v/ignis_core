package repository

import (
	"database/sql"
	"ignis_server/internal/models"
	"time"
)

type UserRepository struct {
	db              *sql.DB
	superAdminEmail string
}

func NewUserRepository(db *sql.DB, superAdminEmail string) *UserRepository {
	return &UserRepository{
		db:              db,
		superAdminEmail: superAdminEmail,
	}
}

// GetOrCreateUser syncs a user from Firebase to PostgreSQL
func (r *UserRepository) GetOrCreateUser(firebaseUID, email, displayName, photoURL string) (*models.User, error) {
	var user models.User

	// Try to get existing user
	query := `SELECT id, firebase_uid, email, display_name, photo_url, is_admin, created_at, last_login, COALESCE(fcm_token, '')
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
		&user.FCMToken,
	)

	if err == sql.ErrNoRows {
		// User doesn't exist, create new
		insertQuery := `INSERT INTO users (firebase_uid, email, display_name, photo_url, last_login)
		                VALUES ($1, $2, $3, $4, $5)
		                RETURNING id, firebase_uid, email, display_name, photo_url, is_admin, created_at, last_login, '' as fcm_token`

		err = r.db.QueryRow(insertQuery, firebaseUID, email, displayName, photoURL, time.Now()).Scan(
			&user.ID,
			&user.FirebaseUID,
			&user.Email,
			&user.DisplayName,
			&user.PhotoURL,
			&user.IsAdmin,
			&user.CreatedAt,
			&user.LastLogin,
			&user.FCMToken,
		)

		if err != nil {
			return nil, err
		}

		user.IsSuperAdmin = (user.Email == r.superAdminEmail)
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
	user.LastLogin = time.Now()
	user.IsSuperAdmin = (user.Email == r.superAdminEmail)
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

// IsSuperAdmin checks if a user is a super admin based on email
func (r *UserRepository) IsSuperAdmin(firebaseUID string) (bool, error) {
	var email string
	err := r.db.QueryRow("SELECT email FROM users WHERE firebase_uid = $1", firebaseUID).Scan(&email)
	if err != nil {
		return false, err
	}
	return email == r.superAdminEmail, nil
}

// UpdateUserRole updates the admin status of a user
func (r *UserRepository) UpdateUserRole(userID string, isAdmin bool) error {
	_, err := r.db.Exec("UPDATE users SET is_admin = $1 WHERE id = $2", isAdmin, userID)
	return err
}

// UpdateFCMToken updates the FCM token for a user
func (r *UserRepository) UpdateFCMToken(firebaseUID, token string) error {
	_, err := r.db.Exec("UPDATE users SET fcm_token = $1 WHERE firebase_uid = $2", token, firebaseUID)
	return err
}

// GetFCMToken returns the FCM token for a user
func (r *UserRepository) GetFCMToken(firebaseUID string) (string, error) {
	var token sql.NullString
	err := r.db.QueryRow("SELECT fcm_token FROM users WHERE firebase_uid = $1", firebaseUID).Scan(&token)
	if err != nil {
		return "", err
	}
	if token.Valid {
		return token.String, nil
	}
	return "", nil
}

// Count returns the total number of registered users
func (r *UserRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}

// GetAll returns a paginated list of users
func (r *UserRepository) GetAll(limit, offset int) ([]models.User, error) {
	query := `SELECT id, firebase_uid, email, display_name, photo_url, is_admin, created_at, last_login, COALESCE(fcm_token, '')
	          FROM users
	          ORDER BY created_at DESC
	          LIMIT $1 OFFSET $2`

	rows, err := r.db.Query(query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var u models.User
		err := rows.Scan(
			&u.ID,
			&u.FirebaseUID,
			&u.Email,
			&u.DisplayName,
			&u.PhotoURL,
			&u.IsAdmin,
			&u.CreatedAt,
			&u.LastLogin,
			&u.FCMToken,
		)
		if err != nil {
			return nil, err
		}
		u.IsSuperAdmin = (u.Email == r.superAdminEmail)
		users = append(users, u)
	}

	return users, nil
}
