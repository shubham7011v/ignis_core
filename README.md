# Vivaah - Premium Wedding Invitations

[![Flutter](https://img.shields.io/badge/Flutter-3.10-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**Vivaah** is a premium, offline-first wedding invitation video creator. It allows users to download cinematic templates, customize them with their wedding details, and render high-quality MP4 invitations directly on their device.

## 🚀 Key Features (v1.0)
*   **Offline Rendering**: Zero-server video generation using `FFmpegKit`.
*   **Cinematic Templates**: Professional 1080p templates powered by YouTube CDN.
*   **Privacy First**: All data stays on your device. No login required.
*   **Instant Sharing**: Share directly to WhatsApp or Instagram.

## 🛠️ Tech Stack
*   **Framework**: Flutter (Dart)
*   **Video Engine**: FFmpegKit (LTS)
*   **Template Source**: YouTube (via `youtube_explode_dart`)
*   **Architecture**: BLoC + Clean Architecture

## 📱 Getting Started
1.  Clone the repository
2.  Run `flutter pub get`
3.  Run `flutter run` on an Android device

## 📄 Documentation
*   [Roadmap](docs/roadmap.md): Release schedule and future plans.
*   [Architecture](docs/architecture.md): Technical deep-dive.
*   [Dev Deployment Guide](docs/dev_deployment_guide.md): Automated deployment for Dev environment.
*   [Production Deployment Guide](docs/production_deployment_guide.md): Guide for Production environment.
