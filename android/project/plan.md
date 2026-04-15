# RFM Nagpur Pulse — Android App Plan

## Overview

A native Android radio streaming app in Kotlin that mirrors the web app's core experience:
live radio streaming for 5 Nagpur/Maharashtra stations, with a mini player bar and
full-screen expanded player.

---

## Decisions

| Decision | Choice |
|---|---|
| UI | XML / Views |
| Architecture | MVVM + Clean Architecture |
| DI | None (manual wiring) |
| Audio | Media3 (ExoPlayer) |
| Background playback | Yes — ForegroundService + MediaSession |
| Audio focus | Yes — auto-pause on call, resume after |
| Headphone disconnect | Yes — auto-pause on BECOMING_NOISY |
| Android Auto | Yes — CarAppService + RadioCarScreen |
| Stations | 5 hardcoded fallback stations |
| Categories | Not included |
| Search | Not included |
| Sharing | Not included |
| Min SDK | API 26 (Android 8.0) |
| Target SDK | API 35 |
| Distribution | Internal APK |
| Package | com.rfm.nagpurpulse |
| Persistence | DataStore Preferences |

---

## Architecture

### Clean Architecture Layers

```
Presentation  →  Domain  →  Data
(UI + VM)        (Models,    (DataStore, Service,
                  UseCases,   Repository Impl)
                  Repo iface)
```

### Package Structure

```
com.rfm.nagpurpulse/
├── data/
│   ├── local/
│   │   └── UserPreferencesDataStore.kt     # DataStore read/write
│   ├── repository/
│   │   └── StationRepositoryImpl.kt        # Returns hardcoded stations
│   └── service/
│       └── RadioPlaybackService.kt         # MediaSessionService (Media3)
│
├── domain/
│   ├── model/
│   │   └── Station.kt                      # Pure data class
│   ├── repository/
│   │   └── StationRepository.kt            # Interface
│   └── usecase/
│       ├── GetStationsUseCase.kt
│       ├── GetSavedPreferencesUseCase.kt
│       └── SavePreferencesUseCase.kt
│
└── presentation/
    ├── main/
    │   ├── MainActivity.kt                 # Single activity host
    │   └── MainViewModel.kt               # MediaController + preferences
    ├── home/
    │   ├── HomeFragment.kt
    │   └── adapter/
    │       └── StationAdapter.kt          # RecyclerView adapter
    ├── player/
    │   └── PlayerBottomSheet.kt           # Full-screen BottomSheetDialogFragment
    └── util/
        └── ViewExtensions.kt
│
└── auto/
    ├── RadioCarAppService.kt               # CarAppService entry point
    └── RadioCarScreen.kt                   # Car UI (station list + playback controls)
```

---

## Data Layer

### Station Model (`domain/model/Station.kt`)

Mirrors the web app's `Station` interface:

```kotlin
data class Station(
    val id: String,
    val name: String,
    val streamUrl: String,       // url_resolved equivalent
    val faviconUrl: String,
    val tags: List<String>,
    val country: String,
    val state: String
)
```

### Hardcoded Stations (`StationRepositoryImpl.kt`)

Same 5 stations as the web app:
1. Vividh Bharti — HLS m3u8 (AIR National)
2. Radio Mirchi 98.3 — MP3 (Nagpur)
3. BIG 92.7 FM — MP3 (Nagpur)
4. Radio City 91.1 — MP3 (Nagpur)
5. Red FM 93.5 — MP3 (Nagpur)

### DataStore (`UserPreferencesDataStore.kt`)

Persists:
- `lastStationId: String` — ID of last played station
- `volume: Int` — 0–100

Uses `androidx.datastore:datastore-preferences`.

---

## Audio Layer

### RadioPlaybackService

Extends `MediaLibraryService` (Media3). Responsibilities:
- Creates and owns the `ExoPlayer` instance
- Creates and owns the `MediaSession`
- Handles HLS streams via Media3's built-in HLS extension
- Manages audio focus via `AudioFocusRequest` (API 26+):
  - Request focus on play
  - Release focus on stop/destroy
  - Pause on `AUDIOFOCUS_LOSS`, duck or pause on `AUDIOFOCUS_LOSS_TRANSIENT`
  - Resume on `AUDIOFOCUS_GAIN` if was playing before loss
- Registers `BroadcastReceiver` for `AudioManager.ACTION_AUDIO_BECOMING_NOISY`:
  - Auto-pause when headphones/BT disconnect
