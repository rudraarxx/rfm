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
            className="fixed bottom-6 left-6 right-6 h-20 glass-brass rounded-[2rem] flex items-center px-6 gap-4 cursor-pointer z-40 lg:max-w-md lg:left-1/2 lg:-translate-x-1/2 shadow-2xl border-brass/10"
          >
            <motion.div 
              style={{ willChange: "transform" }}
              className="w-12 h-12 rounded-xl overflow-hidden bg-mahogany flex-shrink-0 border border-brass/10"
            >
              {currentStation.favicon ? (
                <img src={currentStation.favicon} alt={currentStation.name} className="w-full h-full object-cover" />
              ) : (
                <div className="w-full h-full flex items-center justify-center bg-white/5">
                  <ListMusic className="w-6 h-6 text-brass/20" />
                </div>
              )}
            </motion.div>

            <div className="flex-1 min-w-0">
              <motion.h4 className="text-base font-primary leading-none text-white truncate">
                {currentStation.name}
              </motion.h4>
              <div className="flex items-center gap-2 mt-1">
                <Visualizer isPlaying={isPlaying} />
                <p className="text-[10px] text-brass/60 font-bold uppercase tracking-[0.2em] leading-none">Live Pulse</p>
              </div>
            </div>

            <button
              onClick={(e) => {
                e.stopPropagation();
                togglePlay();
              }}
              className="w-12 h-12 flex items-center justify-center rounded-full glass-brass border-brass/10 hover:bg-brass/10 transition-colors"
            >
              {isPlaying ? <Pause className="w-5 h-5 fill-brass text-brass" /> : <Play className="w-5 h-5 fill-brass text-brass ml-1" />}
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
            transition={{ type: "spring", damping: 30, stiffness: 300, mass: 0.8 }}
            style={{ willChange: "transform", transform: "translateZ(0)" }}
            className="fixed inset-0 h-[100dvh] bg-black z-50 flex flex-col p-6 md:p-12 overflow-hidden"
          >
            {/* Grab Handle */}
            <button
              onClick={() => setIsExpanded(false)}
              className="absolute top-4 left-1/2 -translate-x-1/2 w-12 h-1.5 bg-white/10 rounded-full hover:bg-white/20 transition-colors"
            />
            
            <div className="flex justify-between items-center mt-6 flex-shrink-0">
              <button onClick={() => setIsExpanded(false)} className="text-white/40 hover:text-white transition-colors">
                <ChevronDown className="w-8 h-8" strokeWidth={1} />
              </button>
              <div className="text-center">
                <p className="text-[10px] font-bold uppercase tracking-[0.4em] text-brass">Analog Player</p>
              </div>
              <button className="text-white/40 hover:text-white transition-colors">
                <Share2 className="w-6 h-6" strokeWidth={1} />
              </button>
            </div>

            <div className="flex-1 min-h-0 flex flex-col items-center justify-between py-4 max-w-lg mx-auto w-full gap-4">
              {/* Responsive Artwork */}
              <motion.div 
                layoutId={`image-${currentStation.changeuuid}`}
                className="w-full max-w-[320px] max-h-[40vh] aspect-[4/5] rounded-[2.5rem] overflow-hidden shadow-[0_48px_96px_-32px_rgba(212,175,55,0.15)] bg-mahogany border border-brass/10 border-t-brass/20 flex-shrink"
              >
                {currentStation.favicon ? (
                  <img src={currentStation.favicon} alt={currentStation.name} className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <ListMusic className="w-24 h-24 text-brass/10" />
                  </div>
                )}
              </motion.div>

              <div className="w-full text-center space-y-2 flex-shrink-0">
                <div className="flex items-center justify-center gap-2">
                  <div className={cn(
                    "w-1.5 h-1.5 rounded-full",
                    isPlaying ? "bg-amber animate-pulse shadow-[0_0_12px_rgba(255,176,59,0.5)]" : "bg-white/10"
                  )} />
                  <span className={cn(
                    "text-[9px] font-bold uppercase tracking-[0.3em]",
                    isPlaying ? "text-amber" : "text-white/20"
                  )}>Broadcasting</span>
                </div>
                
                <motion.h2 
                  layoutId={`name-${currentStation.changeuuid}`} 
                  className="text-4xl md:text-5xl font-primary text-white tracking-tight leading-tight"
                >
                  {currentStation.name}
                </motion.h2>
                
                <p className="text-sm text-white/40 font-medium font-sans">
                  {currentStation.tags ? currentStation.tags.split(',')[0] : "Maharashtra"} • Nagpur
                </p>
              </div>

              {/* Controls */}
              <div className="w-full space-y-8 flex-shrink-0">
                <div className="flex items-center justify-center gap-12">
                  <button className="text-white/20 hover:text-white transition-all">
                    <ListMusic className="w-6 h-6" strokeWidth={1} />
                  </button>
                  <motion.button
                    whileHover={{ scale: 1.1 }}
                    whileTap={{ scale: 0.9 }}
                    onClick={togglePlay}
                    className="w-20 h-20 flex items-center justify-center rounded-full bg-brass text-black shadow-[0_0_40px_rgba(212,175,55,0.2)] transition-all"
                  >
                    {isPlaying ? <Pause className="w-8 h-8 fill-black" /> : <Play className="w-8 h-8 fill-black ml-1" />}
                  </motion.button>
                  <button className="text-white/20 hover:text-white transition-all">
                    <Share2 className="w-6 h-6" strokeWidth={1} />
                  </button>
                </div>

                <div className="space-y-4">
                  <div className="flex items-center gap-4 px-2">
                    <Volume2 className="w-4 h-4 text-brass/40 flex-shrink-0" />
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
