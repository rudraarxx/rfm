# Phase 3: UI/UX & Background Refinement - Validation Strategy

**Phase:** 03
**Slug:** ui-ux-refinement
**Date:** 2026-04-28

## Validation Architecture

### Automated Tests
- **Performance**: Monitor frame drops on mobile using `flutter-test` or manual profiling.
- **Audio Service**: Verify `isPlaying` state remains true after 5 minutes of background play (mocking or manual).

### Manual Verification
- **Background Play**: Play a station, lock the phone, and wait for 10 minutes. Ensure audio doesn't stutter or stop.
- **Visual Audit**: Compare Web and Mobile "Circular" visualizers. Ensure they feel like part of the same design system.
- **Glassmorphism**: Verify that blur doesn't lag the scroll performance on mid-range devices.

## Success Criteria (Must-Haves)
- [ ] No audio drops in background (Android).
- [ ] Glassmorphism with noise texture (Mobile).
- [ ] Staggered animations on dashboard (Mobile).

---
*Validation strategy defined: 2026-04-28*
