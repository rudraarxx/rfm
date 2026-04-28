# Codebase Concerns

**Analysis Date:** 2026-04-28

## Technical Debt

**Station Data Duplication:**
- Data exists in `src/data/stationDb.ts` (Manual), `src/data/radio-browser-cache.json` (Cached), and MongoDB.
- **Risk**: Desynchronization between local cache and MongoDB.

**Environment Dependency:**
- The maintenance script depends on a local `firebase-service-account.json`.
- **Risk**: Hard to automate in CI/CD without secure secret management.

**Web-Mobile Sync:**
- Mobile app fetches from Firebase Storage, while Web might fetch from local API.
- **Risk**: Inconsistent station lists between platforms.

## Performance Concerns

**Scraping Efficiency:**
- `scrape-and-upload-stations.mjs` is a heavy process with deliberate delays.
- **Risk**: Becomes slow as the number of cities increases.

**Audio Stream Reliability:**
- Radio Browser URLs often expire or go offline.
- **Risk**: User experience degradation if stream validation isn't frequent.

## Scalability Concerns

**Database Growth:**
- Storing 1000+ stations in MongoDB with frequent updates.
- **Concern**: Cost and performance of MongoDB Atlas on a free/low tier.

---

*Concerns audit: 2026-04-28*
