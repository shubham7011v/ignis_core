-- Placeholder Seed Data
-- Run this after deployment to populate initial templates
-- Usage: \i server/seed_templates.sql

INSERT INTO templates (youtube_id, title, description, thumbnail_url, video_url, price_cents, category, tags, overlay_config)
VALUES 
  ('dQw4w9WgXcQ', 'Royal Gold Video', 'Traditional Gold Design', 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 49900, 'Traditional', ARRAY['Gold', 'Mandala'], '{"bride_groom":{"x":"(w-text_w)/2","y":"(h-text_h)/2-100","size":72,"color":"gold","timing":{"start":2,"end":28}},"date":{"x":"(w-text_w)/2","y":"(h-text_h)/2+100","size":36,"color":"white","timing":{"start":3,"end":27}},"venue":{"x":"(w-text_w)/2","y":"(h-text_h)/2+200","size":24,"color":"white","timing":{"start":4,"end":26}}}'),
  ('jNQXAC9IVRw', 'Modern Minimalist', 'Clean and Elegant', 'https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg', 'https://www.youtube.com/watch?v=jNQXAC9IVRw', 39900, 'Modern', ARRAY['Minimal', 'Elegant'], '{"bride_groom":{"x":"(w-text_w)/2","y":"(h-text_h)/2-50","size":64,"color":"black","timing":{"start":1,"end":29}}}');
