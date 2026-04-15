# RFM Nagpur Pulse — Android Development Log

## Overview

Native Android radio streaming app in Kotlin that mirrors the existing Next.js web app.  
Streams live Indian FM/internet radio stations with a full-featured player UI, background playback, state/city filters, and Android Auto support.

---

## Tech Stack

| Layer | Choice |
|---|---|
| Language | Kotlin |
| UI | XML / Views (no Compose) |
| Architecture | MVVM + Clean Architecture |
| DI | None (manual wiring) |
| Audio | Media3 / ExoPlayer |
| Background playback | `MediaLibraryService` + `MediaSession` |
| Persistence | DataStore Preferences |
| Networking | Retrofit 2 + Gson |
| Image loading | Glide |
| Navigation | Navigation Component |
| Android Auto | `CarAppService` + `GridTemplate` |
| Min SDK | API 26 (Android 8.0) |
| Target SDK | API 35 |
| Package | `com.rfm.nagpurpulse` |

---

## Package Structure

```
android/app/src/main/java/com/rfm/nagpurpulse/
├── data/
│   ├── local/
│   │   ├── HardcodedIndianStations.kt   # Curated station DB with verified stream URLs
│   │   └── UserPreferencesDataStore.kt  # DataStore: last station, volume, favorites
│   ├── remote/
│   │   ├── RadioBrowserApi.kt           # Retrofit interface for radio-browser.info
│   │   ├── RadioBrowserService.kt       # 3-mirror failover, dedup, city search
│   │   └── dto/StationDto.kt            # API DTO → domain mapper
│   ├── repository/
│   │   └── StationRepositoryImpl.kt     # Merges API + hardcoded stations; FALLBACK_STATIONS
│   └── service/
│       └── RadioPlaybackService.kt      # ExoPlayer + MediaSession + audio focus + BECOMING_NOISY
│
├── domain/
│   ├── model/
│   │   ├── Station.kt                   # Pure data class (id, name, streamUrl, localImageName, …)
│   │   ├── IndianStates.kt              # StateFilter list (25 states + ALL)
│   │   ├── IndianCities.kt              # CityFilter per state with search term aliases
│   │   └── UserPreferences.kt           # lastStationId, volume, favoriteIds
│   ├── repository/
│   │   ├── StationRepository.kt         # Interface
│   │   └── PreferencesRepository.kt     # Interface
│   └── usecase/
│       ├── GetStationsUseCase.kt
│       ├── SearchByCityUseCase.kt
│       ├── GetSavedPreferencesUseCase.kt
│       └── SavePreferencesUseCase.kt
│
├── presentation/
│   ├── main/
│   │   ├── MainActivity.kt             # Single activity, mini player, MediaController lifecycle
│   │   └── MainViewModel.kt            # All state: stations, filters, playback, favorites
│   ├── home/
│   │   ├── HomeFragment.kt             # State/city chip filters + station RecyclerView
│   │   └── adapter/StationAdapter.kt   # ListAdapter with active/playing/favorite state
│   ├── player/
│   │   └── PlayerBottomSheet.kt        # Expanded player sheet
│   └── util/
│       ├── ViewExtensions.kt           # Station.imageSource() for Glide
│       └── VisualizerAnimator.kt       # ValueAnimator for 4-bar EQ visualizer
│
└── auto/
    ├── RadioCarAppService.kt           # Android Auto entry point
    └── RadioCarScreen.kt               # GridTemplate with live MediaController playback
```

---

## Features Implemented

### 1. Core Playback
- **Background streaming** via `MediaLibraryService` — continues playing when app is backgrounded
- **Lock screen / notification controls** — Media3 handles notification automatically
- **Audio focus** — pauses on incoming calls, ducks on transient focus loss, resumes on gain
- **Headphone disconnect** — auto-pauses on `ACTION_AUDIO_BECOMING_NOISY` (BroadcastReceiver)
- **HLS + MP3** — Media3 handles both `.m3u8` and direct HTTP streams
- **Buffering indicator** — spinner shown during `STATE_BUFFERING`; hides play button until ready
- **Volume control** — SeekBar in expanded player, persisted to DataStore

### 2. Station Sources (three-tier)
1. **Radio Browser API** (`api.radio-browser.info`) — live Indian stations ordered by vote count, 3-mirror failover (`de1`, `at1`, `nl1`), state filter support
2. **HardcodedIndianStations** — curated DB of verified stream URLs sourced from `onlineradiofm.in`; supplements sparse Radio Browser city data; covers 11 cities across 9 states
3. **FALLBACK_STATIONS** — 5 hardcoded Nagpur stations shown if all else fails

**Verified stream sources:**
- Radio Mirchi 98.3: FastCast4u Icecast (`eu8.fastcast4u.com`)
- BIG FM 92.7: Zeno.fm (`stream.zeno.fm/dbstwo3dvhhtv`)
- Red FM 93.5: Zeno.fm (`stream.zeno.fm/9phrkb1e3v8uv`)
- Radio City 91.1: Zeno.fm (`stream.zeno.fm/pxc55r5uyc9uv`)
- Vividh Bharati / AIR stations: Bitgravity HLS (`air.pc.cdn.bitgravity.com`)

**Zeno.fm fix:** ExoPlayer configured with `DefaultHttpDataSource.Factory` sending  
`User-Agent: Chrome/120` + `Referer: onlineradiofm.in` so Zeno's 401 → 302 → signed CDN URL flow works correctly.

### 3. State → City Filter
- `ChipGroup` for state selection (25 states + All India)
- City chips appear only after a state is selected
- City selection merges hardcoded stations (first) with Radio Browser city search results (deduplicated by ID)
- Section title updates: "All India" → "Maharashtra" → "Nagpur, Maharashtra"

