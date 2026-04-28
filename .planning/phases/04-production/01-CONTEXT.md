# Phase 4 Context: Production & Automation

**Phase:** 04
**Slug:** production
**Date:** 2026-04-28

## Core Decisions
- **Source of Truth**: Firebase Storage (`radio-browser-cache.json`) for Mobile. Local bundle for Web (updated via CI).
- **Automation**: GitHub Actions is the preferred runner for the daily scraper.
- **Vercel**: Next.js app is the primary frontend and API gateway.

## Dependencies
- CI: `actions/checkout`, `actions/setup-node`.
- Server: `firebase-admin`.

---
*Context locked: 2026-04-28*
