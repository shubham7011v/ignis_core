-- Restore tags column to templates table
ALTER TABLE templates ADD COLUMN tags TEXT[];
