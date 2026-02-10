-- 1. Users (Synced from Firebase Auth)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_uid VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255),
  display_name VARCHAR(255),
  photo_url TEXT,
  is_admin BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP
);

-- 2. Templates (Unified - serves both as products AND shorts feed)
CREATE TABLE IF NOT EXISTS templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Video Info (for Shorts feed display)
  youtube_id VARCHAR(50) NOT NULL,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  placeholder_color VARCHAR(20),
  view_count INTEGER DEFAULT 0,
  
  -- Product Info (for template browsing and purchasing)
  title VARCHAR(255) NOT NULL,
  description TEXT,
  price_cents INTEGER NOT NULL,
  category VARCHAR(100),
  tags TEXT[],
  
  -- Metadata
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. User Favorites (References templates directly)
CREATE TABLE IF NOT EXISTS user_favorites (
  user_id VARCHAR(255) NOT NULL,
  template_id UUID REFERENCES templates(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, template_id)
);

-- 4. Orders (User purchases)
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(255) NOT NULL,
  template_id UUID REFERENCES templates(id),
  bride_name VARCHAR(255) NOT NULL,
  groom_name VARCHAR(255) NOT NULL,
  wedding_date DATE NOT NULL,
  venue VARCHAR(500),
  custom_message TEXT,
  status VARCHAR(50) DEFAULT 'pending',
  video_url TEXT,
  payment_status VARCHAR(50) DEFAULT 'pending',
  amount_cents INTEGER,
  transaction_id VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  delivered_at TIMESTAMP,
  admin_notes TEXT
);

-- Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_templates_active ON templates(is_active);
CREATE INDEX IF NOT EXISTS idx_templates_category ON templates(category);
CREATE INDEX IF NOT EXISTS idx_user_favorites_user ON user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_template ON user_favorites(template_id);
