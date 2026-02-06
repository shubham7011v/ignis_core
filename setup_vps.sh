#!/bin/bash

# Ignis (Vivaah) VPS Setup Script
# Run this script after SSH'ing into your VPS as root

set -e  # Exit on error

echo "🚀 Starting Ignis (Vivaah) Setup on VPS..."

# Configuration
ENVIRONMENT=${1:-dev}  # Default to dev if not specified
APP_DIR="/opt/ignis/${ENVIRONMENT}"
REPO_URL="https://github.com/shubham7011v/ignis_core.git"

echo "📋 Environment: $ENVIRONMENT"
echo "📂 Installation Directory: $APP_DIR"

# 1. Check Prerequisites
echo "🔍 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
fi

if ! command -v git &> /dev/null; then
    echo "❌ Git not found. Installing..."
    apt-get update && apt-get install -y git
fi

echo "✅ Prerequisites satisfied"

# 2. Create Directory Structure
echo "📂 Setting up directories..."
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# 3. Clone or Update Repository
if [ -d "ignis_core" ]; then
    echo "🔄 Updating existing repository..."
    cd ignis_core
    git fetch --all
    git pull origin main
    cd ..
else
    echo "📥 Cloning repository..."
    git clone "$REPO_URL" ignis_core
fi

cd ignis_core

# 4. Environment Configuration
echo "⚙️ Configuring environment..."

# Prompt for required secrets
echo ""
echo "📝 Please provide the following configuration:"
read -p "Database Password: " DB_PASSWORD
echo ""
echo "Firebase credentials needed. Please ensure firebase-adminsdk.json is uploaded to:"
echo "  $APP_DIR/ignis_core/server/firebase-adminsdk.json"
echo ""
read -p "Press Enter to continue once you've uploaded the file..."

# Create .env file
if [ "$ENVIRONMENT" = "prod" ]; then
    cat <<EOF > server/.env
PORT=8080
GIN_MODE=release
DB_HOST=db
DB_PORT=5432
DB_USER=ignis_user
DB_PASSWORD=$DB_PASSWORD
DB_NAME=ignis_db
FIREBASE_CREDENTIALS_PATH=/root/firebase-adminsdk.json
ALLOWED_ORIGINS=https://iamsorry.in,https://api.vivaah.iamsorry.in
DOMAINS=api.vivaah.iamsorry.in
EOF
    COMPOSE_FILE="docker-compose-ignis-prod.yml"
    PORT=8083
else
    cat <<EOF > server/.env
PORT=8080
GIN_MODE=debug
DB_HOST=db
DB_PORT=5432
DB_USER=ignis_user
DB_PASSWORD=$DB_PASSWORD
DB_NAME=ignis_db
FIREBASE_CREDENTIALS_PATH=/root/firebase-adminsdk.json
ALLOWED_ORIGINS=*
DOMAINS=dev-api.vivaah.iamsorry.in
EOF
    COMPOSE_FILE="docker-compose-ignis-dev.yml"
    PORT=8082
fi

echo "✅ Environment configured"

# 5. Copy Docker Compose
echo "🐳 Preparing Docker Compose..."
cp "$COMPOSE_FILE" docker-compose.yml

# 6. Build and Start Containers
echo "🏗️ Building and starting containers..."
docker compose build server
docker compose up -d --remove-orphans

# 7. Cleanup
echo "🧹 Cleaning up..."
docker system prune -f

# 8. Health Check
echo "🏥 Performing health check..."
sleep 10

if curl -s http://localhost:$PORT/health | grep -q "ok"; then
    echo "✅ Ignis $ENVIRONMENT deployment successful!"
    echo ""
    echo "📊 Container Status:"
    docker ps | grep ignis
    echo ""
    echo "🌐 Service is running on port $PORT"
    echo "📝 Logs: docker logs ignis-${ENVIRONMENT}"
else
    echo "❌ Health check failed!"
    echo "📋 Recent logs:"
    docker compose logs --tail=50
    exit 1
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Configure Nginx to proxy to localhost:$PORT"
echo "2. Set up SSL with certbot"
echo "3. Update DNS for your domain"
