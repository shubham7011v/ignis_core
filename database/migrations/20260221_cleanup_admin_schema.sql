-- Migration: Admin & Schema Optimization Cleanup
-- Date: 2026-02-21

-- 1. Remove thumbnail_url from templates
-- The app now derives this from youtube_id
ALTER TABLE templates DROP COLUMN IF EXISTS thumbnail_url;

-- 2. Remove is_admin from users
-- Administrative functions are now managed via Google Sheets & Sync Secret
ALTER TABLE users DROP COLUMN IF EXISTS is_admin;

-- 3. (Optional) Cleanup any stale triggers or functions if they exist
-- DROP FUNCTION IF EXISTS check_admin_promotion();
