"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Play, Pause, ChevronUp, ChevronDown, Volume2, Share2, ListMusic } from "lucide-react";
import { useRadioStore } from "@/store/useRadioStore";
import { Visualizer } from "@/components/ui/Visualizer";
import { Slider } from "@/components/ui/slider";
import { cn } from "@/lib/utils";

export function Player() {
  const [isExpanded, setIsExpanded] = useState(false);
  const { currentStation, isPlaying, togglePlay, volume, setVolume } = useRadioStore();

  if (!currentStation) return null;

  return (
    <>
      {/* Mini Player Bar */}
      <AnimatePresence>
        {!isExpanded && (
          <motion.div
            initial={{ y: 100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 100, opacity: 0 }}
            style={{ willChange: "transform, opacity", transform: "translateZ(0)" }}
            onClick={() => setIsExpanded(true)}
            className="fixed bottom-4 left-4 right-4 h-16 glass rounded-2xl flex items-center px-4 gap-3 cursor-pointer z-40 lg:max-w-md lg:left-1/2 lg:-translate-x-1/2"
          >
            <motion.div 
              layoutId="station-image"
              style={{ willChange: "transform" }}
              className="w-10 h-10 rounded-lg overflow-hidden bg-white/10 flex-shrink-0"
            >
              {currentStation.favicon ? (
                <img src={currentStation.favicon} alt={currentStation.name} className="w-full h-full object-cover" />
              ) : (
                <div className="w-full h-full flex items-center justify-center bg-white/5">
                  <ListMusic className="w-5 h-5 text-white/40" />
                </div>
              )}
            </motion.div>

            <div className="flex-1 min-w-0">
              <motion.h4 layoutId="station-name" className="text-sm font-semibold truncate text-white">
                {currentStation.name}
              </motion.h4>
              <div className="flex items-center gap-2">
                <Visualizer isPlaying={isPlaying} />
                <p className="text-[10px] text-white/40 font-medium uppercase tracking-wider">Nagpur Pulse</p>
              </div>
            </div>

            <button
              onClick={(e) => {
                e.stopPropagation();
                togglePlay();
              }}
              className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-white/10 transition-colors"
            >
              {isPlaying ? <Pause className="w-5 h-5 fill-white text-white" /> : <Play className="w-5 h-5 fill-white text-white ml-1" />}
            </button>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Expanded Player */}
      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ y: "100%" }}
            animate={{ y: 0 }}
            exit={{ y: "100%" }}
            transition={{ type: "spring", damping: 25, stiffness: 200 }}
            style={{ willChange: "transform", transform: "translateZ(0)" }}
            className="fixed inset-0 bg-black z-50 flex flex-col p-8"
          >
            <button
              onClick={() => setIsExpanded(false)}
              className="absolute top-6 left-1/2 -translate-x-1/2 w-10 h-1.5 bg-white/20 rounded-full"
            />
            
            <div className="flex justify-between items-center mt-8">
              <button onClick={() => setIsExpanded(false)} className="text-white/60 hover:text-white">
                <ChevronDown className="w-6 h-6" strokeWidth={1.5} />
              </button>
              <button className="text-white/60 hover:text-white">
                <Share2 className="w-5 h-5" strokeWidth={1.5} />
              </button>
            </div>

            <div className="flex-1 flex flex-col items-center justify-center gap-12 max-w-lg mx-auto w-full">
              {/* Massive Drop Shadow Artwork */}
              <motion.div 
                layoutId="station-image"
                className="w-full aspect-square max-w-[320px] rounded-3xl overflow-hidden shadow-[0_32px_64px_-16px_rgba(255,255,255,0.15)] bg-white/5 border border-white/10"
              >
                {currentStation.favicon ? (
                  <img src={currentStation.favicon} alt={currentStation.name} className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center bg-white/5">
                    <ListMusic className="w-20 h-20 text-white/20" />
                  </div>
                )}
              </motion.div>

              <div className="w-full text-center space-y-2">
                <div className="flex items-center justify-center gap-2 mb-4">
                  <div className={cn(
                    "w-2 h-2 rounded-full",
                    isPlaying ? "bg-red-500 animate-pulse shadow-[0_0_8px_rgba(239,68,68,0.5)]" : "bg-white/20"
                  )} />
                  <span className={cn(
                    "text-[10px] font-bold uppercase tracking-[0.2em]",
                    isPlaying ? "text-red-500" : "text-white/40"
                  )}>Live</span>
                </div>
                <motion.h2 layoutId="station-name" className="text-3xl font-bold text-white tracking-tight">
                  {currentStation.name}
                </motion.h2>
                <p className="text-base text-white/40 font-medium">
                  {currentStation.tags ? currentStation.tags.split(',')[0] : "Maharashtra"} • Nagpur
                </p>
              </div>

              {/* Controls */}
              <div className="w-full space-y-8">
                <div className="flex items-center justify-center gap-12">
                  <button className="text-white/40 hover:text-white transition-all disabled:opacity-20" disabled>
                    <ListMusic className="w-6 h-6" strokeWidth={1.5} />
                  </button>
                  <button
                    onClick={togglePlay}
                    className="w-20 h-20 flex items-center justify-center rounded-full bg-white text-black hover:scale-105 active:scale-95 transition-all"
                  >
                    {isPlaying ? <Pause className="w-8 h-8 fill-black" /> : <Play className="w-8 h-8 fill-black ml-1" />}
                  </button>
                  <button className="text-white/40 hover:text-white transition-all">
                    <Volume2 className="w-6 h-6" strokeWidth={1.5} />
                  </button>
                </div>

                <div className="space-y-4">
                  <div className="flex items-center gap-4">
                    <Volume2 className="w-4 h-4 text-white/40" />
                    <Slider
                      value={[volume]}
                      onValueChange={(vals) => setVolume(Array.isArray(vals) ? vals[0] : vals)}
                      max={100}
                      step={1}
                      className="w-full"
                    />
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
