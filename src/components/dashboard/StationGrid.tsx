"use client";

import { motion } from "framer-motion";
import { Station } from "@/store/useRadioStore";
import { Play, ListMusic, ArrowRight } from "lucide-react";
import { useRadioStore } from "@/store/useRadioStore";

interface StationCardProps {
  station: Station;
}

function StationCard({ station }: StationCardProps) {
  const { setStation, currentStation, isPlaying } = useRadioStore();
  const isActive = currentStation?.changeuuid === station.changeuuid;

  return (
    <motion.div
      whileHover={{ y: -5 }}
      whileTap={{ scale: 0.98 }}
      onClick={() => setStation(station)}
      className="flex-shrink-0 w-40 space-y-3 cursor-pointer group"
    >
      <div className="relative aspect-square rounded-2xl overflow-hidden glass border-white/5 group-hover:border-white/20 transition-all">
        {station.favicon ? (
          <img src={station.favicon} alt={station.name} className="w-full h-full object-cover" />
        ) : (
          <div className="w-full h-full flex items-center justify-center bg-white/5">
            <ListMusic className="w-10 h-10 text-white/10" />
          </div>
        )}
        
        <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
          <div className="w-12 h-12 rounded-full glass flex items-center justify-center">
            {isActive && isPlaying ? (
              <div className="flex gap-1 items-end h-4">
                {[1, 2, 3].map(i => (
                  <motion.div
                    key={i}
                    animate={{ height: ["4px", "16px", "8px"] }}
                    transition={{ repeat: Infinity, duration: 0.6, delay: i * 0.1 }}
                    className="w-1 bg-white rounded-full"
                  />
                ))}
              </div>
            ) : (
              <Play className="w-6 h-6 fill-white text-white ml-1" />
            )}
          </div>
        </div>
      </div>
      <div className="space-y-0.5 px-1">
        <h4 className="text-sm font-semibold truncate text-white/90 group-hover:text-white transition-colors uppercase tracking-tight">
          {station.name}
        </h4>
        <p className="text-[10px] font-bold text-white/40 uppercase tracking-widest truncate">
          {station.tags ? station.tags.split(',')[0] : "Maharashtra"}
        </p>
      </div>
    </motion.div>
  );
}

export function StationGrid({ stations, title }: { stations: Station[], title: string }) {
  return (
    <section className="space-y-6">
      <div className="flex items-center justify-between px-6">
        <h2 className="text-2xl font-bold tracking-tight text-white flex items-center gap-3">
          {title}
          <span className="text-[10px] bg-red-500 text-white px-2 py-0.5 rounded-full font-black uppercase tracking-widest animate-pulse">Live</span>
        </h2>
        <button className="text-sm font-bold text-white/40 hover:text-white transition-colors flex items-center gap-1 group">
          See All <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
        </button>
      </div>
      <div className="flex gap-4 overflow-x-auto pb-8 px-6 no-scrollbar snap-x">
        {stations.map((station) => (
          <div key={station.changeuuid} className="snap-start">
            <StationCard station={station} />
          </div>
        ))}
      </div>
    </section>
  );
}
