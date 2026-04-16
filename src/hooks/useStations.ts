import { useState, useEffect, useCallback } from "react";
import { Station } from "@/types/radio";
import { radioBrowserService } from "@/lib/radioBrowser";
import { getStationsForCity, getStationsForState, getAllStations, processStationData, mergeRemoteStations, updateStationIndex } from "@/data/stationDb";

export function useStations() {
  const [stations, setStations] = useState<Station[]>([]);
  const [syncedStations, setSyncedStations] = useState<Station[]>(getAllStations());
  const [loading, setLoading] = useState(true);
  const [syncing, setSyncing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [query, setQuery] = useState("");
  const [selectedState, setSelectedState] = useState<string | null>(null);
  const [selectedCity, setSelectedCity] = useState<string | null>(null);

  // 1. Sync station index from API
  useEffect(() => {
    async function syncIndex() {
      setSyncing(true);
      try {
        const res = await fetch('/api/index');
        if (res.ok) {
          const indexData = await res.json();
          updateStationIndex(indexData);
          console.log("✅ Synced station index from MongoDB");
        }
      } catch (err) {
        console.warn("Failed to sync station index:", err);
      } finally {
        setSyncing(false);
      }
    }
    syncIndex();
  }, []);

  // Reset city when state changes
  useEffect(() => {
    setSelectedCity(null);
  }, [selectedState]);

  const loadStations = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      if (query.trim()) {
        const qLower = query.toLowerCase();
        
        // 1. Fetch from our MongoDB
        let dbResults: Station[] = [];
        try {
           const dbRes = await fetch(`/api/stations?search=${encodeURIComponent(query)}`);
           if (dbRes.ok) {
             const dbData = await dbRes.json();
             dbResults = dbData.stations || [];
           }
        } catch (err) {
           console.warn("DB search failed", err);
        }

        // 2. Fetch from RadioBrowser API
        let apiResults: Station[] = [];
        try {
          apiResults = await radioBrowserService.searchStations(query);
        } catch (apiError) {
          console.warn("API search failed, falling back to db only", apiError);
        }

        const combined = [...dbResults];
        apiResults.forEach(res => {
          const isDuplicate = combined.some(c => {
            const n1 = (c.name || '').toLowerCase().replace(/[^a-z0-9]/g, '');
            const n2 = (res.name || '').toLowerCase().replace(/[^a-z0-9]/g, '');
            return n1.includes(n2) || n2.includes(n1) || c.url === res.url;
          });
          if (!isDuplicate) combined.push(res);
        });
        
        setStations(processStationData(combined));
      } else {
        // Discovery: Fetch from API based on selected state/city
        let url = '/api/stations';
        if (selectedState && selectedCity) {
          url += `?state=${encodeURIComponent(selectedState)}&city=${encodeURIComponent(selectedCity)}`;
        } else if (selectedState) {
          url += `?state=${encodeURIComponent(selectedState)}`;
        }
        
        const res = await fetch(url);
        if (res.ok) {
          const data = await res.json();
          const processed = processStationData(data.stations || []);
          setStations(processed);
        } else {
          // Fallback to local default database
          const results = getAllStations();
          setStations(results);
        }
      }
    } catch (e) {
      console.error("Failed to load stations:", e);
      setError("Failed to reach radio servers. Showing curated stations.");
      setStations(getAllStations());
    } finally {
      setLoading(false);
    }
  }, [query, selectedState, selectedCity]);

  useEffect(() => {
    const timer = setTimeout(() => {
      loadStations();
    }, query ? 500 : 0);
    return () => clearTimeout(timer);
  }, [loadStations, query]);

  return {
    stations,
    loading,
    syncing,
    error,
    query,
    setQuery,
    selectedState,
    setSelectedState,
    selectedCity,
    setSelectedCity,
    refresh: loadStations
  };
}
