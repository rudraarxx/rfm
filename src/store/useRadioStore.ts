import { create } from "zustand";
import { persist } from "zustand/middleware";

export interface Station {
  changeuuid: string;
  name: string;
  url: string;
  url_resolved: string;
  homepage: string;
  favicon: string;
  tags: string;
  country: string;
  state: string;
  votes: number;
}

interface RadioState {
  currentStation: Station | null;
  isPlaying: boolean;
  volume: number;
  stations: Station[];
  analyser: AnalyserNode | null;
  
  // Actions
  setStation: (station: Station) => void;
  togglePlay: () => void;
  setIsPlaying: (isPlaying: boolean) => void;
  setVolume: (volume: number) => void;
  setStations: (stations: Station[]) => void;
  setAnalyser: (analyser: AnalyserNode | null) => void;
}

export const useRadioStore = create<RadioState>()(
  persist(
    (set) => ({
      currentStation: null,
      isPlaying: false,
      volume: 80,
      stations: [],
      analyser: null,

      setStation: (station) => set({ currentStation: station, isPlaying: true }),
      togglePlay: () => set((state) => ({ isPlaying: !state.isPlaying })),
      setIsPlaying: (isPlaying) => set({ isPlaying }),
      setVolume: (volume) => set({ volume }),
      setStations: (stations) => set({ stations }),
      setAnalyser: (analyser) => set({ analyser }),
    }),
    {
      name: "radio-storage",
      partialize: (state) => ({ 
        currentStation: state.currentStation, 
        volume: state.volume 
      }),
    }
  )
);
