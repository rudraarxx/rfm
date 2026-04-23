# Task Backlog — RFM Mobile

**Last updated:** 2026-04-23  
**Branch:** dev  
**Ref docs:** PRD.md, APP_FLOW.md

---

## Priority Legend

| Tag | Meaning |
|-----|---------|
| 🔴 P0 | Broken / blocking core UX |
| 🟠 P1 | High value, low risk |
| 🟡 P2 | Medium value, moderate effort |
| 🟢 P3 | Nice to have |

---

## Sprint 1 — Foundation Fixes (do first, unblocks everything)

### T-01 🔴 Wire Settings Panel
**File:** `lib/presentation/screens/player_screen.dart:53`  
**What:** Settings icon `onPressed` is empty stub. `SettingsPanel` widget already built.  
**Do:** Connect icon tap → show `SettingsPanel` as bottom sheet or slide-in overlay.  
**Acceptance:** Tap settings icon → panel appears → visualizer toggle works.  
**Effort:** XS (< 1hr)

---

### T-02 🔴 Surface API Error States
**Files:** `dashboard_screen.dart`, `search_screen.dart`  
**What:** All `AsyncValue.error` cases silently return empty list. User sees blank screen.  
**Do:**  
- FORGE: show "SIGNAL LOST — TAP TO RETRY" with retry button on API error  
- SCAN: same error state in results area  
- Both: pass `ref.refresh(provider)` to retry  
**Acceptance:** Kill network → error state visible → tap retry → stations reload.  
**Effort:** S (2-3hr)

---

### T-03 🟠 Show Location Fallback Toast
**File:** `lib/logic/providers/location_provider.dart`  
**What:** GPS denied → silently falls back to Nagpur. User never knows.  
**Do:** On fallback, emit a one-time `SnackBar` — "Location unavailable. Showing Nagpur."  
**Acceptance:** Deny location permission → toast appears.  
**Effort:** XS (< 1hr)

---

## Sprint 2 — Player Completeness

### T-04 🟠 Implement Skip Next / Prev
**Files:** `radio_handler.dart`, `radio_controller.dart`, `player_screen.dart`  
**What:** `skipToNext()` is a stub. No skip buttons in UI.  
**Do:**  
1. Add `currentQueue` (List<Station>) and `currentIndex` to `RadioState`  
2. `RadioController.setQueue(stations, index)` — called when user plays from a list  
3. `skipToNext()` / `skipToPrev()` increment/decrement index, call `playStation()`  
4. Add Prev / Next buttons to player screen flanking play button  
5. Wire into `AudioHandler` `MediaItem` for lock screen prev/next  
**Queue context rules:**  
- Play from city carousel → queue = city stations  
- Play from national list → queue = all stations  
- Play from search results → queue = filtered results  
**Acceptance:** Play from list → prev/next buttons cycle stations → lock screen controls work.  
**Effort:** M (4-6hr)  
**Depends on:** None

---

### T-05 🟠 Favorites System
**Files:** `persistence_service.dart`, new `favorites_provider.dart`, UI (cards + tiles)  
**What:** No bookmarking. High-value gap.  
**Do:**  
1. Extend `PersistenceService`: `saveFavorite(uuid)`, `removeFavorite(uuid)`, `getFavorites()` → `List<String>` (changeuuids)  
2. `favoritesProvider` — `StateNotifierProvider<List<String>>`  
3. Heart icon on `StationListTile`, `CityStationCard`, `HeroStationCard`  
   - Filled = saved, outline = not saved  
   - Tap → toggle + persist  
4. "SAVED FREQUENCIES" section on FORGE tab (above national list)  
   - Empty state: "NO SAVED FREQUENCIES YET"  
   - Load: fetch full Station objects for saved uuids from `stationsProvider`  
**Acceptance:** Heart tap → persists across app restarts. Section shows saved stations.  
**Effort:** M (5-7hr)  
**Depends on:** None

---

### T-06 🟡 Station Detail Bottom Sheet
**Files:** New `station_detail_sheet.dart`, `station_list_tile.dart`, `city_station_card.dart`  
**What:** `frequency`, `bitrate`, `language`, `tags`, `homepage`, `established` all in model, never shown.  
**Do:**  
1. Long-press any station card → `showModalBottomSheet` → `StationDetailSheet`  
2. Sheet shows: name, favicon, frequency (e.g. "104.2 FM"), bitrate, language, tags chips, city/state, established, homepage (`url_launcher`), contact  
3. Play button inside sheet  
**Acceptance:** Long press → sheet shows station metadata. Homepage link opens browser.  
**Effort:** M (4-5hr)  
**Depends on:** None  
**Package needed:** `url_launcher` (add to pubspec)