- Exposes `MediaSession` to the system for lock screen and notification controls
- Shows a persistent foreground notification (Media3's `MediaNotification` built-in)
- Runs as a foreground service while playing

### MediaController (Presentation layer)

`MainViewModel` builds a `MediaController` connected to `RadioPlaybackService` via `SessionToken`.
All play/pause/station change commands flow through the `MediaController` — the ViewModel
never touches ExoPlayer directly.

---

## Presentation Layer

### MainActivity

- Single activity
- Hosts `NavHostFragment` (Navigation Component)
- Hosts the **mini player bar** (always visible at the bottom when a station is selected)
- Observes `MainViewModel` for current station + play state to show/hide mini player
- Binds `MediaController` lifecycle to activity

### HomeFragment

- `DashboardHero` section: static branded header (TextView + badge)
- `StationGrid`: horizontal `RecyclerView` with `LinearLayoutManager` (horizontal)
  - `StationAdapter` binds station name, favicon (Glide), and active state
  - Item click → ViewModel `selectStation(station)`
- No categories section

### MainViewModel

Responsibilities:
- Holds `MediaController` (connects to `RadioPlaybackService`)
- Exposes `StateFlow<Station?>` for current station
- Exposes `StateFlow<Boolean>` for isPlaying
- Exposes `StateFlow<Int>` for volume
- `selectStation(station)`: sets MediaItem on controller, calls `play()`
- `togglePlay()`: play/pause via controller
- `setVolume(v)`: sets volume via controller + saves to DataStore
- On init: reads DataStore, restores last station and volume

### PlayerBottomSheet

Full-screen `BottomSheetDialogFragment`. Shown when user taps the mini player.
- Station artwork (Glide, with fallback drawable)
- Station name + tags + LIVE badge
- Play/Pause button (large)
- Volume SeekBar (0–100, bound to MainViewModel)
- Dismiss handle at top
- Animated visualizer bars (simple ValueAnimator on 4 views)
- Observes same `MainViewModel` as MainActivity

### Mini Player Bar

Embedded in `activity_main.xml` (not a fragment — just a `ConstraintLayout`).
- Station favicon (Glide)
- Station name
- 4-bar visualizer (shows when playing)
- Play/Pause ImageButton
- Tap anywhere → opens `PlayerBottomSheet`

---

## Navigation

Navigation Component with a single `nav_graph.xml`:

```
HomeFragment  (start destination)
    └── PlayerBottomSheet  (bottom sheet action)
```

---

## Key Dependencies (`build.gradle.kts`)

```kotlin
// Media3 (ExoPlayer)
implementation("androidx.media3:media3-exoplayer:1.3.1")
implementation("androidx.media3:media3-exoplayer-hls:1.3.1")
implementation("androidx.media3:media3-session:1.3.1")
implementation("androidx.media3:media3-ui:1.3.1")

// DataStore
implementation("androidx.datastore:datastore-preferences:1.1.1")

// ViewModel + LiveData
implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.3")
implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.3")

// Navigation
implementation("androidx.navigation:navigation-fragment-ktx:2.7.7")
implementation("androidx.navigation:navigation-ui-ktx:2.7.7")

// Image loading
implementation("com.github.bumptech.glide:glide:4.16.0")

// Coroutines
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

// ViewBinding (enabled in build.gradle, no dep needed)

// Android Auto
implementation("androidx.car.app:app:1.4.0")
```

---

## AndroidManifest Permissions & Declarations

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />  <!-- API 33+ -->

<service
    android:name=".data.service.RadioPlaybackService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true">
    <intent-filter>
        <action android:name="androidx.media3.session.MediaLibraryService" />
    </intent-filter>
</service>
```

---

## Screens Summary

| Screen | Type | Key Views |
|---|---|---|
| Home | Fragment | RecyclerView (stations), static hero TextView |
| Mini Player | View in Activity | ImageView, TextView, ImageButton, Visualizer |
| Expanded Player | BottomSheetDialogFragment | ImageView, SeekBar, ImageButton, Visualizer |

---

## Build & Distribution

- **Build variant:** `release` with `minifyEnabled false` (internal APK, no obfuscation needed yet)
- **Signing:** local debug keystore for internal distribution
- **Output:** unsigned or debug-signed APK shared directly

---

## Implementation Order

1. Project setup — Gradle, ViewBinding, package skeleton
2. Domain layer — `Station` model, `StationRepository` interface, use cases
3. Data layer — `StationRepositoryImpl` (hardcoded), `UserPreferencesDataStore`
4. Audio service — `RadioPlaybackService` with ExoPlayer + MediaSession + HLS
5. Audio focus + BECOMING_NOISY handling
6. `MainViewModel` — MediaController wiring, StateFlows
7. `HomeFragment` + `StationAdapter` — station grid
8. Mini player bar in `MainActivity`
9. `PlayerBottomSheet` — expanded player UI
10. DataStore persistence (restore last station + volume on launch)
11. Foreground notification (verify lock screen controls work)
12. Polish — Glide image loading, visualizer animation, edge cases
