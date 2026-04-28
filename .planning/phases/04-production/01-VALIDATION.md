# Phase 4: Production & Automation - Validation Strategy

**Phase:** 04
**Slug:** production
**Date:** 2026-04-28

## Validation Architecture

### Automated Tests
- **GitHub Action Dry-Run**: Manually trigger the workflow and verify it completes without errors.
- **Firebase Upload**: Verify the file timestamp in Firebase Storage updates after a run.

### Manual Verification
- **Live Site**: Visit the Vercel URL and ensure the player works.
- **Mobile Sync**: Delete local app cache, restart app, and verify it fetches the latest list from Firebase.

## Success Criteria (Must-Haves)
- [ ] GitHub Action scheduled successfully.
- [ ] Vercel deployment successful.
- [ ] Mobile ETag sync working in production environment.

---
*Validation strategy defined: 2026-04-28*
