# Requirements: Music OS (RFM)

**Defined:** 2026-04-28
**Core Value:** High-fidelity, zero-latency radio discovery and playback with a "Music OS" aesthetic.

## v1 Requirements

### Architecture (Local-First)
- [ ] **ARCH-01**: Remove MongoDB/Mongoose dependencies and code from web/maintenance layers.
- [ ] **ARCH-02**: Implement ETag-based conditional fetching for `stations.json` on both web and mobile.
- [ ] **ARCH-03**: Optimize scraper script to generate valid, versioned JSON artifacts for Firebase Storage.
- [ ] **ARCH-04**: Ensure offline fallback using local cached JSON when network is unavailable.

### Visualization
- [ ] **VIS-01**: Web: Implement real-time frequency bars/waveform using Web Audio API and Canvas.
- [ ] **VIS-02**: Web: Handle CORS constraints for cross-origin audio streams to enable `AnalyserNode`.
- [ ] **VIS-03**: Mobile: Implement real-time frequency visualization in Flutter using `audio_flux` or `audio_visualizer`.
- [ ] **VIS-04**: Visualizer must maintain 60fps performance without impacting audio playback stability.

### UI/UX Polish
- [ ] **UX-01**: Implement smooth glassmorphic transitions between station selection and playback states.
- [ ] **UX-02**: Synchronize visualizer theme colors with station metadata (if available) or dominant album art colors.
- [ ] **UX-03**: Mobile: Ensure persistent background playback with correct metadata on Lock Screen / Dynamic Island.

### Production Readiness
- [ ] **PROD-01**: Configure Vercel CI/CD for automatic web deployments on branch push.
- [ ] **PROD-02**: Secure all Firebase and scraper credentials using environment variables (no hardcoded secrets).
- [ ] **PROD-03**: Automate station list updates using GitHub Actions.

## v2 Requirements

### Features
- **USER-01**: User favorites/bookmarks (stored in local device storage).
- **USER-02**: Custom user-defined radio streams.
- **ALRT-01**: Push notifications for "Station Live" or "Special Event" alerts.

## Out of Scope
- **User Accounts** — No server-side profiles or authentication for v1.
- **Social Sharing** — Focus is on the solo listening experience.

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| ARCH-01 | Phase 1 | Pending |
| ARCH-02 | Phase 1 | Pending |
| ARCH-03 | Phase 1 | Pending |
| ARCH-04 | Phase 1 | Pending |
| VIS-01 | Phase 2 | Pending |
| VIS-02 | Phase 2 | Pending |
| VIS-03 | Phase 2 | Pending |
| VIS-04 | Phase 2 | Pending |
| UX-01 | Phase 3 | Pending |
| UX-02 | Phase 3 | Pending |
| UX-03 | Phase 3 | Pending |
| PROD-01 | Phase 4 | Pending |
| PROD-02 | Phase 4 | Pending |
| PROD-03 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 14 total
- Mapped to phases: 14
- Unmapped: 0 ✓

---
*Requirements defined: 2026-04-28*
*Last updated: 2026-04-28 after research*
