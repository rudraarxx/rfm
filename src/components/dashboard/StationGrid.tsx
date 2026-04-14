"use client";

import { motion } from "framer-motion";
import { Station } from "@/types/radio";
import { Play, ListMusic, ArrowRight } from "lucide-react";
import { useRadioStore } from "@/store/useRadioStore";
import { useHasHydrated } from "@/hooks/useHasHydrated";

interface StationCardProps {
  station: Station;
}

export function StationGrid({
  stations,
  title,
}: {
  stations: Station[];
  title: string;
}) {
  return (
    <section className="space-y-12">
      <div className="flex flex-col items-center text-center px-6 space-y-2">
        <h2 className="text-3xl font-primary tracking-tight text-white flex items-center gap-3">
          {title}
        </h2>
        <p className="text-[10px] text-brass font-bold uppercase tracking-[0.3em]">
          Analog Curations
        </p>
      </div>

      <div className="relative group/scroll">
        <div 
          className="flex flex-row gap-8 overflow-x-auto px-10 pb-4 no-scrollbar snap-x snap-mandatory scroll-smooth"
          style={{
            WebkitMaskImage: "linear-gradient(to right, transparent, black 40px, black calc(100% - 40px), transparent)"
          }}
        >
          {stations.map((station) => (
            <div key={station.changeuuid} className="flex-shrink-0 snap-center">
              <StationCard station={station} />
            </div>
          ))}
          {/* Spacer to allow reaching the end cleanly */}
          <div className="flex-shrink-0 w-2" />
        </div>
      </div>

      <div className="flex justify-center px-6">
        <button className="text-sm font-bold text-white/20 hover:text-white transition-colors flex items-center gap-2 group border-b border-transparent hover:border-white/10 pb-1">
          Explore Archive{" "}
          <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
        </button>
      </div>
    </section>
  );
}

function StationCard({ station }: StationCardProps) {
  const hasHydrated = useHasHydrated();
  const setStation = useRadioStore((state) => state.setStation);
  const isPlaying = useRadioStore((state) => state.isPlaying);
  const activeId = useRadioStore((state) => state.currentStation?.changeuuid);

  const isPlayingAndActive = 
    hasHydrated && 
    isPlaying && 
    activeId === station.changeuuid;

  return (
    <motion.div
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      onClick={() => setStation(station)}
      className="w-full max-w-[280px] space-y-6 cursor-pointer group flex flex-col items-center"
    >
      <div className="relative w-full aspect-4/5 rounded-[2rem] overflow-hidden glass-brass border-brass/10 group-hover:border-brass/30 transition-all shadow-2xl">
        <motion.div
          layoutId={`image-${station.changeuuid}`}
          className="w-full h-full"
        >
          {station.favicon ? (
            <img
              src={station.favicon}
              alt={station.name}
              className="w-full h-full object-cover grayscale-[0.2] group-hover:grayscale-0 transition-all duration-700"
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center bg-mahogany">
              <ListMusic className="w-12 h-12 text-brass/20" />
            </div>
          )}
        </motion.div>

        <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent opacity-60" />

        <div className="absolute bottom-6 left-1/2 -translate-x-1/2">
          <div className="w-14 h-14 rounded-full glass-brass backdrop-blur-xl flex items-center justify-center border-brass/20 shadow-xl group-hover:scale-110 transition-transform">
            {isPlayingAndActive ? (
              <div className="flex gap-1.5 items-end h-5">
                {[1, 2, 3].map((i) => (
                  <motion.div
                    key={i}
                    animate={{ height: ["6px", "20px", "10px"] }}
                    transition={{
                      repeat: Infinity,
                      duration: 0.6,
                      delay: i * 0.1,
                    }}
                    className="w-1 bg-brass rounded-full"
                  />
                ))}
              </div>
            ) : (
              <Play className="w-6 h-6 fill-brass text-brass ml-1" />
            )}
          </div>
        </div>
      </div>

      <div className="space-y-2 text-center">
        <motion.h4
          layoutId={`name-${station.changeuuid}`}
          className="text-2xl font-primary text-white tracking-tight group-hover:text-brass transition-colors"
        >
          {station.name}
        </motion.h4>
        <p className="text-[10px] font-bold text-white/20 uppercase tracking-[0.4em]">
          {station.tags ? station.tags.split(",")[0] : "Retro Soul"}
        </p>
      </div>
    </motion.div>
  );
}