---

## Sprint 3 — Discovery Enhancements

### T-07 🟡 Recently Played Section
**Files:** `persistence_service.dart`, new `history_provider.dart`, `dashboard_screen.dart`  
**What:** No playback history.  
**Do:**  
1. Extend `PersistenceService`: maintain ordered list of last 20 played stations (JSON array)  
2. `historyProvider` — `StateNotifierProvider<List<Station>>`  
3. On `RadioController.playStation()` → append to history  
4. FORGE tab: "RECENT TRANSMISSIONS" horizontal carousel (same card as city carousel)  
   - Hidden if history empty  
**Acceptance:** Play 3 stations → section appears → survives app restart.  
**Effort:** S (3-4hr)  
**Depends on:** None

---

### T-08 🟡 Language + Tags Filter in Search
**Files:** `search_screen.dart`, `station_repository.dart`, `station_api.dart`  
**What:** `language` and `tags` on Station model, unused in search.  
**Do:**  
1. Add language dropdown to SCAN (alongside state/city dropdowns)  
2. Add tag chips row (derive unique tags from loaded stations)  
3. Pass language/tag params to `getStations()` API call  
   - If backend doesn't support → filter client-side in `filteredStationsProvider`  
**Acceptance:** Filter by language "Hindi" → only Hindi stations shown.  
**Effort:** M (4-5hr)  
**Depends on:** T-02 (stable stations data)

---

## Sprint 4 — Player Extras

### T-09 🟡 Sleep Timer
**Files:** New `sleep_timer_provider.dart`, `settings_panel.dart`, `mini_player.dart`  
**What:** Common radio feature. Not implemented.  
**Do:**  
1. `SleepTimerNotifier` — `StateNotifierProvider<Duration?>` with countdown  
2. Options in `SettingsPanel`: 15m / 30m / 60m / Off  
3. On countdown = 0 → `RadioController.pause()`  
4. `MiniPlayer`: show timer icon + remaining time when active  
**Acceptance:** Set 15m → station pauses at 15m → mini-player shows countdown.  
**Effort:** S (3-4hr)  
**Depends on:** T-01 (settings panel wired)

---

### T-10 🟢 Surface Station Frequency on Cards
**Files:** `station_list_tile.dart`, `city_station_card.dart`  
**What:** `frequency` field (e.g., "104.2") exists on model, not shown on any card.  
**Do:** Show `"${station.frequency} FM"` as subtitle/badge if `frequency != null`.  
**Acceptance:** Station with frequency field shows "104.2 FM" on card.  
**Effort:** XS (< 1hr)  
**Depends on:** None

---

### T-11 🟢 Remove Debug Print Statements
**File:** `lib/logic/audio/radio_handler.dart:54`  
**What:** `print("Error loading audio source: $e")` — raw debug output in prod.  
**Do:** Replace with `debugPrint()` or structured logger (`package:logging`).  
**Effort:** XS (15min)

---

## Task Summary

| ID | Title | Priority | Effort | Depends |
|----|-------|----------|--------|---------|
| T-01 | Wire Settings Panel | 🔴 P0 | XS | — |
| T-02 | Surface API Error States | 🔴 P0 | S | — |
| T-03 | Location Fallback Toast | 🟠 P1 | XS | — |
| T-04 | Skip Next / Prev | 🟠 P1 | M | — |
| T-05 | Favorites System | 🟠 P1 | M | — |
| T-06 | Station Detail Sheet | 🟡 P2 | M | — |
| T-07 | Recently Played | 🟡 P2 | S | — |
| T-08 | Language + Tags Filter | 🟡 P2 | M | T-02 |
| T-09 | Sleep Timer | 🟡 P2 | S | T-01 |
| T-10 | Show Frequency on Cards | 🟢 P3 | XS | — |
| T-11 | Remove Debug Prints | 🟢 P3 | XS | — |

---

## Recommended Build Order

```
T-11 → T-01 → T-03 → T-02
                         ↓
              T-10 → T-04 → T-05 → T-07
                               ↓
                            T-06 → T-08 → T-09
```

Start with T-11, T-01, T-03 (all < 1hr, zero risk).  
Then T-02 (error states — unlocks confident data loading).  
Then T-04 + T-05 in parallel (independent, highest user value).
