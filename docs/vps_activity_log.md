# 🖥️ VPS Setup & Deployment Log

## Server Details
- **Provider**: Hostinger
- **IP Address**: `72.62.197.76`
- **OS**: Ubuntu 22.04 LTS
- **User**: `root` (SSH Key Authentication)
- **SSH Key**: `C:\Users\u32n08\.ssh\id_rsa_hostinger`

---

## 🕒 Chronological Activity Log

### 1. Initial Access & Reconciliation (Feb 2026)
- **Discovery**: Connected via SSH to explore existing setup.
- **Findings**:
    - `Veil` (Game Server) was already running (Docker containers `veil-game-dev` & `veil-game-prod`).
    - `Veil` files located in `/root/veil_core` and managed via `/root/docker-compose.yml`.
    - No existing `Ignis` folders found.

### 2. Environment Preparation
- **Directory Structure**: Created `/opt/ignis/dev` for development environment.
- **Docker**: Verified Docker and Docker Compose were installed and active (version 24.0.5+).

### 3. Initial Deployment Attempts (Iterative Process)

#### The "Go Version" Saga
- **Issue**: Build failed with `go: go.mod requires go >= 1.25.5`. The `Dockerfile` was using `golang:1.21`.
- **Action**: Updated `Dockerfile` to use `golang:1.25-alpine`.
- **Result**: Build proceeded but failed on code errors.

#### The "Missing Model" Error
- **Issue**: Compilation failed with `undefined: models.Short`.
- **Action**: Modified `sharing_service.go` to use `models.Template` instead.
- **Result**: Fixed type error, but revealed unused variables.

#### The "Unused Variable" Strictness
- **Issue**: Go compiler rejected unused `id` and `short` variables in `sharing.go`.
- **Action**: Replaced variables with blank identifier `_`.
- **Result**: **Code Compiled Successfully!** 🎉

### 4. Runtime Troubleshooting (The "Crash Loop")

#### The Database Credential Mismatch
- **Symptoms**: Containers started but `ignis-dev` kept restarting. Logs showed `pq: password authentication failed`.
- **Root Cause**:
    - Server `.env` file had: `DB_PASSWORD=local_pass`
    - `docker-compose.yml` had: `POSTGRES_PASSWORD=ignis_secure_pass_2026`
- **Fix**: Updated `.env` on VPS to use the correct secure password.

#### The "Stale Volume" Problem
- **Symptoms**: Even after fixing `.env`, auth still failed.
- **Root Cause**: The Docker Volume was initialized with the old password and persisted.
- **Fix**: Ran `docker compose down -v` to delete the volume and force fresh DB initialization.

#### The "Dirty Migration" State
- **Symptoms**: DB connected, but app crashed with `Dirty database version 1`.
- **Cause**: Flawed initial migration run during crash loop left DB in locked state.
- **Fix**: Manually forced the state clean:
  ```sql
  UPDATE schema_migrations SET dirty=false WHERE version=1;
  ```

### 5. Vites Rebranding & DNS Setup (2026-02-07)

#### DNS Configuration
- **Action**: Added A records for Vites domains
  - `dev.vites.iamsorry.in` → `72.62.197.76`
  - `vites.iamsorry.in` → `72.62.197.76`
- **Result**: DNS propagation confirmed via Google DNS (8.8.8.8)

#### SSL Certificate Installation
- **Tool**: Certbot with Nginx plugin
- **Domains**: `dev.vites.iamsorry.in`, `vites.iamsorry.in`
- **Result**: ✅ Let's Encrypt certificates installed successfully
- **Expiry**: 2026-05-08 (auto-renewal configured)
- **Config**: `/etc/nginx/sites-available/vites`

