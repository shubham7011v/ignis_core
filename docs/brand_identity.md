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

### Option 8: The Celebration Crest
A shield-like crest formed by two overlapping geometric shapes. One is a sleek "V" and the other is a play-button triangle pointing upwards. Together they create a diamond-like icon.
- **Colors**: Symmetrical Gold and Burgundy split.
- **Vibe**: Authoritative, stable, trustworthy.

### Option 9: The Golden Helix
Two intertwined golden lines that form a "V" while resembling a celestial orbit or a simplified DNA strand. It symbolizes the "perfect match" and eternal connection.
- **Colors**: Metallic Gold gradients on a Dark Burgundy background.
- **Vibe**: Ethereal, sophisticated, high-end.

### Option 10: The Origami Messenger
A minimalist, geometric golden origami bird whose wings are swept back to form a distinct "V" shape. Represents the "delivery" of a digital invitation with grace.
- **Colors**: Sharp Gold edges with deep Burgundy shadows.
- **Vibe**: Artistic, light, unique.

### Option 11: The Mosaic Sparkle
A "V" shape composed of tiny, sparkling golden geometric shards of varying sizes. It represents the "bits" of cinematic video and the glitter of a wedding.
- **Colors**: Multi-tonal Gold gradients.
- **Vibe**: Shimmering, festive, digital.

### Option 12: The Lotus Negative-Space
A minimalist golden lotus flower where the negative space between the petals forms a sharp, modern "V".
- **Colors**: Gold linework on a solid Burgundy field.
- **Vibe**: Spiritual, premium, clean.

## ⚠️ Migration Notes
- **Firebase**: Since the package name changed, a **NEW** Firebase project (or new App within existing project) is mandatory. The old `google-services.json` file is now invalid for this build.
- **Play Store**: Upload this as a **NEW** application. Do not try to update an existing track if you had one.
