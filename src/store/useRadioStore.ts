import { create } from "zustand";
import { persist } from "zustand/middleware";
import { Station } from "@/types/radio";
import { getAllStations } from "@/data/stationDb";

interface RadioState {
  currentStation: Station | null;
  isPlaying: boolean;
  volume: number;
  stations: Station[];
  analyser: AnalyserNode | null;
  visualizerStyle: "classic" | "colorful" | "circular";
  favorites: Station[];
  
  // Actions
  setStation: (station: Station) => void;
  togglePlay: () => void;
  setIsPlaying: (isPlaying: boolean) => void;
  setVolume: (volume: number) => void;
  setStations: (stations: Station[]) => void;
  setAnalyser: (analyser: AnalyserNode | null) => void;
  setVisualizerStyle: (style: "classic" | "colorful" | "circular") => void;
  toggleFavorite: (station: Station) => void;
  nextStation: () => void;
  previousStation: () => void;
  initialize: () => Promise<void>;
}

const API_URL = "/api/stations";
export const useRadioStore = create<RadioState>()(
  persist(
    (set) => ({
      currentStation: null,
      isPlaying: false,
      volume: 80,
      stations: getAllStations(),
      analyser: null,
      visualizerStyle: "classic",
      favorites: [],

      setStation: (station) => set({ currentStation: station, isPlaying: true }),
      togglePlay: () => set((state) => ({ isPlaying: !state.isPlaying })),
      setIsPlaying: (isPlaying) => set({ isPlaying }),
      setVolume: (volume) => set({ volume }),
      setStations: (stations) => set({ stations }),
      setAnalyser: (analyser) => set({ analyser }),
      setVisualizerStyle: (style) => set({ visualizerStyle: style }),
      
      toggleFavorite: (station) => set((state) => {
        const isFav = state.favorites.some(s => s.changeuuid === station.changeuuid);
        const newFavs = isFav 
          ? state.favorites.filter(s => s.changeuuid !== station.changeuuid)
          : [...state.favorites, station];
        return { favorites: newFavs };
      }),
      
      nextStation: () => set((state) => {
        if (state.stations.length === 0) return state;
        const currentId = state.currentStation?.changeuuid;
        const currentIndex = state.stations.findIndex(s => s.changeuuid === currentId);
        
        // If nothing is playing or station not found, play the first one
        if (currentIndex === -1) {
          return { currentStation: state.stations[0], isPlaying: true };
        }
        
        const nextIndex = (currentIndex + 1) % state.stations.length;
        return { currentStation: state.stations[nextIndex], isPlaying: true };
      }),

      previousStation: () => set((state) => {
        if (state.stations.length === 0) return state;
        const currentId = state.currentStation?.changeuuid;
        const currentIndex = state.stations.findIndex(s => s.changeuuid === currentId);
        
        // If nothing is playing or station not found, play the last one
        if (currentIndex === -1) {
          return { currentStation: state.stations[state.stations.length - 1], isPlaying: true };
        }
        
        const prevIndex = (currentIndex - 1 + state.stations.length) % state.stations.length;
        return { currentStation: state.stations[prevIndex], isPlaying: true };
      }),

      initialize: async () => {
        try {
          const response = await fetch(API_URL);
          if (!response.ok) throw new Error("Failed to fetch remote cache");
          
          const data = await response.json();
          if (data && data.stations) {
            const { mergeRemoteStations } = await import("@/data/stationDb");
            const updatedStations = mergeRemoteStations(data.stations);
            set({ stations: updatedStations });
            console.log(`✅ Loaded ${data.stations.length} remote stations`);
          }
        } catch (error) {
          console.error("❌ Error loading remote stations:", error);
        }
      },
    }),
    {
      name: "radio-storage",
      partialize: (state) => ({ 
        currentStation: state.currentStation, 
        volume: state.volume,
        visualizerStyle: state.visualizerStyle,
        favorites: state.favorites
      }),
    }
  )
);
