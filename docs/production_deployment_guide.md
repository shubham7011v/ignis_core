# Ignis (Vites) Production Deployment Guide

## Overview
This guide explains how to deploy Ignis (Vites) to production on the same VPS, running alongside Dev and Veil services.

## Environment Architecture

### Port Allocation
| Service | Port | URL |
|---------|------|-----|
| Veil Dev | 8080 | `http://72.62.197.76:8080` |
| Veil Prod | 8081 | `http://72.62.197.76:8081` |
| **Ignis Dev** | 8082 | `http://72.62.197.76:8082` → `dev.vites.iamsorry.in` |
| **Ignis Prod** | 8083 | `http://72.62.197.76:8083` → `vites.iamsorry.in` |

### Container Structure
Each environment runs **2 containers**:
- **App Container**: Go server (Gin)
- **DB Container**: PostgreSQL 18

## Production Configuration

### Key Differences: Dev vs Prod

| Setting | Dev | Prod |
|---------|-----|------|
| **GIN_MODE** | `debug` | `release` |
| **ALLOWED_ORIGINS** | `*` (all) | `https://vites.iamsorry.in` |
| **DOMAINS** | `dev.vites.iamsorry.in` | `vites.iamsorry.in` |
| **DB_PASSWORD** | `ignis_secure_pass_2026` | `ignis_prod_secure_pass_2026` |
| **Database Volume** | `ignis_dev_pg_data` | `ignis_prod_pg_data` |

### Environment Variables (Inline Method)

Both Dev and Prod now use **inline environment variables** (matching Veil's approach):

```yaml
environment:
  - GIN_MODE=release
  - PORT=${PORT:-8080}
  - DB_HOST=db
  - DB_USER=${DB_USER:-vites_user}
  - DB_PASSWORD=${DB_PASSWORD:-ignis_prod_secure_pass_2026}
```

**Benefits**:
- ✅ Visible in dashboard UIs (Portainer/Coolify)
- ✅ Easy to override via shell environment or `.env` file in `/opt/ignis/prod/`
- ✅ Defaults work out-of-the-box

## Deployment Steps

### Manual Deployment (SSH Method)

#### 1. Prepare Deployment Package
```bash
# On local machine
cd c:\Users\u32n08\Documents\ignis_core
Compress-Archive -Path server,docker-compose-ignis-prod.yml,setup_vps.sh `
  -DestinationPath ignis_prod_deploy.zip -Force
```

#### 2. Transfer to VPS
```bash
scp -i "C:\Users\u32n08\.ssh\id_rsa_hostinger" `
  ignis_prod_deploy.zip root@72.62.197.76:/root/
```

#### 3. Deploy on VPS
```bash
ssh -i "C:\Users\u32n08\.ssh\id_rsa_hostinger" root@72.62.197.76

# On VPS
mkdir -p /opt/ignis/prod
unzip -o /root/ignis_prod_deploy.zip -d /opt/ignis/prod
cd /opt/ignis/prod
mv docker-compose-ignis-prod.yml docker-compose.yml

# Optional: Create .env to override defaults
cat > .env << 'EOF'
DB_PASSWORD=your_custom_prod_password
ALLOWED_ORIGINS=https://vites.iamsorry.in
EOF

# Start containers
docker compose up -d

# Verify
docker ps
curl http://localhost:8083/health
```

### GitHub Actions Deployment (Automated)

#### Prerequisites
Add these secrets to GitHub repository (`Settings → Secrets and variables → Actions`):

| Secret Name | Value | Purpose |
|-------------|-------|---------|
| `SERVER_IP` | `72.62.197.76` | VPS IP address |
| `SSH_KEY` | `<private key content>` | SSH private key for VPS access |
| `DB_PASSWORD` | `ignis_prod_secure_pass_2026` | Production database password |
| `FIREBASE_SERVICE_ACCOUNT` | `<JSON content>` | Firebase Admin SDK credentials |

#### Workflow Trigger
Production deployment triggers on **Git tags**:
```bash
# Create and push a production tag
git tag vites_prod_v1.0.0
git push origin vites_prod_v1.0.0
```

The workflow will:
1. Build the Go binary on GitHub runners
2. Transfer files to `/opt/ignis/prod/` via SCP
3. Restart containers via SSH
4. Verify health endpoint

## Post-Deployment Configuration

### 1. Nginx Reverse Proxy
Configure Nginx to route domain traffic:

```nginx
# /etc/nginx/sites-available/ignis-prod
server {
    listen 80;
    server_name vites.iamsorry.in;
    
    location / {
        proxy_pass http://localhost:8083;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 2. SSL Certificate (Let's Encrypt)
```bash
certbot --nginx -d vites.iamsorry.in
```

### 3. Database Migrations
The server auto-runs migrations on startup. To manually check:
```bash
docker exec ignis-prod-db psql -U vites_user -d vites_db -c '\dt'
```

## Monitoring & Maintenance

### View Logs
```bash
# App logs
docker logs ignis-prod -f --tail=50

# Database logs
docker logs ignis-prod-db --tail=20
```

### Restart Services
```bash
cd /opt/ignis/prod
docker compose restart server
```

### Database Backup
```bash
docker exec ignis-prod-db pg_dump -U vivaah_user vivaah_db > backup_$(date +%Y%m%d).sql
```

### Update Environment Variables
Edit `/opt/ignis/prod/.env` and restart:
```bash
docker compose restart
```

## Rollback Procedure
If production deployment fails:

```bash
# Restore previous version
cd /opt/ignis/prod
docker compose down
# Restore previous zip backup
unzip -o /root/ignis_prod_deploy_backup.zip
docker compose up -d
```

## Security Checklist
- [ ] Change default `DB_PASSWORD` in production
- [ ] Restrict `ALLOWED_ORIGINS` to your domain only
- [ ] Enable SSL/TLS via Nginx + Certbot
- [ ] Set up firewall rules (UFW) to block direct port 8083 access
- [ ] Enable PostgreSQL connection encryption
- [ ] Rotate Firebase service account keys regularly
