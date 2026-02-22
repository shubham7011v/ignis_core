package services

import (
	"context"
	"fmt"
	"log"

	"cloud.google.com/go/firestore"
	gcsstorage "cloud.google.com/go/storage"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"firebase.google.com/go/v4/messaging"
	"firebase.google.com/go/v4/storage"
	"google.golang.org/api/iterator"
	"google.golang.org/api/option"
)

type FirebaseService struct {
	AuthClient      *auth.Client
	MessagingClient *messaging.Client
	FirestoreClient *firestore.Client
	StorageClient   *storage.Client
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

	storageClient, err := app.Storage(ctx)
	if err != nil {
		log.Printf("WARNING: Failed to initialize Firebase Storage: %v", err)
	}

	log.Println("Firebase Admin SDK initialized successfully")

	return &FirebaseService{
		AuthClient:      authClient,
		MessagingClient: messagingClient,
		FirestoreClient: firestoreClient,
		StorageClient:   storageClient,
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

// DeleteOrderPhotos deletes all photos for a given order from storage
func (s *FirebaseService) DeleteOrderPhotos(ctx context.Context, bucketName, folderPath string) error {
	if s.StorageClient == nil {
		return fmt.Errorf("storage client not initialized")
	}

	// Get the underlying GCS bucket handle from the Firebase Admin client
	bucketHandle, err := s.StorageClient.Bucket(bucketName)
	if err != nil {
		return fmt.Errorf("failed to get bucket: %w", err)
	}

	// List all objects in the folder using GCS query
	it := bucketHandle.Objects(ctx, &gcsstorage.Query{Prefix: folderPath})
	for {
		attrs, err := it.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return fmt.Errorf("listing objects: %w", err)
		}

		if err := bucketHandle.Object(attrs.Name).Delete(ctx); err != nil {
			log.Printf("[Cleanup] Failed to delete %s: %v", attrs.Name, err)
		} else {
			log.Printf("[Cleanup] Deleted %s", attrs.Name)
		}
	}

	return nil
}
