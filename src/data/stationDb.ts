import { Station } from "@/types/radio";
import radioBrowserCache from "./radio-browser-cache.json";
import stationIndexRaw from "./station-index.json";

let STATION_INDEX = stationIndexRaw as Record<string, string[]>;

/**
 * Updates the city index (used for dropdowns)
 */
export function updateStationIndex(newIndex: Record<string, string[]>) {
  STATION_INDEX = newIndex;
}

// ── Verified stream URLs (from Android app) ──────────────────────────────────
// RadioMirchi has no public HTTP stream (DRM/app-only). Using AIR Rainbow (pop/Bollywood) as equivalent.
const AIR_RAINBOW = "https://air.pc.cdn.bitgravity.com/air/live/pbaudio015/playlist.m3u8"; // AIR FM – Bollywood/Hindi pop (verified ✅)
const BIG_FM = "https://stream.zeno.fm/dbstwo3dvhhtv";
const RED_FM = "https://stream.zeno.fm/9phrkb1e3v8uv";
const RADIO_CITY = "https://stream.zeno.fm/pxc55r5uyc9uv";
const ISHQ_FM = "https://drive.uber.radio/uber/bollywoodlove/icecast.audio";
const VIVIDH_BHARATI_NATIONAL = "https://air.pc.cdn.bitgravity.com/air/live/pbaudio001/playlist.m3u8";
const AIR_GOLD_DELHI = "https://airhlspush.pc.cdn.bitgravity.com/httppush/hlspbaudio005/hlspbaudio005_Auto.m3u8";
const SURYAN_935 = "https://radios.crabdance.com:8002/2";
const RADIO_INDIGO = "https://a2.asurahosting.com/hls/office_radio/live.m3u8";

