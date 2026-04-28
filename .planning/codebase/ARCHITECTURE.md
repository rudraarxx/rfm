# Architecture

**Analysis Date:** 2026-04-28

## Pattern Overview

**Overall:** Hybrid Web-Mobile Radio Application (Music OS).

**Key Characteristics:**
- **Local-First Discovery**: App loads a cached station index for instant startup.
- **Background Persistence**: Mobile app uses native audio services for background playback.
- **Sync-Driven Maintenance**: Stations are scraped/fetched and synced to the cloud via maintenance scripts.
- **Glassmorphic UI**: Premium visual language shared across web and mobile.

## Layers (Web)

**App Router (Next.js):**
- Purpose: Frontend delivery and API endpoints.
- Location: `src/app/`
- Key Routes: `src/app/api/stations/route.ts` (Dynamic station fetching).

**Data Layer:**
- Purpose: MongoDB connection and Mongoose models.
- Location: `src/lib/mongodb.ts`, `src/models/Station.ts`.

## Layers (Mobile - Flutter)

**Presentation Layer:**
- Purpose: UI Components and Screens.
- Location: `rfm_mobile/lib/presentation/`
- Pattern: Riverpod Providers for state binding.

**Logic Layer:**
- Purpose: Audio handling and business rules.
- Location: `rfm_mobile/lib/logic/`
- Key Files: `rfm_mobile/lib/logic/audio/radio_handler.dart`.

**Data Layer:**
- Purpose: API clients and repositories.
- Location: `rfm_mobile/lib/data/`
- Key Files: `rfm_mobile/lib/data/repositories/station_repository.dart`.

## Data Flow

**Station Data Sync:**
1. Scraper script (`scripts/scrape-and-upload-stations.mjs`) runs.
2. Data is enriched with Radio Browser API details.
3. Data is uploaded to MongoDB and Firebase Storage.
4. Clients (Web/Mobile) fetch the index on startup.
5. User selects a station; `just_audio` (mobile) or HTML5 Audio (web) handles the stream.

## Error Handling

**Web:**
- Next.js Error Boundaries.
- Try/Catch blocks in API routes with JSON error responses.

**Mobile:**
- Async catchError in repositories.
- Toast notifications (Sonner-like) for stream failures.

---

*Architecture analysis: 2026-04-28*
