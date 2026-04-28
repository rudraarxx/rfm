# Research: Common Pitfalls

## Web Audio API Constraints
- **User Interaction Requirement**: Browsers block `AudioContext` until the user interacts with the page (e.g., clicks "Play").
- **CORS Issues**: Cross-Origin Resource Sharing (CORS) must be allowed by the radio stream server for the `AnalyserNode` to read raw frequency data. If not, the visualizer will show silence even if audio plays.

## Mobile Background Audio
- **OS Killing**: Android and iOS are aggressive about killing background processes. Without a properly configured `Foreground Service` (Android) or `Background Mode` (iOS), the stream will stop after 1-5 minutes of background play.
- **Battery Optimization**: Heavy visualizations can drain battery quickly. Consider "Low Power Mode" for visualizers when the screen is off or the battery is low.

## Data Consistency
- **Schema Drift**: If the scraper changes the JSON format but the mobile app isn't updated, the app may crash.
- **Recommendation**: Implement a `version` field in the JSON and use strict type-checking/validation (Zod on web, JSON serialization on mobile).

---
*Research synthesized: 2026-04-28*
