-- Migration: Cleanup and Customer Metadata
-- Date: 2026-02-21

-- 1. Remove thumbnail_url from templates (derived from youtube_id)
ALTER TABLE templates DROP COLUMN IF EXISTS thumbnail_url;

-- 2. Remove is_admin from users (managed via Sheets/Secret)
ALTER TABLE users DROP COLUMN IF EXISTS is_admin;

-- 3. Add photos_link and event_details for customer orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS photos_link TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS event_details JSONB;
