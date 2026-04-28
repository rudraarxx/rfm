# Phase 2: Visualizer Engine - Validation Strategy

**Phase:** 02
**Slug:** visualizer-engine
**Date:** 2026-04-28

## Validation Architecture

### Automated Tests
- **Web**: Verify that `AudioSpectrum` canvas is drawing (pixel check in browser test if possible, or simple mount check).
- **Mobile**: Verify that `AudioVisualizer` widget receives a non-empty list of amplitudes when `isPlaying` is true.

### Manual Verification
- **Web**: Open the player, play a station, and verify bars move in sync with audio beats. Switch styles and verify visual change.
- **Android**: Verify real-time responsiveness. Check that permission dialog for "Microphone" (Recording) appears and that after approval, bars react to audio.
- **iOS**: Verify the "Smooth Pulse" simulation feels natural and reacts to volume/playback state.

## Success Criteria (Must-Haves)
- [ ] Real FFT data on Web.
- [ ] Real FFT data on Android (Visualizer class).
- [ ] Minimum 60fps rendering on both platforms.
- [ ] 3 different visual styles available in settings.

---
*Validation strategy defined: 2026-04-28*
