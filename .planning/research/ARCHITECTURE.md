# Research: Architecture Patterns

## Local-First Station Sync

### Flow
1. **Cloud Update**: Scraper script runs on a schedule (via GitHub Actions or manual maintenance) and uploads a versioned `stations.json` to Firebase Storage.
2. **Client Check**: On startup, the client (Web/Mobile) sends a HEAD request to check the `ETag` or `Last-Modified` header of the JSON file.
3. **Delta Check**: If the hash differs from the local copy, download the full list.
4. **Offline Mode**: If the network is down, the app remains fully functional using the last cached version.

### Benefits
- **Zero Latency**: No database query delay on startup.
- **Cost Efficiency**: No live DB instance costs; Firebase Storage is significantly cheaper for read-heavy static assets.
- **Simplicity**: No complex auth or write-locks needed for station discovery.

## Stream Health Monitoring

### Best Practices
- **Pre-flight HEAD checks**: Quickly verify stream availability before showing "Now Playing".
- **Adaptive Reconnection**: Use exponential backoff (2s, 4s, 8s...) to avoid battery drain during network outages.
- **Foreground Service (Android)**: Mandatory to keep the CPU/Wi-Fi alive when the screen is off.

---
*Research synthesized: 2026-04-28*
