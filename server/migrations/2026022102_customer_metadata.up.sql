-- Migration to add photos_link and event_details columns
ALTER TABLE orders ADD COLUMN IF NOT EXISTS photos_link TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS event_details JSONB;
