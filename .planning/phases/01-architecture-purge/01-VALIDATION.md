# Phase 1: Architecture Purge & JSON Sync - Validation Strategy

**Phase:** 01
**Slug:** architecture-purge
**Date:** 2026-04-28

## Validation Architecture

### Automated Tests
- **Purge Audit**: Verify that `mongoose` is removed from `package.json` and `node_modules`.
- **API Functional Test**: Run `curl -I http://localhost:3000/api/stations` and verify:
    - Status: `200 OK`.
    - Content: Valid JSON station list.
    - Headers: Contains an `ETag`.
- **Conditional Fetch Test**: Run `curl -I -H "If-None-Match: [ETag]" http://localhost:3000/api/stations` and verify status is `304 Not Modified`.
- **Scraper Audit**: Run the scraper script and verify it produces a valid `src/data/radio-browser-cache.json` without attempting to connect to MongoDB.

### Manual Verification
- **Web App**: Open the web app on Vercel (or local dev) and verify station search/filtering still works correctly.
- **Mobile App**: Run the Flutter app and verify it successfully fetches and caches the station list on startup.
- **Background Play**: Verify that audio still plays on mobile even after the DB removal.

## Success Criteria (Must-Haves)
- [ ] No MongoDB/Mongoose references in `src/` or `scripts/`.
- [ ] `api/stations` returns `304` when `If-None-Match` matches.
- [ ] Mobile app starts up instantly using cached JSON.

---
*Validation strategy defined: 2026-04-28*
