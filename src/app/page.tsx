"use client";

import { DashboardHero } from "@/components/dashboard/DashboardHero";
import { StationGrid } from "@/components/dashboard/StationGrid";
import { StationSearch } from "@/components/dashboard/StationSearch";
import { useStations } from "@/hooks/useStations";
import { motion, AnimatePresence } from "framer-motion";
import { Loader2 } from "lucide-react";

export default function Home() {
  const { 
    stations, 
    loading, 
    error, 
    query, 
    setQuery, 
    selectedState, 
    setSelectedState,
    selectedCity,
    setSelectedCity
  } = useStations();

  return (
    <div className="flex flex-col gap-12 max-w-lg mx-auto overflow-hidden pb-40">
      <DashboardHero />

      <StationSearch 
        query={query}
        onQueryChange={setQuery}
        selectedState={selectedState}
        onStateChange={setSelectedState}
        selectedCity={selectedCity}
        onCityChange={setSelectedCity}
      />

      <div className="space-y-16">
        <AnimatePresence mode="wait">
          {loading ? (
            <motion.div 
              key="loader"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="flex flex-col items-center justify-center py-20 gap-4"
            >
              <Loader2 className="w-8 h-8 text-brass animate-spin" />
              <p className="text-[10px] text-brass font-bold uppercase tracking-[0.3em]">Tuning Signals...</p>
            </motion.div>
          ) : (
            <motion.div
              key="content"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="space-y-16"
            >
              <StationGrid 
                title={query ? "Search Results" : (selectedCity || selectedState || "Indian Stations")} 
                stations={stations} 
              />

              {error && (
                <div className="px-8 text-center">
                  <p className="text-[10px] text-brass/40 font-bold uppercase tracking-[0.2em]">
                    {error}
                  </p>
                </div>
              )}

              <div className="px-8 flex justify-center">
                <div className="relative glass-brass rounded-[2rem] p-12 text-center space-y-4 w-full border-brass/5 overflow-hidden group">
                  <div className="absolute top-4 right-4 bg-brass/10 border border-brass/20 px-3 py-1 rounded-full">
                    <p className="text-[8px] font-bold text-brass uppercase tracking-[0.2em]">Coming Soon</p>
                  </div>
                  <h3 className="text-2xl font-primary text-foreground">The Archive.</h3>
                  <p className="text-[10px] text-foreground/30 font-bold uppercase tracking-[0.3em]">
                    Curating the Soul of Nagpur
                  </p>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}

