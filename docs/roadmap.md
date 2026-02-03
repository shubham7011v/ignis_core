# Vivaah Implementation Roadmap

> **Strategy Shift**: Prioritize a **client-only MVP (v1.0)** for rapid market validation, then layer in cloud features based on user demand.

---

## 🎯 Current Focus: v1.0 MVP - Client-Only Release

### ✅ **Phase 1: Foundation** (COMPLETE)
- [x] YouTube CDN Integration
- [x] Template Download System (`youtube_explode_dart`)
- [x] Royal Theme UI Foundation

### ✅ **Phase 2: Client-Side Rendering** (COMPLETE)
- [x] Integrated FFmpegKit for local video composition
- [x] Text-on-video overlay with custom wedding details
- [x] Progress visualization during rendering
- [x] Sharing and Gallery export

### 🔄 **Phase 3: v1.0 MVP Preparation** (IN PROGRESS)
**Goal**: Ship a standalone Android app with zero backend dependencies.

- [ ] **Disable Firebase Integration** (Do not remove code)
    - [ ] Comment out `firebase_auth`, `firebase_crashlytics`, `firebase_analytics` usage
    - [ ] Comment out `FirebaseAppCheck` and Firebase initialization in `main_common.dart`
    - [ ] Simplify app boot to skip server config sync
- [ ] **Disable Auth & Profile Features** (Do not remove code)
    - [ ] Disable login/logout flows (Hidden UI)
    - [ ] Detach `AuthBloc`, `ProfileBloc`, and related UI screens from active flow
    - [ ] Bypass onboarding in navigation (Keep code intact)
- [ ] **Integrate Google Play Billing**
    - [ ] Add `in_app_purchase` package
    - [ ] Implement one-time payment for "Premium Templates" pack
    - [ ] Local license validation (no server required)
- [ ] **Template Catalog Hardcoding**
    - [ ] Embed 5-10 curated template configs directly in app
    - [ ] Map YouTube video IDs to local JSON
- [ ] **Polish & Testing**
    - [ ] Test on low-end Android devices (API 24+)
    - [ ] Verify FFmpeg rendering performance
    - [ ] Asset optimization (reduce APK size)

---

## 🚀 **Future Phases** (Post v1.0 Launch)

### **Phase 4: User Accounts & Cloud Sync** (v2.0)
*Deploy only if v1.0 gains traction (>1000 active users)*

- [ ] Reintroduce Firebase Authentication
- [ ] Cloud storage for user's created videos (Firebase Storage)
- [ ] Cross-device video history sync
- [ ] Analytics and crash reporting

### **Phase 5: Server-Side Rendering** (v3.0)
*Deploy if client-side rendering fails on >20% of devices*

- [ ] Go `VideoService` with FFmpeg workers
- [ ] Render Job Queue (Worker Pool)
- [ ] Job Status API endpoints
- [ ] Cloud deployment to VPS (Hostinger/Fly.io)

### **Phase 6: Hybrid Intelligence** (v4.0)
- [ ] Device capability benchmarking
- [ ] Auto-fallback to server for low-end devices
- [ ] HD Premium tier (server-rendered 4K videos)

---

## 📦 Release Timeline

| Version | Description | Target Date |
| :--- | :--- | :--- |
| **v1.0** | Client-only MVP with Google Play payment | 2 weeks |
| **v2.0** | User accounts + Cloud sync | 6-8 weeks post-launch |
| **v3.0** | Server rendering for premium users | 12 weeks post-launch |
