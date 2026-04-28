# Phase 4 Research: Production & Automation

## Automation Strategy
- **Mechanism**: GitHub Actions (Cron schedule).
- **Triggers**: 
    - Daily at 00:00 UTC.
    - Manual dispatch for emergency updates.
- **Secrets Required**: 
    - `FIREBASE_SERVICE_ACCOUNT`: Content of the service account JSON.
- **Workflow**: 
    1. Checkout code.
    2. Setup Node.js.
    3. Install dependencies (`firebase-admin`).
    4. Run `npm run update-stations-enriched`.
    5. No commit back needed (it uploads to Firebase Storage, which is the live source for the mobile app).

## Web Deployment (Vercel)
- **Frontend**: Next.js 16.
- **Data Source**: Uses `src/data/radio-browser-cache.json` which is included in the bundle.
- **Optimization**: The API uses `If-None-Match` (ETag) to save bandwidth on mobile.

## Mobile Distribution
- **Flutter**: Ready for APK/IPA generation.
- **Update Logic**: Mobile app checks Firebase Storage on every cold start (with ETag caching).

---
*Research synthesized: 2026-04-28*
