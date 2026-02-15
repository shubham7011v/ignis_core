-- Remove video_url column from templates table
ALTER TABLE templates DROP COLUMN IF EXISTS video_url;
