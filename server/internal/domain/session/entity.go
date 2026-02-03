package session

import (
	"time"
)

// Session represents a coordination unit in the server (e.g., for video generation tracking)
type Session struct {
	ID              string
	Settings        Settings
	CreatedAt       int64
	LastActivityAt  time.Time
	DisconnectTimes map[string]time.Time
}

type Settings struct {
	Name       string
	Code       string
	Password   string
	IsPrivate  bool
	HostID     string
	MaxPlayers int
}

func NewSession(id string, settings Settings) *Session {
	return &Session{
		ID:              id,
		Settings:        settings,
		CreatedAt:       time.Now().Unix(),
		LastActivityAt:  time.Now(),
		DisconnectTimes: make(map[string]time.Time),
	}
}

// ActionResult is a generic result for session activities
type ActionResult struct {
	BroadcastState bool
	BroadcastEvent *BroadcastEvent
	Error          error
	ClientResponse any
}

type BroadcastEvent struct {
	Type    string
	Payload interface{}
}
