# Security & Secrets Management Guide

## 🔒 Overview

This guide documents all credentials, API keys, and secrets required for the Vivaah project. **NEVER commit actual secrets to the repository.**

---

## 📋 Required GitHub Secrets

Configure these in your GitHub repository settings under **Settings → Secrets and variables → Actions**.

### Development Environment

| Secret Name | Description | Example/Format |
|------------|-------------|----------------|
| `DEV_API_BASE_URL` | Development API endpoint | `http://dev.iamsorry.in:8080` |
| `FIREBASE_CONFIG_DEV_BASE64` | Base64-encoded Firebase config (Dev) | See instructions below |

### Production Environment

| Secret Name | Description | Example/Format |
|------------|-------------|----------------|
| `PROD_API_BASE_URL` | Production API endpoint | `https://api.iamsorry.in` |
| `FIREBASE_CONFIG_PROD_BASE64` | Base64-encoded Firebase config (Prod) | See instructions below |
| `KEYSTORE_BASE64` | Base64-encoded Android signing keystore | See instructions below |
| `KEYSTORE_PASSWORD` | Keystore password | Your keystore password |
| `KEY_ALIAS` | Key alias from keystore | `release` or your alias |
| `KEY_PASSWORD` | Key password | Your key password |

### Server Secrets (for deployment)

| Secret Name | Description | Example/Format |
|------------|-------------|----------------|
| `SERVER_DB_PASSWORD` | PostgreSQL password | Your database password |
| `SERVER_FIREBASE_CREDENTIALS` | Base64-encoded Firebase service account | See instructions below |

---

## 🔧 Setting Up Secrets

### 1. Firebase Configuration Files

**Development**:
```bash
# Encode firebase_options_dev.dart to base64
cat lib/config/firebase_options_dev.dart | base64 > firebase_dev_base64.txt

# Copy contents and add as FIREBASE_CONFIG_DEV_BASE64 in GitHub secrets
```

**Production**:
```bash
# Encode firebase_options_prod.dart to base64
cat lib/config/firebase_options_prod.dart | base64 > firebase_prod_base64.txt

# Copy contents and add as FIREBASE_CONFIG_PROD_BASE64 in GitHub secrets
```

### 2. Android Signing Keystore

**Create keystore** (if you don't have one):
```bash
keytool -genkey -v -keystore release.keystore -alias release \
  -keyalg RSA -keysize 2048 -validity 10000
```

**Encode for GitHub**:
```bash
cat android/app/release.keystore | base64 > keystore_base64.txt

# Copy contents and add as KEYSTORE_BASE64 in GitHub secrets
```

### 3. Firebase Server Credentials

```bash
# Encode Firebase Admin SDK JSON
cat server/firebase-adminsdk.json | base64 > firebase_server_base64.txt

# Copy contents and add as SERVER_FIREBASE_CREDENTIALS in GitHub secrets
```

---

## 🛠️ Local Development Setup

### Flutter App

**Option 1: Using .env file** (Recommended for simplicity)

Create `.env` in project root:
```env
API_BASE_URL=http://10.0.2.2:8080
APP_ENV=development
```

**Option 2: Using --dart-define** (Recommended for production builds)

```bash
# Android Emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

# iOS Simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8080

# Physical Device (replace with your machine's IP)
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8080
```

### Go Server

Create `server/.env`:
```env
PORT=8080
GIN_MODE=debug

DB_HOST=localhost
DB_PORT=5432
DB_USER=vivaah_user
DB_PASSWORD=local_pass
DB_NAME=vivaah_db

FIREBASE_CREDENTIALS_PATH=C:/Users/YourUsername/Documents/ignis_core/server/firebase-adminsdk.json

ALLOWED_ORIGINS=*
```

---

## 📁 Files That Must Never Be Committed

These are already in `.gitignore`, but verify:

### Root Directory
- `.env`
- `.env.local`
- `*.pem`
- `*.key`

### Server
- `server/.env`
- `server/firebase-adminsdk*.json`
- `server/service-account*.json`
- `server/init_db.ps1` (contains credentials)
- `server/seed_data.sql` (may contain sensitive data)

### Android
- `android/app/release.keystore`
- `android/key.properties`
- `android/app/google-services.json`

### iOS
- `ios/Runner/GoogleService-Info.plist`

### Flutter Config
- `lib/config/firebase_options_dev.dart` (auto-generated, contains API keys)
- `lib/config/firebase_options_prod.dart` (auto-generated, contains API keys)

---

## ✅ Security Checklist

Before committing/pushing code:

- [ ] Run `git status` to verify no `.env` files are staged
- [ ] Check no API keys are hardcoded in Dart/Go files
- [ ] Verify `.gitignore` includes all credential patterns
- [ ] Firebase config files use base64 encoding in CI/CD
- [ ] All API URLs use environment variables, not hardcoded values
- [ ] Dummy/placeholder Firebase credentials are used for local testing
- [ ] Real Firebase credentials are stored in GitHub secrets only

---

## 🚀 Production Deployment

### Building Release APK

```bash
flutter build apk \
  --dart-define=API_BASE_URL=https://api.iamsorry.in \
  --dart-define=APP_ENV=production \
  --release
```

### Building App Bundle for Play Store

```bash
flutter build appbundle \
  --dart-define=API_BASE_URL=https://api.iamsorry.in \
  --dart-define=APP_ENV=production \
  --release
```

### Server Deployment (VPS)

1. **Copy `.env` to server**:
```bash
scp server/.env.example user@your-vps:/path/to/server/.env
# Edit .env on server with real credentials
```

2. **Copy Firebase credentials**:
```bash
scp firebase-adminsdk.json user@your-vps:/path/to/server/
```

3. **Update server `.env`**:
```env
PORT=8080
GIN_MODE=release

DB_HOST=localhost
DB_PORT=5432
DB_USER=vivaah_user
DB_PASSWORD=YOUR_STRONG_PASSWORD_HERE
DB_NAME=vivaah_db

FIREBASE_CREDENTIALS_PATH=/opt/vivaah/server/firebase-adminsdk.json

ALLOWED_ORIGINS=https://iamsorry.in,https://api.iamsorry.in
```

---

## 🔍 Verifying Security

### Scan for Hardcoded Secrets

```bash
# Search for potential API keys in code
git grep -i "api[-_]key"
git grep -i "secret"
git grep -i "password"
git grep -i "firebase.*api"
```

### Check .gitignore Coverage

```bash
# List all .env files (should return empty if properly ignored)
git ls-files | grep ".env"

# List Firebase credentials (should return empty)
git ls-files | grep "firebase.*json"
```

---

## 📞 Emergency: Leaked Credentials

If credentials are accidentally committed:

1. **Immediately rotate all exposed credentials**:
   - Regenerate Firebase API keys
   - Change database passwords
   - Revoke and recreate service account keys

2. **Remove from Git history**:
```bash
# Use BFG Repo-Cleaner or git-filter-repo
git filter-repo --path server/.env --invert-paths
git push --force
```

3. **Update GitHub secrets** with new credentials

4. **Notify team members** to fetch the cleaned repository

---

## 🛡️ Best Practices

1. **Use different credentials for each environment** (dev, staging, prod)
2. **Rotate secrets periodically** (every 90 days minimum)
3. **Use strong, randomly generated passwords**
4. **Enable 2FA** on Firebase, GitHub, and cloud providers
5. **Limit API key permissions** to only what's needed
6. **Monitor secret access logs** in Firebase Console
7. **Use Read-only Firebase credentials** for client apps
8. **Never log or print secrets** in application code

---

## 📚 Additional Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/get-started)
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