### 4. Player UI
- **Mini player bar** — always visible at bottom when a station is selected; station icon, name, animated visualizer, prev/play/next buttons
- **Expanded player (BottomSheetDialogFragment)** — station artwork (from local drawable or Glide URL), name, tags, visualizer, favorite button, prev/play/next controls, volume SeekBar

### 5. EQ Visualizer Animation
- 4 bar `View`s animated independently with `ValueAnimator`
- Each bar has a different duration (380–520ms), staggered start delay, `AccelerateDecelerate` interpolation — never moves in unison
- `VisualizerAnimator` singleton keyed by root view; properly cancels on RecyclerView recycle

### 6. Prev / Next Navigation
- `playNext()` / `playPrevious()` in `MainViewModel`
- Both are circular: last station wraps to first, first wraps to last
- Operate on the sorted `displayedStations` list (so favorites-first order is respected)
- Buttons present in both mini player and expanded player

### 7. Favorites
- Tap the ❤ on a station card or the heart button in the expanded player header
- Favorite station IDs persisted to DataStore as `StringSet`
- `_favoriteIds` is a `MutableStateFlow<Set<String>>`; combined with `_displayedStationsRaw` via `combine { }.stateIn()` so favorites always float to top reactively
- Heart icon on station card (filled red = favorited)
- Favorite button in player header changes tint: accent red (favorited) / grey (not)

### 8. Station Images
- `Station.localImageName` field stores drawable resource name (e.g. `radio_mirchi`)
- `Station.imageSource(context)` resolves local drawable by name via `Resources.getIdentifier()`; falls back to `faviconUrl` for Glide
- Local PNGs copied from web app `public/stations/`: `radio_mirchi.png`, `big_fm.png`, `red_fm.png`, `radio_city.png`, `vividh_bharti.png`

### 9. Persistence (DataStore)
| Key | Type | Description |
|---|---|---|
| `last_station_id` | String | Restored on startup, pre-selects last station |
| `volume` | Int | Restored and applied to MediaController |
| `favorite_ids` | StringSet | Restored and applied to `_favoriteIds` flow |

### 10. Android Auto
- `RadioCarAppService` + `RadioCarSession` + `RadioCarScreen`
- `GridTemplate` showing `FALLBACK_STATIONS` with station name, genre tag, and radio icon
- Tapping a station builds a `MediaItem` and calls `play()` via a `MediaController` connected to `RadioPlaybackService`
- Controller released on screen lifecycle destroy

---

## Key Design Decisions

### Why Radio Browser + Hardcoded?
Radio Browser is the only free public API for Indian radio but has sparse city-level data — searching `name=nagpur` returns only 1 station. Major private FM chains (Mirchi, BIG, Red, Radio City) are not in Radio Browser with city metadata. Solution: `HardcodedIndianStations.kt` with stream URLs sourced directly from `onlineradiofm.in`.

### How onlineradiofm.in streams work
Each station page server-renders `var FILE = "..."` with a direct stream URL. No API — pure HTML scrape. All major national chains use a single national stream across every city. Zeno.fm streams (`stream.zeno.fm`) require browser headers to get the 302 redirect to the short-lived signed CDN URL.

### Why no Zeno.fm API / Streema?
- **Streema**: no public API; unofficial npm scraper only, fragile
- **Zeno.fm API**: gated — requires API key via email to `subscription@zenomedia.com`; can be added once a key is obtained

### Architecture choices
- No DI framework — app is simple enough; manual wiring in ViewModel init
- `MediaController` owned by `MainViewModel`, not the Activity — survives configuration changes
- `combine().stateIn()` for sorted favorites list — fully reactive, zero imperative sorting calls

---

## Hardcoded Station Coverage

| City | Stations |
|---|---|
| Nagpur | Mirchi, BIG FM, Radio City, Red FM, Vividh Bharati 100.6, AIR Nagpur |
| Mumbai | Mirchi, BIG FM, Radio City, Red FM, Ishq 104.8 |
| Pune | Mirchi, BIG 95, Radio City, Red FM |
| New Delhi | Mirchi, BIG FM, Radio City, Red FM, Ishq 104.8, AIR FM Gold |
| Bengaluru | Mirchi, BIG FM, Radio City, Red FM, Radio Indigo 91.9 |
| Chennai | Mirchi, BIG FM, Radio City, Suryan 93.5 |
| Hyderabad | Mirchi, BIG FM, Radio City, Red FM |
| Ahmedabad | Mirchi, Radio City, Red FM |
| Kolkata | Mirchi, BIG FM, Red FM |
| Jaipur | Mirchi, BIG FM, Radio City, Red FM |
| Lucknow | Mirchi, BIG 94.3, Radio City, Red FM |
| Amritsar | Mirchi, Red FM |

---

## Build & Run

```bash
# Build debug APK
cd android
./gradlew :app:assembleDebug

# Install on connected device
adb install -r app/build/outputs/apk/debug/app-debug.apk

# Or via Gradle (requires device connected via ADB daemon)
./gradlew :app:installDebug
```

**Note:** If `installDebug` fails with "No connected devices", restart the ADB daemon:
```bash
adb kill-server && adb start-server
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

---

## Known Limitations / Future Work

- Zeno.fm streams generate a new signed CDN URL on each connection (60s JWT) — this is handled automatically by ExoPlayer following the redirect, but cached URLs will expire
- Radio Browser city data for India is sparse; hardcoded DB covers major cities only
- Android Auto uses `FALLBACK_STATIONS` (5 Nagpur stations); could be expanded to use the full station list once a coroutine-safe loading mechanism is added to `RadioCarScreen`
- No search feature (by design per initial spec)
- No categories (by design)
- Zeno.fm API integration pending API key from `subscription@zenomedia.com`
