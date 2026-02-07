package services

import (
	"context"
	"log"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

type FirebaseService struct {
	AuthClient      *auth.Client
	MessagingClient *messaging.Client
}

func NewFirebaseService(credentialsPath, credentialsJSON string) (*FirebaseService, error) {
	ctx := context.Background()

	var opt option.ClientOption
	if credentialsJSON != "" {
		opt = option.WithCredentialsJSON([]byte(credentialsJSON))
		log.Println("Initializing Firebase using FIREBASE_CREDENTIALS_JSON env var")
	} else if credentialsPath != "" {
		opt = option.WithCredentialsFile(credentialsPath)
		log.Println("Initializing Firebase using config file path")
	} else {
		log.Println("WARNING: No Firebase credentials provided (JSON or File)")
		return nil, nil
	}

	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return nil, err
	}

	authClient, err := app.Auth(ctx)
	if err != nil {
		return nil, err
	}

	messagingClient, err := app.Messaging(ctx)
	if err != nil {
		log.Printf("WARNING: Failed to initialize Firebase Messaging: %v", err)
	}

	log.Println("Firebase Admin SDK initialized successfully")

	return &FirebaseService{
		AuthClient:      authClient,
		MessagingClient: messagingClient,
	}, nil
}

// VerifyIDToken verifies a Firebase ID token and returns the decoded token
func (s *FirebaseService) VerifyIDToken(ctx context.Context, idToken string) (*auth.Token, error) {
	return s.AuthClient.VerifyIDToken(ctx, idToken)
}
