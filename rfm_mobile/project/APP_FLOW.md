# App Flow — RFM Mobile

**Version:** 1.0 | **Date:** 2026-04-23

---

## 1. App Launch Flow

```
App Cold Start
│
├── AudioService.init()
│
├── SharedPreferences.load()
│   ├── last_station → restore RadioState
│   ├── volume → restore volume
│   ├── visualizer_style → restore visualizer
│   └── city → restore LocationState
│
├── Location Check
│   ├── city in prefs? ──YES──→ use saved city
│   └── NO → request GPS permission
│            ├── GRANTED → geolocate → geocode → set city
│            └── DENIED  → fallback city = "Nagpur"
│
└── MainScreen (FORGE tab active)
    └── fetch stations for city (cityStationsProvider)
        fetch all stations (stationsProvider)
```

---

## 2. Navigation Shell

```
MainScreen (IndexedStack — preserves scroll state)
│
├── [0] FORGE — Dashboard / Discovery
├── [1] WAVES — Full Player
└── [2] SCAN  — Search

MiniPlayer (overlay above nav bar)
  Visible: tabs 0, 2 AND a station is loaded
  Hidden:  tab 1 (player already visible)

GlassmorphicNavBar (always visible)
```

---

## 3. Discovery Flow (FORGE tab)

```
FORGE Tab
│
├── Hero Section
│   └── currentStation loaded? 
│       ├── YES → show station name, play CTA
│       └── NO  → show default "THE IRON RHYTHM" placeholder
│
├── Local Transmission (City Carousel)
│   ├── cityStationsProvider loads
│   │   ├── loading → shimmer/skeleton
│   │   ├── error   → [GAP: silent empty list today]
│   │   └── data    → horizontal scrollable cards
│   │                 tap card → play station + go to WAVES tab
│   │
│   └── City Label (tappable)
│       └── opens Location Dialog
│           ├── "Auto-detect" → GPS flow (see §1)
│           └── Type city name → manual override → reload carousel
│
└── National Network (Full List)
    ├── stationsProvider loads
    │   ├── loading → skeleton list
    │   ├── error   → [GAP: silent empty list today]
    │   └── data    → staggered station list tiles
    └── tap tile → play station
```

---

## 4. Playback Flow

### 4a. Start Playback
```
User taps station (any screen)
│
├── RadioController.playStation(station)
│   ├── set currentStation
│   ├── set isBuffering = true
│   ├── AudioHandler.playStation(url)
│   │   └── just_audio loads stream URL
│   ├── on ready → isBuffering = false, isPlaying = true
│   └── persist station to SharedPreferences
│
└── UI updates
    ├── MiniPlayer appears (FORGE / SCAN tabs)
    ├── Hero card updates to new station
    └── WAVES tab shows new station
```

### 4b. Full Player (WAVES tab)
```
WAVES Tab
│
├── Station artwork (Hero animated from MiniPlayer)
├── Station name + city/state metadata
├── Audio Visualizer (animated bars)
│   └── style: classic | colorful (from settings)
├── Play / Pause button (haptic feedback on tap)
├── Volume Slider (0.0 → 1.0)
│   └── change → RadioController.setVolume() → persist
├── Settings icon (top-right)
│   └── [GAP: onPressed is empty stub today]
└── Status: "ANALOG RECEIVER // V.1.0"
```

### 4c. MiniPlayer
```
MiniPlayer (overlay)
│
├── Station favicon + name
├── Play / Pause toggle
└── tap anywhere (non-button) → SlideTransition → Full Player
    └── Hero animation: artwork mini → full
```

### 4d. Background / Lock Screen
```
Station playing → AudioService active
├── Notification: station name, play/pause control
├── Lock screen: same controls
└── [GAP: skip next/prev buttons in notification — stub only]
```

### 4e. Playback States
```
IDLE ──play()──→ LOADING ──ready──→ PLAYING
                                    │
                          pause()←──┤──→pause()──→ PAUSED
                                    │
                          error  ←──┘──→ ERROR [GAP: no UI]
```

---

## 5. Search Flow (SCAN tab)

```
SCAN Tab
│
├── Text Search Mode
│   ├── user types in search field
│   ├── filteredStationsProvider(query) fires
│   └── results list updates
│       ├── matches → station list tiles (tap → play)
│       └── no matches → "NO SIGNAL FOUND" empty state
│
├── Territory Filter Mode
│   ├── State dropdown → statesProvider loads all states
│   ├── select state → citiesForStateProvider(state) loads cities
│   ├── select city → filteredStationsProvider(state, city) fires
│   └── results: stations in that city
│
└── Both modes mutually exclusive (text OR location filter)
    "VIEW ALL STATIONS" button → clears filters → full list
```

