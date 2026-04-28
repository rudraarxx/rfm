# Research: Technology Stack (2025)

**Domain**: Real-Time Audio Visualization & Hybrid Radio

## Web Visualization (Next.js)

### Recommended Approach: Web Audio API + HTML5 Canvas
- **Why**: Native browser support, zero overhead, and maximum flexibility.
- **Tools**:
  - `AnalyserNode`: For FFT (Fast Fourier Transform) frequency data.
  - `Canvas API`: For high-performance 60fps rendering in a `requestAnimationFrame` loop.
- **Alternatives**:
  - `Butterchurn`: Shader-based psychedelic visuals (Winamp style).
  - `Three.js`: If 3D visualization is desired.

## Mobile Visualization (Flutter)

### Recommended Package: `audio_flux` / `flutter_soloud`
- **Why**: High-performance audio engine with built-in FFT support and shader compatibility.
- **Tools**:
  - `audio_visualizer`: Best for quick integration of standard bars/circles.
  - `CustomPainter`: For unique architectural designs mapped to frequency streams.

## Data Synchronization

### Recommended Approach: ETag-based JSON Sync
- **Why**: Avoids constant redownloading of the 1MB+ station list.
- **Tools**:
  - **Firebase Storage**: For hosting the public `radio-browser-cache.json`.
  - **Client-Side Cache**: `shared_preferences` (Flutter) and `localStorage` (Web).

---
*Research synthesized: 2026-04-28*
