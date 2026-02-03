package user

import "time"

// User represents the person in the domain layer
type User struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	AvatarURL string    `json:"avatarUrl"`
	IsBanned  bool      `json:"isBanned"`
	LastSeen  time.Time `json:"lastSeen"`
}

func (u *User) CalculateRank() {
	// Placeholder if we ever want to add ranks for power users/creators
}
