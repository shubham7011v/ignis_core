package sqlite

import (
	"database/sql"
	"fmt"
	"ignis_server/internal/domain/user"
	"time"
)

// UserRepository implements user.Repository
type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) GetOrCreate(id, name string) (*user.User, error) {
	var u user.User
	var dbName string
	var isBanned bool
	var dbAvatar sql.NullString

	// Note: We keep the underlying table structure to avoid migrations for now, but only scan relevant fields
	row := r.db.QueryRow("SELECT user_id, name, avatar, is_banned FROM users WHERE user_id = ?", id)
	err := row.Scan(&u.ID, &dbName, &dbAvatar, &isBanned)

	if isBanned {
		return nil, fmt.Errorf("USER_BANNED")
	}

	if err == sql.ErrNoRows {
		// Create new user
		_, err := r.db.Exec("INSERT INTO users (user_id, name, last_seen) VALUES (?, ?, ?)", id, name, time.Now())
		if err != nil {
			return nil, err
		}
		newUser := &user.User{
			ID:       id,
			Name:     name,
			LastSeen: time.Now(),
		}
		return newUser, nil
	} else if err != nil {
		return nil, err
	}

	u.Name = dbName
	if dbAvatar.Valid {
		u.AvatarURL = dbAvatar.String
	}

	// Update last seen
	r.db.Exec("UPDATE users SET last_seen = ? WHERE user_id = ?", time.Now(), id)

	return &u, nil
}

func (r *UserRepository) UpdateProfile(id, name, avatar string) error {
	if name != "" {
		_, err := r.db.Exec("UPDATE users SET name = ? WHERE user_id = ?", name, id)
		if err != nil {
			return err
		}
	}
	if avatar != "" {
		_, err := r.db.Exec("UPDATE users SET avatar = ? WHERE user_id = ?", avatar, id)
		if err != nil {
			return err
		}
	}
	return nil
}

func (r *UserRepository) UpdateLastSeen(id string) error {
	_, err := r.db.Exec("UPDATE users SET last_seen = ? WHERE user_id = ?", time.Now(), id)
	return err
}

func (r *UserRepository) BanUser(id string) error {
	_, err := r.db.Exec("UPDATE users SET is_banned = 1 WHERE user_id = ?", id)
	return err
}

func (r *UserRepository) DeleteUser(id string) error {
	_, err := r.db.Exec("DELETE FROM users WHERE user_id = ?", id)
	return err
}
