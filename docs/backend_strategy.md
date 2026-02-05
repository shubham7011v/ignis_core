# Production Strategy: Hybrid Backend Cost Optimization

To minimize production costs for Vivaah, we will use a **Hybrid Approach** leveraging both **Firebase (SaaS)** and a **Go Server (VPS)**.

## 1. Core Principles
- **"Free Tier Only" Policy**: Design every interaction to ensure Firebase usage (Firestore, Auth, Messaging) NEVER exceeds the Spark (Free) tier limits.
- **VPS as Primary Logic Engine**: Use the fixed-cost Go VPS for all heavy data storage, complex queries, and administrative overhead.

## 2. Resource Allocation

| Component | Provider | Why? | Cost Tactic |
| :--- | :--- | :--- | :--- |
| **Authentication** | Firebase Auth | Secure & Free (Spark Tier) | Use **Google Sign-In ONLY** to avoid rolling custom auth. |
| **Order Metadata** | Firestore | **Sync Only** | Use Firestore ONLY for status updates. Move full order history/details to the VPS DB. |
| **Admin Panel** | Go (VPS) | $0 Over Free | All admin reads/writes happen directly on the VPS database to save Firebase quotas. |
| **Database (Primary)**| **PostgreSQL (VPS)**| **Fixed Cost** | Store comprehensive logs, user profiles, and order details here. |
| **Image/Icon Assets** | Firebase Storage | Fast, CDN-backed | Move high-traffic, unchanging assets to a cheap CDN like **Cloudflare R2** if costs grow. |
| **Video Hosting** | YouTube | **Free Storage/Bandwidth** | Hosting completed videos as "Unlisted" on YouTube costs **$0**. |
| **Cron Jobs / Tasks** | Go (VPS) | Free on VPS | Running periodic checks on orders is free on a 24/7 VPS. |

## 3. Cost Minimization Blueprint

### A. The "Zero-Cost" Delivery Flow
1. **App** sends order to **Firestore** (Free tier covers ~20k writes/day).
2. **Go Server (VPS)** listens to Firestore changes ($0 additional cost).
3. **Admin Dashboard** (Self-hosted on VPS) alerts staff.
4. **Admin** creates video locally ($0 cloud compute).
5. **Admin** uploads to **YouTube** ($0 storage/bandwidth).
6. **Go Server** updates Firestore with the YouTube ID (1 write).

### B. Scalability vs Cost
- **VPS ($5-10/month)**: Fixed cost. We can scale the number of Go workers or API calls to millions without extra cost (limited only by RAM/CPU).
- **Firebase ($ Variable)**: We only pay for excessive Reads/Writes. By using the Go server to **cache** data or aggregate stats, we reduce Firebase Reads from the Admin side.

## 4. Why this is the best for Production?
1. **Stability**: Firebase Handles the heavy lifting of user connectivity and offline sync.
2. **Flexibility**: Go allows us to write custom scripts for bulk order management or integration with WhatsApp/Email APIs without paying "Function execution" fees.
3. **Portability**: If Firebase becomes too expensive, the Go logic is already written to be migrated to a standard SQL database on the same VPS.

---
> [!IMPORTANT]
> By using **YouTube** as our primary video delivery CDN, we save almost **99%** of the potential storage and streaming costs associated with wedding videos (which are usually large HD/4K files).