// ── Manual Station Database (Highest Priority) ────────────────────────────────
const MANUAL_CITY_STATIONS: Record<string, Station[]> = {
  "Maharashtra|Nagpur": [
    // ✅ All streams verified live on 2026-04-16 (Radio Mirchi 98.3 has no public stream – DRM/app-only)
    {
      changeuuid: "hc-air-rainbow-nagpur", name: "AIR Rainbow FM – Nagpur",
      url: AIR_RAINBOW, url_resolved: AIR_RAINBOW,
      homepage: "https://prasarbharati.gov.in/", favicon: "/stations/vividh_bharti.png",
      tags: "bollywood,hindi,pop,nagpur", country: "India", state: "Maharashtra", city: "Nagpur", votes: 1200
    },
    {
      changeuuid: "hc-big-927-nagpur", name: "BIG FM 92.7 – Nagpur",
      url: BIG_FM, url_resolved: BIG_FM,
      homepage: "https://www.bigfmindia.com/", favicon: "/stations/big_fm.png",
      tags: "bollywood,nagpur,hindi", country: "India", state: "Maharashtra", city: "Nagpur", votes: 1100
    },
    {
      changeuuid: "hc-redfm-935-nagpur", name: "Red FM 93.5 – Nagpur",
      url: RED_FM, url_resolved: RED_FM,
      homepage: "https://www.redfmindia.in/", favicon: "/stations/red_fm.png",
      tags: "bollywood,nagpur,hindi", country: "India", state: "Maharashtra", city: "Nagpur", votes: 1000
    },
    {
      changeuuid: "hc-radiocity-911-nagpur", name: "Radio City 91.1 – Nagpur",
      url: RADIO_CITY, url_resolved: RADIO_CITY,
      homepage: "https://www.radiocity.in/", favicon: "/stations/radio_city.png",
      tags: "bollywood,nagpur,hindi", country: "India", state: "Maharashtra", city: "Nagpur", votes: 950
    },
    {
      // AIR Vividh Bharati 100.6 MHz – the entertainment/music channel of AIR Nagpur
      changeuuid: "hc-vividh-bharati-nagpur", name: "Vividh Bharati 100.6 – Nagpur",
      url: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio070/playlist.m3u8",
      url_resolved: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio070/playlist.m3u8",
      homepage: "https://prasarbharati.gov.in/", favicon: "/stations/vividh_bharti.png",
      tags: "national,classic,nagpur,hindi", country: "India", state: "Maharashtra", city: "Nagpur", votes: 900
    },
    {
      // AIR Nagpur Primary – 102.1 MHz / 585 kHz AM – News & Talk
      changeuuid: "hc-air-nagpur-primary", name: "AIR Nagpur 102.1 FM",
      url: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio069/playlist.m3u8",
      url_resolved: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio069/playlist.m3u8",
      homepage: "https://prasarbharati.gov.in/", favicon: "/stations/vividh_bharti.png",
      tags: "national,news,nagpur,marathi", country: "India", state: "Maharashtra", city: "Nagpur", votes: 850
    },
    {
      // AIR Nagpur additional stream - 107.2 MHz
      changeuuid: "hc-air-nagpur-107", name: "AIR Nagpur 107.2 FM",
      url: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio071/playlist.m3u8",
      url_resolved: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio071/playlist.m3u8",
      homepage: "https://prasarbharati.gov.in/", favicon: "/stations/vividh_bharti.png",
      tags: "national,regional,nagpur,marathi", country: "India", state: "Maharashtra", city: "Nagpur", votes: 800
    },
  ],
  "Maharashtra|Mumbai": [
    {
      changeuuid: "hc-air-rainbow-mumbai", name: "AIR Rainbow FM – Mumbai",
      url: AIR_RAINBOW, url_resolved: AIR_RAINBOW,
      homepage: "https://prasarbharati.gov.in/", favicon: "/stations/vividh_bharti.png",
      tags: "bollywood,hindi,pop,mumbai", country: "India", state: "Maharashtra", votes: 1200
    },
    {
      changeuuid: "hc-redfm-935-mumbai", name: "Red FM 93.5 – Mumbai",
      url: RED_FM, url_resolved: RED_FM,
      homepage: "https://www.redfmindia.in/", favicon: "/stations/red_fm.png",
      tags: "bollywood,mumbai,hindi", country: "India", state: "Maharashtra", votes: 1000
    },
    {
      changeuuid: "hc-ishq-mumbai", name: "Ishq 104.8 FM – Mumbai",
      url: ISHQ_FM, url_resolved: ISHQ_FM,
      homepage: "", favicon: "",
      tags: "bollywood,love,mumbai", country: "India", state: "Maharashtra", votes: 900
    },
  ],
  "Delhi|New Delhi": [
    {
      changeuuid: "hc-air-rainbow-delhi", name: "AIR Rainbow FM – Delhi",
      url: AIR_RAINBOW, url_resolved: AIR_RAINBOW,
      homepage: "https://prasarbharati.gov.in/", favicon: "/stations/vividh_bharti.png",
      tags: "bollywood,hindi,pop,delhi", country: "India", state: "Delhi", votes: 1200
    },
    {
      changeuuid: "hc-air-gold-delhi", name: "AIR FM Gold – Delhi",
      url: AIR_GOLD_DELHI, url_resolved: AIR_GOLD_DELHI,
      homepage: "https://prasarbharati.gov.in/", favicon: "/stations/vividh_bharti.png",
      tags: "national,news,delhi", country: "India", state: "Delhi", votes: 850
    },
  ],
};

const MANUAL_NATIONAL_STATIONS: Station[] = [
  {
    changeuuid: "hc-vividh-bharati", name: "Vividh Bharati",
    url: VIVIDH_BHARATI_NATIONAL, url_resolved: VIVIDH_BHARATI_NATIONAL,
    homepage: "https://prasarbharati.gov.in/", favicon: "/stations/vividh_bharti.png",
    tags: "national,classic,hindi", country: "India", state: "National", votes: 1500
  },
  {
    changeuuid: "hc-air-fmgold", name: "AIR FM Gold",
    url: AIR_GOLD_DELHI, url_resolved: AIR_GOLD_DELHI,
    homepage: "https://prasarbharati.gov.in/", favicon: "/stations/vividh_bharti.png",
    tags: "national,news,hindi", country: "India", state: "National", votes: 1400
  },
];

// ── Merging Logic ────────────────────────────────────────────────────────────

/**
 * Normalizes state names and merges provided cache stations with manual ones.
 * The manual layer always takes priority.
 */
