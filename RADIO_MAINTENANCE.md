# Radio Station Database Maintenance

This guide explains how to manage and refresh the local station database in the RFM application.

## The Database Architecture

The application uses a **local-first** approach for discovery to ensure 100% reliability and instant loading. The data is stored in two parts:

1.  **Manual Layer** (`src/data/stationDb.ts`): Highly curated stations from the Android app with verified working streams.
2.  **Cache Layer** (`src/data/radio-browser-cache.json`): A snapshot of 1000+ Indian stations from the public Radio Browser API.

These layers are automatically merged and deduplicated by the database engine in `stationDb.ts`.

---

## Cloud Sync (Firebase Storage)

The application is now configured to sync the station list from **Firebase Storage** on startup.

### 1. Configure the Web App
Add your Firebase configuration to your environment variables (`.env.local`):

```bash
NEXT_PUBLIC_FIREBASE_API_KEY=your_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
```

### 2. Enable Automatic Uploads
To allow the update script to upload to the cloud:
1. Go to **Firebase Console** -> **Project Settings** -> **Service Accounts**.
2. Click **Generate New Private Key**.
3. Save the JSON file as `firebase-service-account.json` in the **project root folder**.
4. Run `npm run update-stations`. The script will now automatically upload the list to your Storage bucket and make it public.

### 3. Verification
- **App Startup**: The app will attempt to fetch `radio-browser-cache.json` from your Storage bucket. Check the browser console for "✅ Synced stations from Cloud".
- **Offline Fallback**: If the internet is down or Firebase is not configured, the app will automatically use the bundled `src/data/radio-browser-cache.json`.

---

## Adding Manual Stations

If you have a specific high-quality stream (like a new local FM station), add it to the `MANUAL_CITY_STATIONS` object in `src/data/stationDb.ts`.

### Example: Adding a station to Nagpur
1. Open [stationDb.ts](file:///Users/kundanprasad/code/rfm/src/data/stationDb.ts).
2. Find the `"Maharashtra|Nagpur"` key.
3. Add a new object to the array:

```typescript
{
  changeuuid: "my-custom-station-id",
  name: "My Local FM",
  url: "https://example.com/stream.mp3",
  url_resolved: "https://example.com/stream.mp3",
  tags: "local,nagpur",
  country: "India",
  state: "Maharashtra",
  votes: 1000
}
```

---

## Technical Maintenance
The fetch logic is located in [fetch-indian-stations.mjs](file:///Users/kundanprasad/code/rfm/scripts/fetch-indian-stations.mjs). You can modify the `KNOWN_CITIES` list in that file to improve automatic city detection if needed.
