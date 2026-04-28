# Phase 2 Context: Visualizer Engine

**Phase:** 02
**Slug:** visualizer-engine
**Date:** 2026-04-28

## Core Decisions
- **Source of Truth**: The `analyser` state in the Web store and the `VisualizerService` in Flutter.
- **Rendering**: Always use `Canvas` (Web) or `CustomPainter` (Flutter) for 60fps performance. Avoid SVG or DOM-based animations for the spectrum.
- **Style Persistence**: Store the `visualizerStyle` in `localStorage` (Web) and `SharedPreferences` (Mobile).

## Dependencies
- Web: `AudioContext` (Standard).
- Mobile: `just_audio` (audioSessionId), `flutter_riverpod` (state management).

---
*Context locked: 2026-04-28*
