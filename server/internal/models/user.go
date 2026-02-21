package models

import "time"

type User struct {
	ID          string    `json:"id" db:"id"`
	FirebaseUID string    `json:"firebaseUid" db:"firebase_uid"`
	Email       string    `json:"email" db:"email"`
	DisplayName string    `json:"displayName" db:"display_name"`
	PhotoURL    string    `json:"photoUrl" db:"photo_url"`
	CreatedAt   time.Time `json:"createdAt" db:"created_at"`
	LastLogin   time.Time `json:"lastLogin" db:"last_login"`
	FCMToken    string    `json:"fcmToken" db:"fcm_token"`
}
