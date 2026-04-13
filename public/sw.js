const CACHE_NAME = "rfm-radio-v1";
const ASSETS_TO_CACHE = [
  "/",
  "/manifest.json",
  "/icons/icon-192x192.png",
  "/icons/icon-512x512.png",
  "/icons/apple-touch-icon.png",
  "/stations/vividh_bharti.png",
  "/stations/radio_mirchi.png",
  "/stations/big_fm.png",
  "/stations/radio_city.png",
  "/stations/red_fm.png"
];

// Install Event
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS_TO_CACHE);
    })
  );
});

// Activate Event
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      );
    })
  );
});

// Fetch Event
self.addEventListener("fetch", (event) => {
  // Skip caching for audio streams and external APIs
  if (
    event.request.url.includes("stream.zeno.fm") || 
    event.request.url.includes("bitgravity.com") ||
    event.request.url.includes("radio-browser.info")
  ) {
    return;
  }

  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
