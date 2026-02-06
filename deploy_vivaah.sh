#!/bin/bash

# Vivaah Deployment Script
# Usage: ./deploy_vivaah.sh

APP_DIR="/opt/vivaah"
REPO_URL="https://github.com/your-username/ignis_core.git" # User: Update this!

echo "🚀 Starting Vivaah Deployment..."

# 1. Check prerequisites
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "❌ Git not found. Installing..."
    apt-get update && apt-get install -y git
fi

# 2. Setup Directory
if [ ! -d "$APP_DIR" ]; then
    echo "📂 Creating directory $APP_DIR..."
    mkdir -p "$APP_DIR"
    chown -R $USER:$USER "$APP_DIR"
fi

cd "$APP_DIR"

# 3. Clone or Pull
if [ -d "ignis_core" ]; then
    echo "🔄 Updating existing code..."
    cd ignis_core
    git pull origin main
    cd ..
else
    echo "📥 Cloning repository..."
    git clone "$REPO_URL"
    cd ignis_core
fi

# 4. Setup Secrets
SERVER_DIR="$APP_DIR/ignis_core/server"

if [ ! -f "$SERVER_DIR/.env" ]; then
    echo "⚠️ .env file missing in $SERVER_DIR"
    echo "Creating from example..."
    cp "$SERVER_DIR/.env.example" "$SERVER_DIR/.env"
    echo "📝 Please edit $SERVER_DIR/.env with real credentials!"
    
    # Simple interactive prompt
    read -p "Enter DB Password: " DB_PASS
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" "$SERVER_DIR/.env"
    
    # Set docker specific config
    sed -i "s/DB_HOST=.*/DB_HOST=db/" "$SERVER_DIR/.env"
    sed -i "s|FIREBASE_CREDENTIALS_PATH=.*|FIREBASE_CREDENTIALS_PATH=/root/firebase-adminsdk.json|" "$SERVER_DIR/.env"
fi

# 5. Firebase Credentials
if [ ! -f "$SERVER_DIR/firebase-adminsdk.json" ]; then
    echo "❌ firebase-adminsdk.json missing in $SERVER_DIR"
    echo "Please upload it: scp firebase-adminsdk.json user@host:$SERVER_DIR/"
    exit 1
fi

# 6. Launch Docker
echo "🐳 Launching containers..."
# Use the docker-compose in the root
docker-compose -f docker-compose.yml up -d --build

echo "✅ Deployment Complete!"
echo "Server running on port 8082"
echo "Check logs: docker-compose logs -f"
