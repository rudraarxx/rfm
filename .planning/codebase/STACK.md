# Technology Stack

**Analysis Date:** 2026-04-28

## Languages

**Primary:**
- TypeScript 5.x - Next.js application code, API routes, and scripts.
- Dart 3.11.x - Flutter mobile application code (`rfm_mobile`).

**Secondary:**
- JavaScript (MJS) - Maintenance scripts and data fetching (`scripts/*.mjs`).
- CSS (Tailwind CSS 4) - Styling for the web application.

## Runtime

**Environment:**
- Node.js 20.x - Web server and scripts.
- Flutter SDK - Mobile app build and execution.
- MongoDB - Database for station data.
- Firebase Storage - Cloud storage for public JSON cache.

**Package Manager:**
- npm 10.x / yarn - Web project dependencies.
- pub - Flutter project dependencies.

## Frameworks

**Core:**
- Next.js 16.2.3 - Web framework (App Router).
- Flutter - Cross-platform mobile framework.
- Tailwind CSS 4 - Utility-first CSS framework.

**Testing:**
- Vitest 4.1.4 - Web unit and integration tests.
- flutter_test - Flutter unit and widget tests.

**Build/Dev:**
- TypeScript Compiler - Web transpilation.
- Build Runner - Flutter code generation (Riverpod).

## Key Dependencies

**Critical:**
- `mongoose` 9.4.1 - MongoDB object modeling.
- `framer-motion` 12.38.0 - Web animations.
- `just_audio` (Flutter) - Core audio playback engine.
- `audio_service` (Flutter) - Background audio and media session.
- `flutter_riverpod` - State management for the mobile app.
- `zustand` - State management for the web app.

## Configuration

**Environment:**
- `.env.local` - Web environment variables (Firebase, MongoDB).
- `firebase-service-account.json` - Credential for cloud uploads.

**Build:**
- `tsconfig.json` - TypeScript configuration.
- `pubspec.yaml` - Flutter project configuration.
- `next.config.ts` - Next.js configuration.

## Platform Requirements

**Development:**
- macOS (recommended for iOS development).
- Flutter SDK & Android Studio / Xcode.
- Node.js environment.

**Production:**
- Vercel (Web deployment).
- Google Play Store / Apple App Store (Mobile).
- MongoDB Atlas (Database).

---

*Stack analysis: 2026-04-28*
