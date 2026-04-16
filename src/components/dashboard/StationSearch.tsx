"use client";

import { motion, AnimatePresence } from "framer-motion";
import { Search, X, MapPin } from "lucide-react";

import { getAvailableStates, getCitiesForState } from "@/data/stationDb";

interface StationSearchProps {
  query: string;
  onQueryChange: (query: string) => void;
  selectedState: string | null;
  onStateChange: (state: string | null) => void;
  selectedCity: string | null;
  onCityChange: (city: string | null) => void;
}

export function StationSearch({
  query,
  onQueryChange,
  selectedState,
  onStateChange,
  selectedCity,
  onCityChange,
}: StationSearchProps) {
  const availableStates = getAvailableStates().sort();
  const INDIAN_STATES = [{ value: "", label: "All India" }, ...availableStates.map(state => ({ value: state, label: state }))];
  const cities = selectedState ? getCitiesForState(selectedState).sort() : [];

  return (
    <div className="w-full max-w-lg mx-auto px-6 space-y-8">
      {/* Search Input */}
      <div className="relative group">
        <div className="absolute inset-y-0 left-6 flex items-center pointer-events-none">
          <Search className="w-4 h-4 text-brass/40 group-focus-within:text-brass transition-colors" />
        </div>
        <input
          type="text"
          value={query}
          onChange={(e) => onQueryChange(e.target.value)}
          placeholder="Search Indian Stations..."
          className="w-full h-14 pl-14 pr-14 rounded-2xl glass-brass border border-brass/5 focus:border-brass/20 text-foreground placeholder:text-foreground/20 text-sm font-medium focus:outline-none transition-all shadow-xl"
        />
        {query && (
          <button
            onClick={() => onQueryChange("")}
            className="absolute inset-y-0 right-6 flex items-center text-brass/40 hover:text-brass transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        )}
      </div>

      <div className="space-y-6">
        {/* State Filters as minimalist horizontal scroll */}
        <div 
          className="flex gap-3 overflow-x-auto pb-2 no-scrollbar -mx-4 px-4 snap-x"
          style={{
            WebkitMaskImage: "linear-gradient(to right, transparent, black 20px, black calc(100% - 20px), transparent)"
          }}
        >
          {INDIAN_STATES.map((state) => (
            <motion.button
              key={state.value}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => onStateChange(state.value || null)}
              className={`
                snap-start px-6 py-2.5 rounded-full text-[10px] font-bold uppercase tracking-[0.2em] whitespace-nowrap transition-all border
                ${(selectedState || "") === state.value 
                  ? "bg-brass text-mahogany border-brass shadow-[0_0_15px_rgba(212,175,55,0.3)]" 
                  : "glass-brass text-brass/60 border-brass/10 hover:border-brass/30"}
              `}
            >
              {state.label}
            </motion.button>
          ))}
        </div>

        {/* City Filters - Only show if state has cities */}
        <AnimatePresence mode="wait">
          {selectedState && cities.length > 0 && (
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="flex flex-col gap-4"
            >
              <div className="flex items-center gap-2 px-1">
                <MapPin className="w-3 h-3 text-brass/40" />
                <span className="text-[9px] font-bold text-brass/40 uppercase tracking-[0.3em]">Select City</span>
              </div>
              <div 
                className="flex gap-2 overflow-x-auto pb-4 no-scrollbar -mx-4 px-4 snap-x"
                style={{
                  WebkitMaskImage: "linear-gradient(to right, transparent, black 20px, black calc(100% - 20px), transparent)"
                }}
              >
                {cities.map((city) => (
                  <motion.button
                    key={city}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    onClick={() => onCityChange(selectedCity === city ? null : city)}
                    className={`
                      snap-start px-5 py-2 rounded-xl text-[9px] font-bold uppercase tracking-[0.1em] whitespace-nowrap transition-all border
                      ${selectedCity === city 
                        ? "bg-brass/20 text-brass border-brass/30 shadow-lg" 
                        : "glass-brass text-brass/40 border-brass/5 hover:border-brass/20"}
                    `}
                  >
                    {city}
                  </motion.button>
                ))}
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
