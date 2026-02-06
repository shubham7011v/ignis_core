#!/bin/bash
# Hostinger VPS Audit Script for Ignis (Vivaah) Deployment
# Run this via SSH to verify your environment

echo "🔍 --- VPS Audit Report ---"
date

echo -e "\n🐳 1. Docker Status"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n🔌 2. Port Occupancy (8080-8083)"
netstat -tulpn | grep -E '8080|8081|8082|8083'

echo -e "\n📂 3. Directory Structure Review"
ls -d /opt/ignis /root/veil_core 2>/dev/null || echo "Directories not yet created"

echo -e "\n🌐 4. Nginx Configuration Check"
if [ -f /etc/nginx/sites-enabled/default ]; then
    echo "Default config exists"
fi
ls /etc/nginx/sites-enabled/

echo -e "\n📦 5. Resource Check"
df -h / | grep /
free -m | grep Mem

echo -e "\n✅ Audit Complete"
