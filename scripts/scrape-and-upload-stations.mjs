#!/usr/bin/env node
/**
 * scrape-and-upload-stations.mjs
 *
 * Scrapes onlineradiofm.in for all Indian radio stations with their
 * state/city/genre/language metadata, enriches with stream URLs from
 * Radio Browser API, and uploads the result to Firebase Storage.
 *
 * Usage: node scripts/scrape-and-upload-stations.mjs
 */

import { readFileSync, writeFileSync, mkdirSync, existsSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";
import * as dotenv from "dotenv";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, "..");
dotenv.config({ path: join(ROOT, ".env.local") });

// ── Config ─────────────────────────────────────────────────────────────────────
const BASE_URL = "https://onlineradiofm.in";
const RADIO_BROWSER_MIRRORS = [
  "https://de1.api.radio-browser.info/json",
  "https://at1.api.radio-browser.info/json",
  "https://nl1.api.radio-browser.info/json",
];
const DELAY_MS = 500; // polite delay between requests
const OUT_PATH = join(ROOT, "src", "data", "onlineradiofm-cache.json");

// All Indian states (slug → display name)
const STATES = {
  "andhra-pradesh": "Andhra Pradesh",
  "assam": "Assam",
  "bihar": "Bihar",
  "chandigarh": "Chandigarh",
  "chhattisgarh": "Chhattisgarh",
  "delhi": "Delhi",
  "gujarat": "Gujarat",
  "haryana": "Haryana",
  "himachal-pradesh": "Himachal Pradesh",
  "jammu-and-kashmir": "Jammu and Kashmir",
  "jharkhand": "Jharkhand",
  "karnataka": "Karnataka",
  "kerala": "Kerala",
  "madhya-pradesh": "Madhya Pradesh",
  "maharashtra": "Maharashtra",
  "manipur": "Manipur",
  "mizoram": "Mizoram",
  "sikkim": "Sikkim",
  "puducherry": "Puducherry",
  "punjab": "Punjab",
  "rajasthan": "Rajasthan",
  "tamil-nadu": "Tamil Nadu",
  "telangana": "Telangana",
  "tripura": "Tripura",
  "uttar-pradesh": "Uttar Pradesh",
  "uttarakhand": "Uttarakhand",
  "west-bengal": "West Bengal",
  "odisha-orissa": "Odisha",
  "goa": "Goa",
  "meghalaya": "Meghalaya",
  "nagaland": "Nagaland",
  "arunachal-pradesh": "Arunachal Pradesh",
  "andaman-and-nicobar-islands": "Andaman & Nicobar Islands",
  "lakshadweep": "Lakshadweep",
};

// ── Helpers ───────────────────────────────────────────────────────────────────

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function fetchText(url) {
  try {
    const res = await fetch(url, {
      headers: {
        "User-Agent": "RFMRadio/1.0 (radio station aggregator)",
        Accept: "text/html,application/xhtml+xml",
      },
    });
    if (!res.ok) return null;
    return res.text();
  } catch {
    return null;
  }
}

async function fetchJson(url) {
  try {
    const res = await fetch(url, {
      headers: { "User-Agent": "RFMRadio/1.0" },
    });
    if (!res.ok) return null;
    return res.json();
  } catch {
    return null;
  }
}

// Extract links matching a pattern from HTML
function extractLinks(html, pattern) {
  const matches = [];
  const regexes = [
    /href="([^"]+)"/g,
    /href='([^']+)'/g,
    /\]\((https?:\/\/[^\s)]+)\)/g,
    /\]\(\/([^\s)]+)\)/g,
  ];
  
  for (const regex of regexes) {
    let m;
    while ((m = regex.exec(html)) !== null) {
      const href = m[1].startsWith("http") ? m[1] : (m[1].startsWith("/") ? m[1] : `/${m[1]}`);
      if (pattern.test(href)) {
        matches.push(href);
      }
    }
  }
  return [...new Set(matches)];
}