#### The "Persistent Migration" Bug
- **Symptoms**: Service crashed with `type "datetime" does not exist` error
- **Cause**: Old migration file (`000001_init_schema.up.sql`) was embedded in Go binary via `//go:embed`
- **Attempted Fixes**:
  1. Deleted file from filesystem (didn't work - embedded in binary)
  2. Schema reset with `DROP SCHEMA public CASCADE` (error persisted)
- **Final Solution**: 
  1. Deleted obsolete migration from git repository
  2. Performed "nuclear rebuild" - removed all Docker images/containers/cache
  3. Fresh clone from GitHub with correct migration file
  4. Result: **Migrations applied successfully** ✅

#### Firebase Crash Loop
- **Symptoms**: Service crashed immediately on startup: `Failed to initialize Firebase`
- **Cause**: Firebase credentials missing, treated as fatal error in `main.go`
- **Fix**: Modified `main.go` line 27-32 to make Firebase optional
  - Changed `log.Fatalf` to `log.Printf` with warning
  - Service now runs without Firebase credentials
- **Result**: Service started successfully ✅

#### Container Naming Cleanup
- **Issue**: Docker containers still named `vivaah-dev`, `vivaah-db`
- **Cause**: VPS was using old `docker-compose.yml` instead of `docker-compose-ignis-dev.yml`
- **Fix**: Copied correct compose file: `cp docker-compose-ignis-dev.yml docker-compose.yml`
- **Result**: Containers now correctly named `vites-dev`, `vites-dev-db` ✅

### 6. **Deployment Success** ✅ (2026-02-07 12:30 IST)

- **Status**: **PRODUCTION LIVE**
- **URL**: https://dev.vites.iamsorry.in/health
- **Response**: `{"service":"vites-api","status":"ok"}`
- **Containers**:
  - `vites-dev` (Go API server) - Up and healthy
  - `vites-dev-db` (PostgreSQL 18) - Up and healthy
- **Database**: Migrations applied successfully (version 2026020601)
- **SSL**: Active with automatic HTTPS redirection

### 7. Post-Deployment Optimization (2026-02-08)

#### The "pq.StringArray" Fix (Critical Repair)
- **Symptoms**: `/api/templates` returned 500 Internal Server Error.
- **Root Cause**: Go's default `sql` package cannot scan PostgreSQL `TEXT[]` arrays directly into `[]string`.
- **Fix**: 
    - Imported `github.com/lib/pq` in `TemplateRepository` and `ShortsRepository`. (Local and VPS files updated).
    - Cast `tags` to `(*pq.StringArray)(&t.Tags)` during the `Scan` process.
- **Result**: API now correctly returns template lists with tags ✅

#### Database Seeding
- **Action**: Manually seeded the dev database (`vites_db`) with 5 initial video templates via SQL script.
- **Reason**: Database was empty, causing empty gallery state.
- **Result**: App now displays initial set of Royal/Floral templates in gallery and shorts feed ✅

#### Environment Variable Migration
- **Action**: Fully standardized configuration via `.env` files.
- **Changes**:
    - Replaced remaining hardcoded variables in `ApiConfig` and `AppConfig`.
    - Integrated `premium_product_key` and `premium_pref_key` into `.env`.
    - Established `.env.example` as the source of truth for new environments.
- **Result**: Secure, portable configuration system established ✅

---

## 📂 File Locations on Server
- **Ignis Dev**: `/opt/ignis/dev/ignis_core/`
  - `server/` (Go application)
  - `docker-compose.yml` (linked to `docker-compose-ignis-dev.yml`)
  - `.git/` (Git repository for updates)
- **Nginx Config**: `/etc/nginx/sites-available/vites`
- **SSL Certificates**: `/etc/letsencrypt/live/vites.iamsorry.in/`
- **Docker Volumes**: 
  - `ignis_core_vites-dev-pg-data` (PostgreSQL data)

---

## 🛡️ Security & Maintenance
- **SSH Access**: Configured with private key (`id_rsa_hostinger`)
- **SSL/TLS**: Let's Encrypt certificates with auto-renewal
- **HTTPS**: All traffic forced to HTTPS via Nginx
- **Database**: Strong passwords, isolated Docker network
- **Firewall**: Ports 8080-8083 exposed for dev/prod services

---

## 📜 Key Learnings

### Go Embed Directive
- Files marked with `//go:embed` are **baked into the binary** at compile time
- Deleting the file from filesystem doesn't remove it from running containers
- Solution: Full Docker rebuild (`docker compose build --no-cache`)

### PostgreSQL vs SQLite
- PostgreSQL doesn't support `DATETIME` type (use `TIMESTAMP` instead)
- Migration state persists in `schema_migrations` table
- "Dirty" migrations require manual intervention or fresh schema

### Docker Compose Volumes
- Volumes persist data even when containers are removed
- Use `docker compose down -v` to delete volumes
- Useful for forcing fresh database initialization

### Firebase Integration
- Making optional dependencies truly optional prevents deployment blockers
- Use `log.Printf` for warnings vs `log.Fatalf` for critical errors
- Service can gracefully degrade without non-essential features
