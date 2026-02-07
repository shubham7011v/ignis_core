# 🎨 Ignis / Vites Brand Identity & Configuration

## 📛 Naming Conventions
| Context | Old Value | **New Value** |
| :--- | :--- | :--- |
| **App Name (Public)** | Vivaah | **Vites** |
| **Tagline** | Wedding Invitation Video App | **Video Invitation App** |
| **Internal Codename** | Ignis | **Ignis** (Preserved) |
| **Domain (Public)** | `vivaah.iamsorry.in` | **`vites.iamsorry.in`** |
| **API Domain** | `api.vivaah.iamsorry.in` | **`vites.iamsorry.in`** (Direct) |

## 🆔 Technical Identifiers (Package IDs)
| Platform | Old ID | **New ID** | Notes |
| :--- | :--- | :--- | :--- |
| **Android Application ID** | `com.ignis.vivaah` | **`com.iamsorry.vites`** | Changed to match domain structure. |
| **iOS Bundle ID** | `com.ignis.vivaah` | **`com.iamsorry.vites`** | Changed to match Android. |
| **Server Package Reference** | `com.vivaah.app` | **`com.iamsorry.vites`** | Used for Deep Linking (AssetLinks). |
| **Firebase Project** | `vivaah-ignis-prod` | **(Create New)** | Requires new `google-services.json`. |

## 🌍 Network Configuration
- **Production URL**: `https://vites.iamsorry.in`
- **Dev URL**: `https://dev.vites.iamsorry.in`
- **Support Email**: `support@iamsorry.in` (Suggested)

## 🎨 Visual Identity
- **Primary Color**: Burgundy (`#7E1E3F`) - *Kept from Vivaah for now, can change.*
- **Accent Color**: Gold - *Kept for premium feel.*
- **Font**: Cinzel (Titles), Lato (Body).

## ⚠️ Migration Notes
- **Firebase**: Since the package name changed, a **NEW** Firebase project (or new App within existing project) is mandatory. The old `google-services.json` file is now invalid for this build.
- **Play Store**: Upload this as a **NEW** application. Do not try to update an existing track if you had one.
