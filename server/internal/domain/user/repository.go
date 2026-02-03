package user

// Repository defines the interface for user persistence
type Repository interface {
	GetOrCreate(id, name string) (*User, error)
	UpdateProfile(id, name, avatar string) error
	UpdateLastSeen(id string) error
	DeleteUser(id string) error
	BanUser(id string) error
}
