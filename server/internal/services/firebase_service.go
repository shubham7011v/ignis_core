package services

import (
	"context"
	"log"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"google.golang.org/api/option"
)

type FirebaseService struct {
	AuthClient *auth.Client
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

	log.Println("Firebase Admin SDK initialized successfully")

	return &FirebaseService{
		AuthClient: authClient,
	}, nil
}

// VerifyIDToken verifies a Firebase ID token and returns the decoded token
func (s *FirebaseService) VerifyIDToken(ctx context.Context, idToken string) (*auth.Token, error) {
	return s.AuthClient.VerifyIDToken(ctx, idToken)
}
