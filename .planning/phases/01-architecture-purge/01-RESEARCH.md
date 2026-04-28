# Phase 1 Research: Architecture Purge & JSON Sync

## Mongoose Decommissioning
- **Impacted Files**:
    - `package.json`: Remove `mongoose` (9.4.1).
    - `src/lib/mongodb.ts`: Delete connection pooling logic.
    - `src/models/Station.ts`: Delete schema and model definition.
    - `src/app/api/stations/route.ts`: Remove DB dependency.
    - `scripts/scrape-and-upload-stations.mjs`: Remove MongoDB upload logic.
- **Scraper Strategy**: The scraper already has the logic to generate a JSON cache. We will redirect the "Upload" step to Firebase Storage instead of MongoDB.

## Memory-Based API (Next.js)
- **Performance**: A 1-2MB JSON file can be parsed and filtered in <10ms in a Node.js runtime.
- **Caching**: We will read the file once at the module level (top-level scope) so it's cached in the serverless function's instance memory between requests.

## ETag Implementation
### Next.js
- **Strategy**: Generate an MD5 hash of the JSON content. Check `If-None-Match` header.
- **Response**: Return `304 Not Modified` if hashes match.

### Flutter
- **Strategy**: Use `dio` with `dio_cache_interceptor` for automatic ETag handling, or manually store the `ETag` in `shared_preferences` and send `If-None-Match`.

## Stream Validation
- **HEAD Requests**: Implement lightweight pre-checks in the sync script to flag offline stations in the JSON.
- **Retry Logic**: Mobile app should use exponential backoff for re-connecting to streams.

---
*Research synthesized: 2026-04-28*