// Extract station entries from a city page
function parseStationsFromPage(html, stateSlug, citySlug, stateName, cityName) {
  const stations = [];
  
  // Site HTML structure:
  // <li> <a href="..." class="h4">Name</a>
  // <div class="name">... | Bitrate: <span>N Kbps</span></div>
  // <div class="name">Genre: <span>...</span></div>
  const stationRegex = /<li>\s*<a href="([^"]+)"[^>]*class="h4"[^>]*>([\s\S]*?)<\/a>[\s\S]*?(?:Bitrate: <span>(\d+)\s*Kbps<\/span>)?[\s\S]*?(?:Genre: <span>([\s\S]*?)<\/span>)?[\s\S]*?(?:Frequency: <span>([\s\S]*?)<\/span>)?[\s\S]*?(?:Language: <span>([\s\S]*?)<\/span>)?/g;

  let match;
  while ((match = stationRegex.exec(html)) !== null) {
    const [_, href, nameRaw, bitrateStr, genresRaw, frequency, languagesRaw] = match;
    
    // Clean name (strip HTML)
    const name = nameRaw.replace(/<[^>]+>/g, "").trim();
    const slug = href.split("/").pop();
    
    if (Object.values(STATES).includes(name)) continue;

    const tags = genresRaw ? genresRaw.replace(/<[^>]+>/g, "").replace(/\.\s*$/, "").trim() : "";
    const languages = languagesRaw ? languagesRaw.replace(/<[^>]+>/g, "").replace(/\.\s*$/, "").trim() : "";

    stations.push({
      changeuuid: `orfm-${stateSlug}-${citySlug}-${slug}`,
      name,
      slug,
      url: "", 
      url_resolved: "",
      homepage: href.startsWith("http") ? href : `${BASE_URL}/${href.replace(/^\//, "")}`,
      favicon: "",
      tags: tags.toLowerCase(),
      country: "India",
      state: stateName,
      city: cityName,
      language: languages,
      frequency: frequency ? frequency.trim() : "",
      bitrate: bitrateStr ? parseInt(bitrateStr) : 0,
      votes: 0,
      source: "onlineradiofm",
    });
  }
  
  return stations;
}

// ── Radio Browser stream lookup ───────────────────────────────────────────────

let radioBrowserCache = null;

async function loadRadioBrowserDB() {
  if (radioBrowserCache) return radioBrowserCache;
  
  console.log("📡 Loading Radio Browser India stations...");
  
  // Check local cache first
  const localCachePath = join(ROOT, "src", "data", "radio-browser-cache.json");
  if (existsSync(localCachePath)) {
    const cached = JSON.parse(readFileSync(localCachePath, "utf-8"));
    radioBrowserCache = cached.stations || [];
    console.log(`  Loaded ${radioBrowserCache.length} stations from local cache`);
    return radioBrowserCache;
  }
  
  // Fetch from API
  for (const mirror of RADIO_BROWSER_MIRRORS) {
    try {
      const data = await fetchJson(
        `${mirror}/stations/search?countrycode=IN&limit=2000&lastcheckok=1&order=votes&reverse=true`
      );
      if (data) {
        radioBrowserCache = data;
        console.log(`  Fetched ${data.length} stations from Radio Browser`);
        return radioBrowserCache;
      }
    } catch {}
  }
  
  radioBrowserCache = [];
  return [];
}

function normalizeForMatch(str) {
  return str.toLowerCase()
    .replace(/\s+/g, " ")
    .replace(/[^\w\s]/g, "")
    .trim();
}

async function fetchStreamUrlFromPage(stationPageUrl) {
  const html = await fetchText(stationPageUrl);
  if (!html) return "";
  
  // Look for var FILE = "..." pattern common on the site
  const fileMatch = html.match(/var\s+FILE\s*=\s*["']([^"']+)["']/);
  if (fileMatch) {
    return fileMatch[1];
  }

  // Fallback to searching for audio sources
  const audioMatch = html.match(/<source[^>]+src=["']([^"']+\.mp3|[^"']+\.m3u8|[^"']+\.aac)[^"']*["']/i);
  if (audioMatch) {
    return audioMatch[1];
  }

  return "";
}

