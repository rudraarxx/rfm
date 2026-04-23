# Product Requirements Document — RFM Mobile

**Version:** 1.0 Draft | **Date:** 2026-04-23 | **App:** RFM — Radio Streaming (Flutter)

---

## 1. Overview

RFM Mobile is an analog-aesthetic radio streaming app for India. Users discover, search, and stream FM/internet radio stations. Design language: "The Analog Machinist" — dark, industrial, glassmorphic.

**Target platform:** iOS + Android (web/desktop present but likely secondary)  
**Backend:** Next.js API → MongoDB (prod: rfm-five.vercel.app)

---

## 2. User Personas

| Persona | Need |
|---------|------|
| Casual listener | Quick access to local city stations |
| Radio enthusiast | Browse by state/city, discover new stations |
| Commuter | Background playback, lock screen controls |

---

## 3. Core Features (Currently Implemented)

### 3.1 Discovery (FORGE tab)
- Hero card with featured/current station
- City carousel — stations for detected/selected city
- Full national station list
- Manual city override + GPS auto-detect
- Fallback default: Nagpur

### 3.2 Search (SCAN tab)
- Text search by station name
- Hierarchical state → city filter dropdowns
- Empty state: "NO SIGNAL FOUND"

### 3.3 Playback (WAVES tab)
- Stream audio via `just_audio`
- Play / pause / volume slider
- Audio visualizer (classic & colorful modes)
- Background playback via `audio_service`
- Lock screen / notification controls
- Mini-player overlay (all non-player tabs)
- Hero animation mini-player ↔ full player

### 3.4 Persistence
- Resume last station on app launch
- Remember volume level
- Remember visualizer style
- Remember selected city

---

## 4. Features Partially Implemented

| Feature | Status | What's Missing |
|---------|--------|----------------|
| Settings Panel | UI exists (`settings_panel.dart`), not wired | Connect to player screen settings icon tap |
| Skip Next/Prev | `skipToNext()` stub in `radio_handler.dart` | Station list context, UI buttons |
| Progress Bar | Package installed (`audio_video_progress_bar`), unused | Integration in player UI |
| Lock Screen Skip Controls | Background service active, skip unimplemented | Tie into MediaItem prev/next |

---

## 5. Features Not Implemented (Backlog)

| Feature | Priority | Notes |
|---------|----------|-------|
| Favorites / Bookmarks | High | No persistence, no UI |
| Playback History | Medium | "Recently played" |
| Sleep Timer | Medium | Common radio app feature |
| Station Detail Sheet | Medium | Homepage, language, contact, tags |
| Language Filter | Medium | `language` field on Station model exists, unused in search |
| Tags / Genre Filter | Medium | `tags` field on Station exists, unused in search |
| Equalizer | Low | UI hint exists, no audio implementation |
| Offline Cache | Low | Streaming-only today |
| User Accounts / Auth | Low | No auth system |
| Playlist / Queue | Low | Single-station model today |
| Social Share | Low | Share station link |
| Station Vote / Rating | Low | `votes` field exists, no UI |

---

## 6. Data Model — Station

| Field | Type | Surfaced in UI? |
|-------|------|-----------------|
| changeuuid | String | No (internal ID) |
| name | String | Yes |
| url | String | No (fallback) |
| urlResolved | String | No (internal) |
| homepage | String? | No |
| favicon | String? | Yes (artwork) |
| tags | String? | No |
| country | String? | No |
| state | String? | Yes (search filter) |
| city | String? | Yes (discovery) |
| language | String? | No |
| votes | int? | No |
| frequency | String? | No |
| bitrate | int? | No |
| established | String? | No |
| contactNumber | String? | No |

---

## 7. Non-Functional Requirements

| Area | Current State | Gap |
|------|---------------|-----|
| Theme | Dark-only | No light mode |
| Accessibility | Not implemented | No semantic labels |
| Error Handling | API failure → empty list | No user-visible error/retry UI |
| Logging | `print()` statements | No structured logging |
| Analytics | None | — |
| Crash Reporting | None | — |
| CI/CD | Not in repo | — |

---

## 8. Architecture

| Layer | Pattern |
|-------|---------|
| Presentation | Flutter Widgets + Riverpod consumers |
| Logic | StateNotifier controllers + FutureProviders |
| Data | Repository pattern + HTTP client |
| Core | Theme, config, constants |

**State:** Riverpod (StateNotifier + FutureProvider + Provider)  
**Storage:** SharedPreferences (local), HTTP (remote API)  
**Audio:** just_audio + audio_service  
**Navigation:** IndexedStack (tab state preserved), single modal route (mini-player → full player)

---

## 9. Open Questions

1. **Favorites** — high-value gap. Build this next, or other priority?
2. **Station fields** — `frequency`, `bitrate`, `language`, `tags` all in model but hidden. Surface any in UI (e.g., "104.2 FM" on cards)?
3. **Error states** — API fails silently today. Want visible error UI ("Signal lost — retry")?
4. **Skip next/prev** — should skip navigate within current context (city list? search results? all stations)?
5. **Settings panel** — what settings beyond visualizer style? (EQ, sleep timer, theme?)
6. **User accounts** — auth planned, or stays anonymous + local-only?
7. **Platform priority** — iOS + Android only, or ship web too?
8. **Station data source** — stays self-hosted MongoDB/Next.js, or direct radio-browser.info integration planned?
