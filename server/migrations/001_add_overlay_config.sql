-- Migration: Add overlay_config to templates table
-- This column stores JSON configuration for FFmpeg overlays (text/image)

-- 1. Add the column
ALTER TABLE templates ADD COLUMN IF NOT EXISTS overlay_config JSONB;

-- 2. (Optional) Provide a default empty config for existing rows
UPDATE templates SET overlay_config = '{}'::jsonb WHERE overlay_config IS NULL;
