# Phase 3 Context: UI/UX & Background Refinement

**Phase:** 03
**Slug:** ui-ux-refinement
**Date:** 2026-04-28

## Core Decisions
- **Aesthetic**: "The Machinist" — High contrast, technical fonts (Space Grotesk), and glassmorphic depth.
- **Stability**: Background audio is the #1 functional priority. UI polish must not compromise battery life or CPU usage.
- **Library**: Add `wakelock_plus` to Flutter for playback stability.

## Dependencies
- Mobile: `wakelock_plus`, `audio_service`, `google_fonts`.
- Web: `framer-motion`, `lucide-react`.

---
*Context locked: 2026-04-28*