async function findStreamUrl(stationName, cityName, stateName, stationPageUrl) {
  // Strategy 1: Radio Browser lookup
  const db = await loadRadioBrowserDB();
  const normalName = normalizeForMatch(stationName);
  const nameNoFreq = normalName.replace(/\d+\.?\d*\s*(fm|am|mhz|khz)?/gi, "").trim();
  
  // Exact name match
  for (const s of db) {
    const sName = normalizeForMatch(s.name);
    if (sName === normalName && s.url) return s.url_resolved || s.url;
  }
  
  // Keyword match
  const keywords = nameNoFreq.split(" ").filter((w) => w.length > 3);
  if (keywords.length > 0) {
    const scored = db
      .filter((s) => s.url)
      .map((s) => {
        const sName = normalizeForMatch(s.name);
        const hits = keywords.filter((k) => sName.includes(k)).length;
        return { s, hits };
      })
      .filter((x) => x.hits >= Math.min(2, keywords.length))
      .sort((a, b) => b.s.votes - a.s.votes);
    
    if (scored.length > 0) return scored[0].s.url_resolved || scored[0].s.url;
  }

  // Strategy 2: Deep fetch from the station's own page if no match found
  if (stationPageUrl) {
    const directUrl = await fetchStreamUrlFromPage(stationPageUrl);
    if (directUrl) return directUrl;
  }
  
  return "";
}

// ── Main scraper ──────────────────────────────────────────────────────────────

async function scrapeCity(stateSlug, citySlug, stateName, cityName) {
  const url = `${BASE_URL}/${stateSlug}/${citySlug}`;
  const html = await fetchText(url);
  if (!html) return [];
  
  const stations = parseStationsFromPage(html, stateSlug, citySlug, stateName, cityName);
  return stations;
}

