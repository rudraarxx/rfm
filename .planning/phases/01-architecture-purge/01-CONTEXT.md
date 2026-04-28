# Phase 1: Architecture Purge & JSON Sync - Context

**Gathered:** 2026-04-28
**Status:** Ready for planning

<domain>
## Phase Boundary
This phase decommissions the MongoDB/Mongoose layer across the web application and maintenance scripts. It establishes a high-performance, local-first synchronization model where the station directory is served as a static JSON artifact from Firebase Storage and cached locally by clients (Web/Mobile) using ETag-based conditional fetching.

</domain>

<decisions>
## Implementation Decisions

### Data Layer
- **Decommission MongoDB**: Delete `src/lib/mongodb.ts` and `src/models/Station.ts`. Remove `mongoose` from `package.json`.
- **JSON-First**: Use `src/data/radio-browser-cache.json` as the local development source of truth.

### API Layer
- **Memory-Based Search**: Update `src/app/api/stations/route.ts` to load the station JSON into memory and perform filtering (state, city, search) using standard JavaScript array methods.
- **Client Sync**: Implement `ETag` or `Last-Modified` checking in the synchronization logic to prevent redundant downloads.

### Maintenance Layer
- **Artifact-Only Scraper**: Update `scripts/scrape-and-upload-stations.mjs` to remove MongoDB upload logic. The script should only focus on generating the enriched JSON and uploading it to Firebase Storage.

### Discretion
- **Filtering Logic**: I will use a simple, performant string-matching or fuzzy-search algorithm for the in-memory station search.
- **Error States**: I will implement graceful fallbacks for when the remote JSON is unreachable (falling back to the local cached version).

</decisions>

<canonical_refs>
## Canonical References

### Database/Models
- `src/lib/mongodb.ts` — Connection pooling logic (to be deleted).
- `src/models/Station.ts` — Station schema (to be deleted).
- `src/app/api/stations/route.ts` — Current station query logic (to be refactored).

### Scripts
- `scripts/scrape-and-upload-stations.mjs` — Scraper and cloud sync entry point (to be refactored).

</canonical_refs>

<specifics>
## Specific Ideas
- Use `fs.readFileSync` for the initial load of the local JSON in the API route, then cache it globally to avoid disk I/O on every request.
- Use `just_audio`'s native caching where possible on the Flutter side.

</specifics>

<deferred>
## Deferred Ideas
- **Fuzzy Search Integration**: Advanced search (like Fuse.js) is deferred; basic keyword matching is sufficient for v1.
- **Multi-region Sync**: Sticking to a single Firebase Storage bucket for now.

</deferred>

---
*Phase: 01-architecture-purge*
*Context gathered: 2026-04-28 after discussion*
