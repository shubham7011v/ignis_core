package services

import (
	"context"
	"fmt"
	"log"

	"firebase.google.com/go/v4/messaging"
)

type NotificationService struct {
	firebaseService *FirebaseService
}

func NewNotificationService(firebaseService *FirebaseService) *NotificationService {
	return &NotificationService{
		firebaseService: firebaseService,
	}
}

// SendOrderUpdate sends a notification to a specific user about an order update
func (s *NotificationService) SendOrderUpdate(fcmToken, orderID, status string) error {
	if s.firebaseService == nil || s.firebaseService.MessagingClient == nil {
		return fmt.Errorf("messaging client not initialized")
	}

	if fcmToken == "" {
		return nil // No token, nothing to do
	}

	// Customize message based on status
	title := "Order Update"
	body := fmt.Sprintf("Your order #%s is now %s", orderID, status)

	switch status {
	case "completed":
		title = "Video Ready! 🎬"
		body = "Your wedding invitation video is ready to download!"
	case "processing":
		title = "Order in Progress ⏳"
		body = "We have started working on your order."
	}

	message := &messaging.Message{
		Token: fcmToken,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: map[string]string{
			"type":    "order_update",
			"orderId": orderID,
			"status":  status,
		},
	}

	response, err := s.firebaseService.MessagingClient.Send(context.Background(), message)
	if err != nil {
		log.Printf("Error sending message: %v", err)
		return err
	}

	log.Printf("Successfully sent message: %s", response)
	return nil
}

// SendMulticast sends a message to multiple tokens
func (s *NotificationService) SendMulticast(tokens []string, title, body string, data map[string]string) error {
	if s.firebaseService == nil || s.firebaseService.MessagingClient == nil {
		return fmt.Errorf("messaging client not initialized")
	}

	if len(tokens) == 0 {
		return nil
	}

	message := &messaging.MulticastMessage{
		Tokens: tokens,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: data,
	}

	br, err := s.firebaseService.MessagingClient.SendMulticast(context.Background(), message)
	if err != nil {
		return err
	}

	log.Printf("%d messages were sent successfully", br.SuccessCount)
	return nil
}

// SendGlobalBroadcast sends a message to the "all_users" topic
func (s *NotificationService) SendGlobalBroadcast(title, body string) error {
	if s.firebaseService == nil || s.firebaseService.MessagingClient == nil {
		return fmt.Errorf("messaging client not initialized")
	}

	// Topic to send to (client must subscribe to this topic)
	topic := "all_users"

	message := &messaging.Message{
		Topic: topic,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: map[string]string{
			"type": "broadcast",
		},
	}

	response, err := s.firebaseService.MessagingClient.Send(context.Background(), message)
	if err != nil {
		log.Printf("Error sending broadcast: %v", err)
		return err
	}

	log.Printf("Successfully sent broadcast: %s", response)
	return nil
}
