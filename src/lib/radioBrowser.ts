import { Station } from "@/types/radio";

const MIRRORS = [
  "https://de1.api.radio-browser.info/json",
  "https://at1.api.radio-browser.info/json",
  "https://nl1.api.radio-browser.info/json",
];

export async function fetchWithMirror(endpoint: string): Promise<any> {
  let lastError: Error | null = null;

  for (const mirror of MIRRORS) {
    try {
      const response = await fetch(`${mirror}${endpoint}`, {
        headers: {
          "User-Agent": "RFMWeb/1.0",
        },
        next: { revalidate: 3600 }, // Cache for 1 hour
      });
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
      return await response.json();
    } catch (e) {
      lastError = e as Error;
      continue;
    }
  }
  throw lastError || new Error("All mirrors failed");
}

export const radioBrowserService = {
  async getIndianStations(state?: string, city?: string): Promise<Station[]> {
    let endpoint;
    if (city) {
      // Relaxing state filter for city-specific searches as many stations have empty state fields in the DB.
      // Searching by 'name' within 'countrycode=IN' is most reliable for Indian cities.
      endpoint = `/stations/search?countrycode=IN&name=${encodeURIComponent(city)}&order=votes&reverse=true`;
    } else if (state) {
      endpoint = `/stations/bycountry/india?state=${encodeURIComponent(state)}`;
    } else {
      endpoint = `/stations/bycountry/india`;
    }
    
    const data = await fetchWithMirror(endpoint);
    return data.map((item: any) => ({
      changeuuid: item.stationuuid || item.changeuuid,
      name: item.name,
      url: item.url,
      url_resolved: item.url_resolved,
      homepage: item.homepage,
      favicon: item.favicon,
      tags: item.tags,
      country: item.country,
      state: item.state,
      votes: item.votes,
    }));
  },

  async searchStations(query: string): Promise<Station[]> {
    const endpoint = `/stations/byname/${encodeURIComponent(query)}`;
    const data = await fetchWithMirror(endpoint);
    // Filter for India only as per mobile app feature
    return data
      .filter((item: any) => item.countrycode === 'IN')
      .map((item: any) => ({
        changeuuid: item.stationuuid || item.changeuuid,
        name: item.name,
        url: item.url,
        url_resolved: item.url_resolved,
        homepage: item.homepage,
        favicon: item.favicon,
        tags: item.tags,
        country: item.country,
        state: item.state,
        votes: item.votes,
      }));
  }
};
