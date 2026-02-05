# Backup Strategy

## 1. Overview
This document outlines the backup procedures for the Vivaah platform to ensure data durability and disaster recovery capability.

## 2. Codebase Backups
- **Source Control**: Bitbucket / GitHub (Primary)
- **Local Mirror**: Daily sync to developer machine.
- **Frequency**: Continuous (on push).

## 3. Database Backups (PostgreSQL on VPS)
- **Tool**: `pg_dump` + `cron`
- **Schedule**:
    - **Daily Full Backup**: At 03:00 UTC.
    - **Retention**: Keep last 7 days locally on VPS.
    - **Off-site Upload**: Upload daily dump to **Google Drive / AWS S3** (encrypted).

### 3.1 Backup Script (vps_backup.sh)
```bash
#!/bin/bash
TIMESTAMP=$(date +"%F")
BACKUP_DIR="/var/backups/postgres"
FILENAME="$BACKUP_DIR/vivaah_db_$TIMESTAMP.sql.gz"

# 1. Bump Database
pg_dump -U postgres vivaah_db | gzip > $FILENAME

# 2. Upload to Cloud (Example with rclone)
rclone copy $FILENAME remote:vivaah-backups/

# 3. Cleanup old backups (older than 7 days)
find $BACKUP_DIR -type f -mtime +7 -name "*.sql.gz" -delete
```

## 4. Firebase Data
- **Firestore**: Use export tool manually before major migrations.
- **Auth**: Use `firebase auth:export` monthly.

## 5. Recovery Plan
1. **Provision new VPS**.
2. **Install PostgreSQL**.
3. **Restore from latest SQL dump**:
   ```bash
   gunzip -c vivaah_db_2024-01-01.sql.gz | psql -U postgres vivaah_db
   ```
4. **Redeploy Go Server**.