---

## 6. Settings Flow (PARTIAL — GAP)

```
Player Screen → settings icon tap
│
└── [GAP: currently no-op]
    Intended: show SettingsPanel (widget exists)
    │
    └── SettingsPanel (settings_panel.dart)
        ├── Visualizer Style toggle (classic ↔ colorful)
        │   └── RadioController.setVisualizerStyle() → persist
        └── [BACKLOG: sleep timer, EQ, etc.]
```

---

## 7. Location Flow

```
Location change trigger:
├── App launch (no saved city)
├── User taps city label on FORGE
└── User taps "Auto-detect" in location dialog

GPS Auto-detect:
  geolocator.getCurrentPosition()
  └── geocoding.placemarkFromCoordinates()
      ├── success → extract city name → set LocationState.city
      └── failure → keep previous city (or fallback "Nagpur")

Manual entry:
  user types city → set LocationState.city → dismiss dialog
  └── cityStationsProvider re-evaluates → carousel reloads
```

---

## 8. Error States (Current vs. Needed)

| Scenario | Current Behavior | Needed |
|----------|-----------------|--------|
| API unreachable | Empty list, no message | "Signal lost — tap to retry" |
| Station URL fails | Audio stops silently | Error toast + offer next station |
| Location denied | Fallback Nagpur silently | Inform user of fallback |
| No stations in city | Empty carousel, no message | "No local stations — browse national" CTA |
| Search no results | "NO SIGNAL FOUND" ✓ | — |

---

## 9. Data Flow Diagram

```
User Action
    │
    ▼
Widget (ConsumerWidget)
    │  watch / read
    ▼
Riverpod Provider
    │
    ├── FutureProvider ──────────→ StationRepository ──→ StationApi ──→ HTTP ──→ Backend
    │                                                                            (Vercel/MongoDB)
    └── StateNotifier
        ├── RadioController ──→ RadioHandler ──→ just_audio ──→ Stream URL
        └── LocationNotifier ──→ geolocator/geocoding
            │
            └── PersistenceService ──→ SharedPreferences (local disk)
```

---

## 10. Screen × Feature Matrix

| Feature | FORGE | WAVES | SCAN | MiniPlayer | Lock Screen |
|---------|-------|-------|------|------------|-------------|
| Show current station | ✓ | ✓ | — | ✓ | ✓ |
| Play / Pause | ✓ (tap card) | ✓ | ✓ (tap result) | ✓ | ✓ |
| Volume control | — | ✓ | — | — | — |
| Visualizer | — | ✓ | — | — | — |
| City filter | ✓ | — | ✓ | — | — |
| Text search | — | — | ✓ | — | — |
| Skip next/prev | — | ✗ GAP | — | — | ✗ GAP |
| Favorites | ✗ GAP | ✗ GAP | ✗ GAP | — | — |
| History | ✗ GAP | ✗ GAP | — | — | — |
| Settings | — | ✗ GAP | — | — | — |
| Station detail | — | ✗ GAP | ✗ GAP | — | — |

---

## 11. Backlog Flows (Not Yet Built)

### Favorites
```
Any screen → heart icon on station card/tile
├── add → persist to SharedPreferences (list of changeuuids)
└── new tab or section: "SAVED FREQUENCIES"
    └── list saved stations → tap → play
```

### Recently Played
```
RadioController.playStation()
└── append to history list (max 20) → persist
    └── FORGE tab: "RECENT TRANSMISSIONS" section
        └── horizontal scroll of last-played stations
```

### Sleep Timer
```
SettingsPanel → Sleep Timer
├── options: 15m / 30m / 60m / off
├── set → start countdown
├── countdown reaches 0 → RadioController.pause()
└── indicator: timer icon in MiniPlayer with remaining time
```

### Station Detail Sheet
```
Long press station card / info icon
└── bottom sheet:
    ├── name, favicon
    ├── frequency (e.g., "104.2 FM")
    ├── bitrate, language, tags
    ├── city, state
    ├── established year
    ├── homepage link (url_launcher)
    ├── contact number
    ├── votes/rating
    └── share button
```

### Skip Next / Prev
```
Context: "queue" = current list user was browsing
├── FORGE city carousel → skip within city stations
├── FORGE national list → skip within all stations
├── SCAN results → skip within filtered results
└── Default → skip within all stations

Controls appear:
├── WAVES tab: prev / next buttons flanking play button
└── Lock screen notification: prev / next media buttons
```
