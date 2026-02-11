package services

import (
	"context"
	"log"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

type FirebaseService struct {
	AuthClient      *auth.Client
	MessagingClient *messaging.Client
	FirestoreClient *firestore.Client
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

	firestoreClient, err := app.Firestore(ctx)
	if err != nil {
		log.Printf("WARNING: Failed to initialize Firestore: %v", err)
	}

	log.Println("Firebase Admin SDK initialized successfully")

	return &FirebaseService{
		AuthClient:      authClient,
		MessagingClient: messagingClient,
		FirestoreClient: firestoreClient,
	}, nil
}

// VerifyIDToken verifies a Firebase ID token and returns the decoded token
func (s *FirebaseService) VerifyIDToken(ctx context.Context, idToken string) (*auth.Token, error) {
	return s.AuthClient.VerifyIDToken(ctx, idToken)
}

// UpdateAppConfig updates the global application configuration in Firestore
func (s *FirebaseService) UpdateAppConfig(ctx context.Context, data map[string]interface{}) error {
	if s.FirestoreClient == nil {
		return nil
	}
	_, err := s.FirestoreClient.Collection("config").Doc("app").Set(ctx, data, firestore.MergeAll)
	return err
}
