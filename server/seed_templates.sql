-- Placeholder Seed Data
-- Run this after deployment to populate initial templates
-- Usage: \i server/seed_templates.sql

INSERT INTO templates (youtube_id, title, description, thumbnail_url, video_url, price_cents, category, tags)
VALUES 
  ('dQw4w9WgXcQ', 'Royal Gold Video', 'Traditional Gold Design', 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 49900, 'Traditional', ARRAY['Gold', 'Mandala']),
  ('jNQXAC9IVRw', 'Modern Minimalist', 'Clean and Elegant', 'https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg', 'https://www.youtube.com/watch?v=jNQXAC9IVRw', 39900, 'Modern', ARRAY['Minimal', 'Elegant']);
