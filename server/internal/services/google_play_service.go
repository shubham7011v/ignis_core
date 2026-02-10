package services

import (
	"context"
	"fmt"

	"google.golang.org/api/androidpublisher/v3"
	"google.golang.org/api/option"
)

type GooglePlayService struct {
	client      *androidpublisher.Service
	packageName string
}

func NewGooglePlayService(ctx context.Context, packageName, credentialsPath string) (*GooglePlayService, error) {
	var opts []option.ClientOption
	if credentialsPath != "" {
		opts = append(opts, option.WithCredentialsFile(credentialsPath))
	}

	service, err := androidpublisher.NewService(ctx, opts...)
	if err != nil {
		return nil, fmt.Errorf("failed to create androidpublisher service: %w", err)
	}

	return &GooglePlayService{
		client:      service,
		packageName: packageName,
	}, nil
}

// VerifyAndConsumePurchase verifies the purchase with Google and then consumes it
// so it can be bought again.
func (s *GooglePlayService) VerifyAndConsumePurchase(ctx context.Context, productId, purchaseToken string) (*androidpublisher.ProductPurchase, error) {
	// 1. Get purchase details
	purchase, err := s.client.Purchases.Products.Get(s.packageName, productId, purchaseToken).Context(ctx).Do()
	if err != nil {
		return nil, fmt.Errorf("failed to get product purchase: %w", err)
	}

	// 2. Check purchase state (0 = purchased, 1 = canceled, 2 = pending)
	if purchase.PurchaseState != 0 {
		return nil, fmt.Errorf("invalid purchase state: %d", purchase.PurchaseState)
	}

	// 3. Acknowledge and Consume
	// In v3, we can use the Consume method
	err = s.client.Purchases.Products.Consume(s.packageName, productId, purchaseToken).Context(ctx).Do()
	if err != nil {
		return nil, fmt.Errorf("failed to consume purchase: %w", err)
	}

	return purchase, nil
}