async function main() {
  console.log("🇮🇳 Scraping onlineradiofm.in for all Indian radio stations\n");
  
  // Preload Radio Browser DB
  await loadRadioBrowserDB();
  
  const allStations = [];
  const stateStats = {};
  
  for (const [stateSlug, stateName] of Object.entries(STATES)) {
    console.log(`\n📍 State: ${stateName}`);
    
    const stateUrl = `${BASE_URL}/${stateSlug}`;
    const stateHtml = await fetchText(stateUrl);
    if (!stateHtml) {
      console.log(`  ⚠️  Could not fetch ${stateUrl}`);
      continue;
    }
    await sleep(DELAY_MS);
    
    // Extract city links for this state
    // Pattern: can be absolute, relative with /, or relative without /
    // e.g. https://onlineradiofm.in/maharashtra/nagpur or /maharashtra/nagpur or maharashtra/nagpur
    const cityLinkPattern = new RegExp(`(?:https?://onlineradiofm\\.in)?/?${stateSlug}/([a-z0-9-]+)$`);
    const cityHrefs = extractLinks(stateHtml, cityLinkPattern);
    
    // Parse city slugs (unique, exclude state itself and common utility slugs)
    const utilitySlugs = ["state", "genre", "language", "countries", "add-radio"];
    const citySlugs = [...new Set(
      cityHrefs
        .map((href) => {
          const m = href.match(cityLinkPattern);
          return m ? m[1] : null;
        })
        .filter((slug) => slug && slug !== stateSlug && !utilitySlugs.includes(slug) && slug.length > 2)
    )];
    
    console.log(`  Found ${citySlugs.length} cities`);
    
    const stateStations = [];
    
    if (citySlugs.length === 0) {
      console.log(`  ℹ️  No sub-cities found. Scraping state page directly...`);
      const stations = await scrapeCity(stateSlug, "", stateName, stateName);
      if (stations.length > 0) {
        let matched = 0;
        for (const station of stations) {
          if (!station.url) {
            station.url = await findStreamUrl(station.name, stateName, stateName, station.homepage);
            station.url_resolved = station.url;
            if (station.url) matched++;
          } else matched++;
        }
        stateStations.push(...stations);
        console.log(`  🏙  ${stateName} (Direct)... ${stations.length} stations (${matched} w/ streams)`);
      }
    }

    for (const citySlug of citySlugs) {
      const cityName = citySlug
        .split("-")
        .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
        .join(" ");
      
      process.stdout.write(`  🏙  ${cityName}...`);
      
      const stations = await scrapeCity(stateSlug, citySlug, stateName, cityName);
      
      if (stations.length > 0) {
        let matched = 0;
        // Enrich with stream URLs
        for (const station of stations) {
          if (!station.url) {
            station.url = await findStreamUrl(station.name, cityName, stateName, station.homepage);
            station.url_resolved = station.url;
            if (station.url) matched++;
          } else {
            matched++;
          }
          // Slight delay between station deep fetches if done
          if (stations.length > 1) await sleep(100);
        }
        
        stateStations.push(...stations);
        process.stdout.write(` ${stations.length} stations (${matched} w/ streams)\n`);
      } else {
        process.stdout.write(` (none)\n`);
      }
      
      await sleep(DELAY_MS);
    }
    
    stateStats[stateName] = stateStations.length;
    allStations.push(...stateStations);
  }
  
  // Deduplicate by URL (keep first occurrence)
  const seen = new Set();
  const deduped = allStations.filter((s) => {
    if (!s.url) return true; // keep even without URL
    if (seen.has(s.url)) return false;
    seen.add(s.url);
    return true;
  });
  
  const withStreams = deduped.filter((s) => s.url);
  const withoutStreams = deduped.filter((s) => !s.url);
  
  console.log("\n📊 Summary by state:");
  for (const [state, count] of Object.entries(stateStats)) {
    if (count > 0) console.log(`   ${state}: ${count} stations`);
  }
  console.log(`\n📻 Total stations scraped: ${deduped.length}`);
  console.log(`   ✅ With stream URLs: ${withStreams.length}`);
  console.log(`   ⚠️  Without stream URLs: ${withoutStreams.length}`);
  
  // Save output
  mkdirSync(dirname(OUT_PATH), { recursive: true });
  const output = {
    scrapedAt: new Date().toISOString(),
    source: "https://onlineradiofm.in",
    totalStations: deduped.length,
    withStreamUrls: withStreams.length,
    stations: deduped,
  };
  writeFileSync(OUT_PATH, JSON.stringify(output, null, 2));
  console.log(`\n💾 Saved to ${OUT_PATH}`);
  
  // ── Firebase Upload ────────────────────────────────────────────────────────
  const serviceAccountEnv = process.env.FIREBASE_SERVICE_ACCOUNT;
  const serviceAccountPath = join(ROOT, "firebase-service-account.json");
  
  if (serviceAccountEnv || existsSync(serviceAccountPath)) {
    console.log("\n🚀 Uploading to Firebase Storage...");
    try {
      const { default: admin } = await import("firebase-admin");
      let serviceAccount;

      if (serviceAccountEnv) {
        console.log("  Using credentials from environment variable...");
        serviceAccount = JSON.parse(serviceAccountEnv);
      } else {
        console.log("  Using credentials from 'firebase-service-account.json'...");
        serviceAccount = JSON.parse(readFileSync(serviceAccountPath, "utf8"));
      }
      
      const bucketName = "retro-radio-493505.firebasestorage.app"; 
      
      if (!admin.apps.length) {
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
          storageBucket: bucketName
        });
      }

      const bucket = admin.storage().bucket();
      const destination = "radio-browser-cache.json";
      
      await bucket.upload(OUT_PATH, {
        destination,
        public: true,
        metadata: {
          contentType: "application/json",
          cacheControl: "public, max-age=3600",
        },
      });

      console.log(`✅ Successfully uploaded to Firebase Storage as ${destination}`);
      console.log(`🔗 Public URL: https://storage.googleapis.com/${bucket.name}/${destination}`);
    } catch (uploadError) {
      console.error("❌ Firebase Upload failed:", uploadError.message);
    }
  } else {
    console.log("\nℹ️  Skipping Firebase upload: 'firebase-service-account.json' not found.");
  }


  console.log("\n✨ Done!");
}

main().catch((e) => {
  console.error("❌ Error:", e.message);
  process.exit(1);
});
