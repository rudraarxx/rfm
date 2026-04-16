#!/usr/bin/env node
/**
 * Fetches ALL Indian radio stations from Radio Browser API (public domain)
 * and saves them as a local JSON cache.
 *
 * Usage: node scripts/fetch-indian-stations.mjs
 */

const MIRRORS = [
  "https://de1.api.radio-browser.info/json",
  "https://at1.api.radio-browser.info/json",
  "https://nl1.api.radio-browser.info/json",
];

async function fetchFromMirror(endpoint) {
  for (const mirror of MIRRORS) {
    try {
      const url = `${mirror}${endpoint}`;
      console.log(`  Trying ${url}...`);
      const res = await fetch(url, {
        headers: { "User-Agent": "RFMWeb/1.0" },
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return await res.json();
    } catch (e) {
      console.log(`  Mirror failed: ${e.message}`);
    }
  }
  throw new Error("All mirrors failed");
}

async function main() {
  console.log("🇮🇳 Fetching all Indian radio stations from Radio Browser...\n");

  // Fetch all Indian stations (no limit)
  const allStations = await fetchFromMirror(
    "/stations/search?countrycode=IN&order=votes&reverse=true&limit=1000&lastcheckok=1"
  );

  console.log(`\n✅ Fetched ${allStations.length} stations from Radio Browser\n`);

  // Map to our Station format
  const stations = allStations.map((item) => ({
    changeuuid: item.stationuuid || item.changeuuid,
    name: item.name.trim(),
    url: item.url,
    url_resolved: item.url_resolved,
    homepage: item.homepage || "",
    favicon: item.favicon || "",
    tags: item.tags || "",
    country: item.country || "India",
    state: item.state || "",
    language: item.language || "",
    votes: item.votes || 0,
    codec: item.codec || "",
    bitrate: item.bitrate || 0,
    source: "radio-browser",
  }));

  // Filter out stations with empty URLs
  const valid = stations.filter((s) => s.url && s.url.trim().length > 0);

  console.log(`📻 ${valid.length} stations with valid stream URLs`);

  // Organize by state
  const byState = {};
  for (const s of valid) {
    const state = s.state || "Unknown";
    if (!byState[state]) byState[state] = [];
    byState[state].push(s);
  }

  console.log(`\n📊 Stations by state:`);
  for (const [state, list] of Object.entries(byState).sort(
    (a, b) => b[1].length - a[1].length
  )) {
    console.log(`   ${state}: ${list.length}`);
  }

  // Try to detect city from station name for common Indian cities
  const KNOWN_CITIES = [
    "Mumbai", "Delhi", "Bengaluru", "Bangalore", "Chennai", "Kolkata",
    "Hyderabad", "Pune", "Ahmedabad", "Jaipur", "Lucknow", "Nagpur",
    "Kochi", "Trivandrum", "Thiruvananthapuram", "Chandigarh", "Amritsar",
    "Surat", "Vadodara", "Indore", "Bhopal", "Patna", "Ranchi",
    "Guwahati", "Visakhapatnam", "Coimbatore", "Madurai", "Mysuru",
    "Mysore", "Mangaluru", "Mangalore", "Jodhpur", "Udaipur",
    "Varanasi", "Kanpur", "Ludhiana", "Shimla", "Dehradun",
    "Panaji", "Goa", "Nashik", "Aurangabad", "Kozhikode",
  ];

  // Assign city if detectable from name
  for (const s of valid) {
    const nameLower = s.name.toLowerCase();
    for (const city of KNOWN_CITIES) {
      if (nameLower.includes(city.toLowerCase())) {
        s.city = city;
        break;
      }
    }
    if (!s.city) s.city = "";
  }

  const withCity = valid.filter((s) => s.city);
  console.log(`\n🏙️  ${withCity.length} stations with detected city`);

  // Write output
  const fs = await import("fs");
  const path = await import("path");
  const outPath = path.join(
    process.cwd(),
    "src",
    "data",
    "radio-browser-cache.json"
  );

  // Ensure directory exists
  fs.mkdirSync(path.dirname(outPath), { recursive: true });

  const output = {
    fetchedAt: new Date().toISOString(),
    totalStations: valid.length,
    stations: valid,
  };

  fs.writeFileSync(outPath, JSON.stringify(output, null, 2));
  console.log(`\n💾 Saved to ${outPath}`);

  // ── Firebase Upload ────────────────────────────────────────────────────────
  const serviceAccountPath = path.join(process.cwd(), "firebase-service-account.json");
  
  if (fs.existsSync(serviceAccountPath)) {
    console.log("\n🚀 Uploading to Firebase Storage...");
    try {
      const { default: admin } = await import("firebase-admin");
      const { readFileSync } = await import("fs");
      
      const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, "utf8"));
      
      // Use the bucket from user config if possible, fallback to project_id.appspot.com
      const bucketName = "retro-radio-493505.firebasestorage.app"; 
      
      // Initialize only if not already initialized
      if (!admin.apps.length) {
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
          storageBucket: bucketName
        });
      }

      const bucket = admin.storage().bucket();
      const destination = "radio-browser-cache.json";
      
      await bucket.upload(outPath, {
        destination,
        public: true, // Make it publicly readable for the app
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
    console.log("\nℹ️  Skipping Firebase upload: 'firebase-service-account.json' not found in project root.");
    console.log("   To enable upload, place your Firebase Service Account JSON file in the root directory.");
  }

  console.log("\n✨ Done!");
}

main().catch((e) => {
  console.error("❌ Error:", e.message);
  process.exit(1);
});
