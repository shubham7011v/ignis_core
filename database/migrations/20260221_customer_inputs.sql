-- Migration: Advanced Manual Factory (Customer Inputs)
-- Add extra metadata fields to 'orders' table for manual production

ALTER TABLE orders ADD COLUMN IF NOT EXISTS photos_link TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS event_details JSONB; -- JSON for flexible event list (Haldi, Mehendi, etc)

COMMENT ON COLUMN orders.photos_link IS 'Public link to customer photos (Google Drive/Firebase Storage)';
COMMENT ON COLUMN orders.event_details IS 'JSON mapping of event names to dates/times';