export function processStationData(cacheStations: Station[]): Station[] {
  const allStationsMap = new Map<string, Station>();

  // 1. Add manual national stations
  MANUAL_NATIONAL_STATIONS.forEach(s => allStationsMap.set(s.url, s));

  // 2. Add manual city stations
  Object.values(MANUAL_CITY_STATIONS).flat().forEach(s => allStationsMap.set(s.url, s));

  // 3. Add cached stations
  cacheStations.forEach(s => {
    if (!allStationsMap.has(s.url)) {
      let state = s.state || "";
      if (state.toLowerCase().includes("maha")) state = "Maharashtra";
      else if (state.toLowerCase().includes("delhi")) state = "Delhi";
      else if (state.toLowerCase().includes("karnat")) state = "Karnataka";
      else if (state.toLowerCase().includes("tamil")) state = "Tamil Nadu";
      else if (state.toLowerCase().includes("west ben")) state = "West Bengal";
      else if (state.toLowerCase().includes("gujarat")) state = "Gujarat";
      else if (state.toLowerCase().includes("punjab")) state = "Punjab";
      else if (state.toLowerCase().includes("rajast")) state = "Rajasthan";
      else if (state.toLowerCase().includes("kerala")) state = "Kerala";
      else if (state.toLowerCase().includes("telangan")) state = "Telangana";
      else if (state.toLowerCase().includes("goa")) state = "Goa";
      else if (state.toLowerCase().includes("uttar p")) state = "Uttar Pradesh";

      allStationsMap.set(s.url, { ...s, state });
    }
  });

  return Array.from(allStationsMap.values());
}

// Default library loaded from bundled cache
let INITIAL_STATIONS = processStationData(radioBrowserCache.stations as Station[]);

/**
 * Merges additional stations (e.g. from a remote fetch) into the current database.
 */
export function mergeRemoteStations(newStations: Station[]) {
  INITIAL_STATIONS = processStationData([...radioBrowserCache.stations as Station[], ...newStations]);
  return INITIAL_STATIONS;
}

// ── Lookup helpers (Accepting arbitrary station lists) ───────────────────────

export function getStationsForCity(state: string, city: string, stations: Station[] = INITIAL_STATIONS): Station[] {
  const manual = MANUAL_CITY_STATIONS[`${state}|${city}`] || [];
  const cityLower = city.toLowerCase();
  
  const fromCache = stations.filter(s => {
    if (manual.some(m => m.name === s.name)) return false;
    const nameMatch = s.name.toLowerCase().includes(cityLower);
    const tagMatch = s.tags.toLowerCase().split(',').some(t => t.trim() === cityLower);
    return s.state === state && (nameMatch || tagMatch);
  });

  return [...manual, ...fromCache];
}

export function getStationsForState(state: string, stations: Station[] = INITIAL_STATIONS): Station[] {
  return stations.filter(s => s.state === state);
}

export function getCitiesForState(state: string, stations: Station[] = INITIAL_STATIONS): string[] {
  const cities = new Set<string>();
  // 1. Add cities from manual overrides
  for (const key of Object.keys(MANUAL_CITY_STATIONS)) {
    if (key.startsWith(`${state}|`)) {
      cities.add(key.split("|")[1]);
    }
  }
  
  // 2. Add cities from the scraped index
  for (const key of Object.keys(STATION_INDEX)) {
    if (key.startsWith(`${state}|`)) {
      cities.add(key.split("|")[1]);
    }
  }

  // 3. Fallback: scan existing stations for well-known cities
  // (Still useful for the base radio-browser-cache which isn't perfectly indexed)
  stations.forEach(s => {
    if (s.state === state && s.city) {
      cities.add(s.city);
    }
  });
  
  return Array.from(cities).sort();
}

export function getAvailableStates(stations: Station[] = INITIAL_STATIONS): string[] {
  const states = new Set<string>();
  stations.forEach(s => {
    if (s.state && s.state !== "National") {
      states.add(s.state);
    }
  });
  return Array.from(states).sort();
}

export function getAllStations(stations: Station[] = INITIAL_STATIONS): Station[] {
  return stations;
}
