# Phase 3 Research: UI/UX & Background Refinement

## Glassmorphism Polish (The "Ethereal" Layer)
- **Problem**: Current glass containers are consistent but "flat".
- **Refinement**: 
    - Add **Noise Textures** to the glass background to simulate mechanical frosted glass.
    - Implement **Dynamic Glows** that react to the visualizer's energy (ambient lighting).
    - Use `BrassGlassContainer` more strategically for "premium" interactive elements.

## Background Audio Stability (The "Grounded" Layer)
- **Problem**: Android may kill the audio service if not explicitly optimized for foreground state during long play sessions.
- **Refinement**:
    - Update `AudioServiceConfig` in `main.dart` to ensure `androidNotificationOngoing` is properly handled.
    - Research `wakelock_plus` to prevent CPU sleep during playback.
    - Implement a "Keep Alive" periodic ping in the `RadioHandler`.

## UI Micro-Animations
- **Staggered Entrance**: Use `framer-motion` (Web) and `flutter_staggered_animations` (Mobile) for list loading.
- **Analog Transitions**: Implement "fade-to-black" or "static noise" transition effects when switching stations.

---
*Research synthesized: 2026-04-28*
