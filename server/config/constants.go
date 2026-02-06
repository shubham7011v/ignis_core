package config

import "time"

// Server configuration constants
var (
	// Default Grace period (seconds)
	DefaultGracePeriodSec = int64(60)

    // Token expiry duration
    TokenExpiryDuration = time.Hour * 24 * 7
)

// Duration constants (pre-calculated for convenience)
var (
	DefaultGracePeriod     = time.Duration(DefaultGracePeriodSec) * time.Second
)
