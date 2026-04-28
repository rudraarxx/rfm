# Phase 2 Research: Visualizer Engine

## Web Visualizer (Canvas + Web Audio API)
- **Current State**: `AudioEngine.tsx` correctly initializes the `AnalyserNode` and passes it to the store. `AudioSpectrum.tsx` renders frequency bars on a canvas.
- **Optimization**: Use `path2D` for drawing multiple bars to reduce draw calls. Implement "Peak Meter" (falling white lines above bars).
- **Latency**: Ensure `fftSize` is tuned (256-512) for a balance between detail and performance.

## Flutter Visualizer (Real-time Spectrum)
- **Problem**: `just_audio` does not expose the raw PCM stream for cross-platform FFT analysis.
- **Android Solution**:
    - Use the `Visualizer` class from Android SDK.
    - Requires `audioSessionId` from `just_audio`.
    - Requires `RECORD_AUDIO` permission (to capture the output session).
- **iOS Solution**:
    - High complexity for session-level capture.
    - Strategy: Implement a "React-Sim" visualizer for iOS that uses a pseudo-random algorithm driven by a high-frequency ticker, similar to the current implementation but more sophisticated (per-band simulated logic).
- **Cross-Platform Bridge**:
    - Create a `VisualizerService` in Flutter that provides a `Stream<List<double>>` (frequency magnitudes).
    - On Android: Piped from native Visualizer.
    - On iOS/Web-fallback: Piped from a simulated generator.

## UI Styles
- **Style A (Classic)**: Vertical bars centered on a horizontal axis (current).
- **Style B (Colorful)**: Gradient bars with glow effects (glassmorphic).
- **Style C (Retro Circular)**: Radial bars emanating from the center of the artwork.

---
*Research synthesized: 2026-04-28*
