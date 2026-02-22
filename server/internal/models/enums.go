package models

// OrderStatus defines the lifecycle of an order
type OrderStatus string

const (
	OrderStatusPending    OrderStatus = "pending"
	OrderStatusProcessing OrderStatus = "processing"
	OrderStatusCompleted  OrderStatus = "completed"
	OrderStatusCancelled  OrderStatus = "cancelled"
)

// PaymentStatus defines the status of a transaction
type PaymentStatus string

const (
	PaymentStatusUnpaid PaymentStatus = "unpaid"
	PaymentStatusPaid   PaymentStatus = "paid"
	PaymentStatusFailed PaymentStatus = "failed"
)

// TemplateCategory defines the design style
type TemplateCategory string

const (
	CategoryTraditional TemplateCategory = "Traditional"
	CategoryModern      TemplateCategory = "Modern"
	CategoryMinimal     TemplateCategory = "Minimal"
)

// InputMethod defines how order details were provided
type InputMethod string

const (
	InputMethodManual InputMethod = "manual"
	InputMethodCard   InputMethod = "card"
)

// BroadcastStatus defines the trigger state for notifications
type BroadcastStatus string

const (
	BroadcastStatusDraft BroadcastStatus = "DRAFT"
	BroadcastStatusSend  BroadcastStatus = "SEND"
	BroadcastStatusSent  BroadcastStatus = "SENT"
)
