-- Add delivery_time_hours to templates
ALTER TABLE templates ADD COLUMN IF NOT EXISTS delivery_time_hours INTEGER DEFAULT 48;

-- Add due_at to orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS due_at TIMESTAMP WITH TIME ZONE;
