# Roadmap: Music OS (RFM)

## Overview
This roadmap transforms the RFM project from a DB-heavy prototype into a high-performance, local-first hybrid application. We will decommission the MongoDB layer, implement a sophisticated real-time audio visualizer across web and mobile, and automate the station maintenance pipeline for production.

## Phases

- [ ] **Phase 1: Architecture Purge & JSON Sync** - Transition to 100% local-first JSON architecture.
- [ ] **Phase 2: Visualizer Engine** - Implement high-fidelity frequency visualization on Web and Flutter.
- [ ] **Phase 3: UI/UX & Background Refinement** - Polish animations and harden background audio stability.
- [ ] **Phase 4: Production & Automation** - Configure CI/CD and automated station maintenance.

## Phase Details

### Phase 1: Architecture Purge & JSON Sync
**Goal**: Remove DB overhead and establish high-speed JSON synchronization.
**Depends on**: Nothing
**Requirements**: [ARCH-01, ARCH-02, ARCH-03, ARCH-04]
**Success Criteria**:
  1. No MongoDB or Mongoose code remains in the project.
  2. Both Web and Mobile apps fetch and cache `stations.json` using ETag validation.
  3. Scraper script successfully uploads valid JSON to Firebase Storage.
**Plans**: 2 plans

Plans:
- [ ] 01-01: Decommission MongoDB and remove Mongoose from all layers.
- [ ] 01-02: Implement ETag sync logic in Web and Flutter clients.

### Phase 2: Visualizer Engine
**Goal**: Add real-time audio visualization to both platforms.
**Depends on**: Phase 1
**Requirements**: [VIS-01, VIS-02, VIS-03, VIS-04]
**Success Criteria**:
  1. Real-time frequency bars/waveform render on Web using Web Audio API.
  2. Smooth (60fps) visualization renders on Mobile using Flutter.
  3. CORS issues resolved for external radio streams on Web.
**Plans**: 2 plans

Plans:
- [ ] 02-01: Build Web Audio API visualizer for Next.js.
- [ ] 02-02: Build high-performance Flutter visualizer engine.

### Phase 3: UI/UX & Background Refinement
**Goal**: Polish the "Music OS" feel and ensure mobile stability.
**Depends on**: Phase 2
**Requirements**: [UX-01, UX-02, UX-03]
**Success Criteria**:
  1. Glassmorphic transitions implemented between UI states.
  2. Mobile audio continues playback indefinitely in the background with correct metadata.
  3. Visualizer theme adapts to station metadata.
**Plans**: 2 plans

Plans:
- [ ] 03-01: Implement glassmorphic animations and theme synchronization.
- [ ] 03-02: Harden Flutter background audio services (Foreground/WakeLocks).

### Phase 4: Production & Automation
**Goal**: Prepare the project for public deployment and automated maintenance.
**Depends on**: Phase 3
**Requirements**: [PROD-01, PROD-02, PROD-03]
**Success Criteria**:
  1. Vercel deployment succeeds with all environment variables configured.
  2. GitHub Actions automatically updates the station list on a schedule.
  3. No hardcoded secrets remain in the repository.
**Plans**: 1 plan

Plans:
- [ ] 04-01: Configure CI/CD and GitHub Actions maintenance workflow.

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Architecture Purge | 2/2 | Completed | 2026-04-28 |
| 2. Visualizer Engine | 2/2 | Completed | 2026-04-28 |
| 3. UI/UX Refinement | 0/2 | In progress | - |
| 4. Production | 0/1 | Not started | - |

---
*Roadmap defined: 2026-04-28*
