# 🖥️ VPS Setup & Deployment Log

## Server Details
- **Provider**: Hostinger
- **IP Address**: `72.62.197.76`
- **OS**: Ubuntu 22.04 LTS (presumed based on standard images)
- **User**: `root` (SSH Key Authentication)

---

## 🕒 Chronological Activity Log

### 1. Initial Access & Reconciliation
- **Discovery**: Connected via SSH to explore existing setup.
- **Findings**:
    - `Veil` (Game Server) was already running (Docker containers `veil-game-dev` & `veil-game-prod`).
    - `Veil` files located in `/root/veil_core` and managed via `/root/docker-compose.yml`.
    - No existing `Ignis` folders found.

### 2. Environment Preparation
- **Directory Structure**: Created `/opt/ignis/dev` and `/opt/ignis/prod` for clean separation.
- **Docker**: Verified Docker and Docker Compose were already installed and active (version 24.0.5+).

### 3. Deployment Attempts (Iterative Process)

#### Attempt v1-v3: The "Go Version" Saga
- **Issue**: Build failed with `go: go.mod requires go >= 1.25.5`. The `Dockerfile` was using `golang:1.21`.
- **Action**: Updated `Dockerfile` to use `golang:1.25-alpine`.
- **Result**: Build proceeded but failed on code errors.

#### Attempt v4: The "Missing Model" Error
- **Issue**: Compilation failed with `undefined: models.Short`.
- **Action**: Modified `sharing_service.go` to use `models.Template` instead (Architecture alignment).
- **Result**: Fixed type error, but revealed unused variables.

#### Attempt v5: The "Unused Variable" Strictness
- **Issue**: Go compiler (strict mode) rejected unused `id` and `short` variables in `sharing.go`.
- **Action**: Replaced variables with blank identifier `_`.
- **Result**: **Code Compiled Successfully!** 🎉

### 4. Runtime Troubleshooting (The "Crash Loop")

#### The Database Credential Mismatch
- **Symptoms**: Containers started but `ignis-dev` kept restarting. Logs showed `pq: password authentication failed for user "vivaah_user"`. (Note: `vivaah_user` is the internal DB user, kept for legacy compatibility).
- **Root Cause**:
    - Server `.env` file had: `DB_PASSWORD=local_pass`
    - `docker-compose.yml` had: `POSTGRES_PASSWORD=ignis_secure_pass_2026`
- **Fix**: Updated `.env` on VPS to use the correct secure password.

#### The "Stale Volume" Problem
- **Symptoms**: Even after fixing `.env`, auth still failed.
- **Root Cause**: The Docker Volume (`ignis_dev_pg_data`) was initialized with the *old* wrong password and persisted.
- **Fix**: Ran `docker compose down -v` to delete the volume and force a fresh DB initialization.

#### The "Dirty Migration" State
- **Symptoms**: DB connected, but app crashed with `Dirty database version 1`.
- **Cause**: Flawed initial migration run during the crash loop left the DB in a strictly locked state.
- **Fix**: Manually forced the state clean:
  ```sql
  UPDATE schema_migrations SET dirty=false WHERE version=1;
  ```

### 5. Final Configuration (Success State)
- **Deployment**: Manual SSH transfer of `ignis_deploy_v6.zip`.
- **Architecture**:
    - **Ignis Dev**: Port 8082 (Mapped to container 8080).
    - **Ignis DB**: Internal Port 5432 (Isolated network).
- **Env Variables**: Converted to **Inline** format in `docker-compose.yml` (matching `Veil`'s pattern) for better visibility.

---

## 🛡️ Security & Maintenance
- **SSH Access**: Configured with private key (`id_rsa_hostinger`).
- **Firewall**: Ports 8080-8083 are currently exposed (need locking down after Nginx setup).
- **Data Persistence**: Docker volumes `ignis_dev_pg_data` and `ignis_prod_pg_data` ensure data survives restarts.

## 📂 File Locations on Server
- **Ignis Dev**: `/opt/ignis/dev/`
- **Ignis Prod**: `/opt/ignis/prod/` (Created but not fully active)
- **Ignis Logs**: `docker logs ignis-dev`, `docker logs ignis-prod`

---

## 📜 Rebranding Log (Feb 2026)
- **Decision**: App renamed from **Vivaah** to **Vites**.
- **Domain**: Switched from `vivaah.iamsorry.in` to `vites.iamsorry.in`.
- **Impact**: 
    - Internal DB User/Name (`vivaah_user`) preserved to prevent data migration issues.
    - Public URLs updated in `production_deployment_guide.md`.
