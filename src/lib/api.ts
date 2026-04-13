import { Station } from "@/store/useRadioStore";

const mirrors = [
  "de1.api.radio-browser.info",
  "at1.api.radio-browser.info",
  "nl1.api.radio-browser.info",
];

export async function fetchStations(state: string = "Maharashtra", tag: string = "nagpur"): Promise<Station[]> {
  // Try mirrors until one works
  for (const mirror of mirrors) {
    try {
      const url = `https://${mirror}/json/stations/search?state=${state}&tag=${tag}&hidebroken=true&order=votes&reverse=true`;
      const response = await fetch(url, {
        headers: {
          "User-Agent": "RFMRadio/1.0",
        },
        next: { revalidate: 3600 } // Cache for 1 hour
      });

      if (!response.ok) continue;

      const data = await response.json();
      return data;
    } catch (error) {
      console.warn(`Failed to fetch from mirror ${mirror}:`, error);
    }
  }

  return [];
}
