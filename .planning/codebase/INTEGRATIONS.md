# External Integrations

**Analysis Date:** 2026-04-28

## APIs & External Services

**Radio Browser API:**
- Source of truth for global radio station directory.
- Mirrors used: `de1.api.radio-browser.info`, `at1.api.radio-browser.info`, `nl1.api.radio-browser.info`.
- Method: REST API via `fetch`.
- Purpose: Discovering and refreshing station stream URLs.

**Onlineradiofm.in (Scraping):**
- Purpose: Aggregating Indian-specific station metadata (cities, states).
- Tool: `scripts/scrape-and-upload-stations.mjs`.

## Data Storage

**Databases:**
- MongoDB (Atlas) - Primary persistent store for indexed stations.
- Client: Mongoose ORM.
- Connection: `MONGODB_URI` environment variable.

**Cloud Storage:**
- Firebase Storage - Hosting the public `radio-browser-cache.json`.
- Bucket: `retro-radio-493505.firebasestorage.app`.
- Auth: Service account in `firebase-service-account.json`.
- Purpose: Fast, reliable delivery of the station list to mobile and web clients on startup.

## Monitoring & Observability

**Logs:**
- Console output for scraping and sync scripts.
- Terminal-based health checks via GSD skills.

## CI/CD & Deployment

**Hosting:**
- Vercel - Next.js application hosting.
- GitHub Actions - Planned for automation of station updates.

## Environment Configuration

**Required Env Vars:**
- `MONGODB_URI`: MongoDB connection string.
- `NEXT_PUBLIC_FIREBASE_*`: Firebase configuration for public access.
- `FIREBASE_SERVICE_ACCOUNT`: (Internal) path to service account JSON.

---

*Integration audit: 2026-04-28*
