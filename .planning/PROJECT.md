# Music OS (RFM)

Hybrid Web-Mobile Radio Application providing a premium, glassmorphic listening experience with local-first reliability.

## Context
The project consists of a Next.js web application and a Flutter mobile application. It aggregates Indian radio stations using a custom scraper and the Radio Browser API. The current architecture is transitioning from a MongoDB-dependent backend to a pure local-first/JSON-driven synchronization model using Firebase Storage for fast delivery.

## Core Value
High-fidelity, zero-latency radio discovery and playback with a "Music OS" aesthetic that feels native across web and mobile.

## Requirements

### Validated
- ✓ **Cross-Platform Foundation** — Next.js web and Flutter mobile cores established.
- ✓ **Station Aggregation** — Functional scraper and enrichment via Radio Browser API.
- ✓ **Local-First Discovery** — Apps load from cached station indices for instant startup.
- ✓ **Background Playback** — Flutter app supports native audio sessions.
- ✓ **Glassmorphic UI** — Core visual language implemented.

### Active
- [ ] **Real-Time Visualizer** — Implement high-fidelity frequency/waveform visualization on both platforms.
- [ ] **DB Removal & Optimization** — Decommission MongoDB/Mongoose and optimize the JSON-based sync workflow.
- [ ] **UI/UX Polish** — Enhance animations, transitions, and layout consistency.
- [ ] **Production Readiness** — Configure CI/CD, secure environment variables, and prepare for store deployment.

### Out of Scope
- **User Accounts/Profiles** — Staying focused on pure listening experience for now.
- **Global Stations** — Focus remains on high-quality Indian radio stations.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Local-First JSON | Ensures 100% reliability and instant loading without DB latency. | Active |
| Remove MongoDB | Reduces deployment complexity and hosting costs for a metadata-only app. | Pending |
| Hybrid Web-Mobile | Leverages Next.js for web reach and Flutter for native mobile performance. | Validated |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-28 after initialization*
