"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Play,
  Pause,
  ChevronUp,
  ChevronDown,
  Volume2,
  Share2,
  ListMusic,
} from "lucide-react";
import { toast } from "sonner";
import { useRadioStore } from "@/store/useRadioStore";
import { Visualizer } from "@/components/ui/Visualizer";
import { AudioSpectrum } from "@/components/ui/AudioSpectrum";
import { Slider } from "@/components/ui/slider";
import { Portal } from "@/components/ui/portal";
import { useHasHydrated } from "@/hooks/useHasHydrated";
import { cn } from "@/lib/utils";

export function Player() {
  const hasHydrated = useHasHydrated();
  const [isExpanded, setIsExpanded] = useState(false);
  const [showVolume, setShowVolume] = useState(false);
  const {
    currentStation,
    isPlaying,
    togglePlay,
    volume,
    setVolume,
    nextStation,
    previousStation,
  } = useRadioStore();

  const handleShare = () => {
    navigator.clipboard.writeText(window.location.href);
    toast("Link Copied", {
      description: "Ready to share with friends",
      icon: <div className="p-1 rounded-full bg-brass/20 border border-brass/50"><Share2 className="w-3 h-3 text-brass" /></div>,
      duration: 3000,
    });
  };

  if (!hasHydrated || !currentStation) return null;

  return (
    <>
      {/* Mini Player Bar */}
      <AnimatePresence>
        {!isExpanded && (
          <motion.div
            initial={{ y: 100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 100, opacity: 0 }}
            style={{
              willChange: "transform, opacity",
              transform: "translateZ(0)",
            }}
            onClick={() => setIsExpanded(true)}
            className="fixed bottom-6 left-6 right-6 h-20 glass-brass rounded-full flex items-center px-4 gap-4 cursor-pointer z-40 lg:max-w-md lg:left-1/2 lg:-translate-x-1/2 shadow-2xl border-brass/10"
          >
            <motion.div
              style={{ willChange: "transform" }}
              className="w-12 h-12 rounded-xl overflow-hidden bg-mahogany shrink-0 border border-brass/10"
            >
              {currentStation.favicon ? (
                <img
                  src={currentStation.favicon}
                  alt={currentStation.name}
                  className="w-full h-full object-cover"
                />
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
                <p className="text-[10px] text-brass/60 font-bold uppercase tracking-[0.2em] leading-none">
                  Live Pulse
                </p>
              </div>
            </div>

            <div className="flex items-center gap-1">
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  handleShare();
                }}
                className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-white/5 transition-colors text-white/40 hover:text-white"
              >
                <Share2 className="w-5 h-5" strokeWidth={1.5} />
              </button>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  togglePlay();
                }}
                className="w-12 h-12 flex items-center justify-center rounded-full glass-brass border-brass/10 hover:bg-brass/10 transition-colors"
              >
                {isPlaying ? (
                  <Pause className="w-5 h-5 fill-brass text-brass" />
                ) : (
                  <Play className="w-5 h-5 fill-brass text-brass ml-1" />
                )}
              </button>
            </div>
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
            transition={{
              type: "spring",
              damping: 30,
              stiffness: 300,
              mass: 0.8,
            }}
            style={{ willChange: "transform", transform: "translateZ(0)" }}
            className="fixed inset-0 h-dvh bg-black z-50 flex flex-col p-6 md:p-12 overflow-hidden"
          >
            {/* Grab Handle */}
            <button
              onClick={() => setIsExpanded(false)}
              className="absolute top-4 left-1/2 -translate-x-1/2 w-12 h-1.5 bg-white/10 rounded-full hover:bg-white/20 transition-colors"
            />

            <div className="flex justify-between items-center mt-6 shrink-0">
              <button
                onClick={() => setIsExpanded(false)}
                className="text-white/40 hover:text-white transition-colors"
              >
                <ChevronDown className="w-8 h-8" strokeWidth={1} />
              </button>
              <div className="text-center">
                <p className="text-[10px] font-bold uppercase tracking-[0.4em] text-brass">
                  Analog Player
                </p>
              </div>
              <button 
                onClick={handleShare}
                className="text-white/40 hover:text-white transition-colors p-2"
              >
                <Share2 className="w-6 h-6" strokeWidth={1} />
              </button>
            </div>

            <div className="flex-1 min-h-0 flex flex-col items-center justify-between py-4 max-w-lg mx-auto w-full gap-4">
              {/* Responsive Artwork */}
              <motion.div
                layoutId={`image-${currentStation.changeuuid}`}
                className="w-full max-w-[320px] max-h-[40vh] aspect-4/5 rounded-[2.5rem] overflow-hidden shadow-[0_48px_96px_-32px_rgba(212,175,55,0.15)] bg-mahogany border border-brass/10 border-t-brass/20 shrink"
              >
                {currentStation.favicon ? (
                  <img
                    src={currentStation.favicon}
                    alt={currentStation.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <ListMusic className="w-24 h-24 text-brass/10" />
                  </div>
                )}
              </motion.div>

              <div className="w-full text-center space-y-2 shrink-0">
                <div className="flex items-center justify-center gap-2">
                  <div
                    className={cn(
                      "w-1.5 h-1.5 rounded-full",
                      isPlaying
                        ? "bg-amber animate-pulse shadow-[0_0_12px_rgba(255,176,59,0.5)]"
                        : "bg-white/10",
                    )}
                  />
                  <span
                    className={cn(
                      "text-[9px] font-bold uppercase tracking-[0.3em]",
                      isPlaying ? "text-amber" : "text-white/20",
                    )}
                  >
                    Broadcasting
                  </span>
                </div>

                <motion.h2
                  layoutId={`name-${currentStation.changeuuid}`}
                  className="text-4xl md:text-5xl font-primary text-white tracking-tight leading-tight"
                >
                  {currentStation.name}
                </motion.h2>

                <p className="text-sm text-white/40 font-medium font-sans">
                  {currentStation.tags
                    ? currentStation.tags.split(",")[0]
                    : "Maharashtra"}{" "}
                  • Nagpur
                </p>
              </div>

              {/* Controls */}
              <div className="w-full space-y-4 shrink-0">
                <div className="flex items-center justify-center">
                  <div className="relative flex items-center justify-center w-full max-w-[400px]">
                    <AudioSpectrum
                      width={400}
                      height={100}
                      className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 pointer-events-none"
                    />
                    <motion.button
                      whileHover={{ scale: 1.1 }}
                      whileTap={{ scale: 0.9 }}
                      onClick={togglePlay}
                      className="w-24 h-24 flex items-center justify-center rounded-full glass-brass backdrop-blur-3xl border border-brass/20 text-brass shadow-[0_0_50px_rgba(212,175,55,0.15)] transition-all z-10 group"
                    >
                      {isPlaying ? (
                        <Pause className="w-10 h-10 fill-brass group-hover:scale-110 transition-transform" />
                      ) : (
                        <Play className="w-10 h-10 fill-brass ml-1 group-hover:scale-110 transition-transform" />
                      )}
                    </motion.button>
                  </div>
                </div>

                <div className="pt-1">
                  <div className="flex items-center justify-between px-8 py-0 glass-brass rounded-full border border-brass/10 max-w-sm mx-auto">
                    <div className="flex-1">
                      <button
                        onClick={previousStation}
                        className="text-[9px] font-bold uppercase tracking-[0.4em] text-white/20 hover:text-brass transition-all py-3 w-full text-left"
                      >
                        Prev
                      </button>
                    </div>

                    {/* Volume Trigger Button (Center) */}
                    <div className="shrink-0">
                      <button
                        onClick={() => setShowVolume((v) => !v)}
                        className={cn(
                          "w-10 h-10 flex items-center justify-center transition-all hover:scale-110",
                          showVolume
                            ? "text-brass scale-110"
                            : "text-brass/30 hover:text-brass",
                        )}
                      >
                        <Volume2
                          className={cn(
                            "w-4 h-4 transition-transform",
                            showVolume && "scale-110",
                          )}
                          strokeWidth={1.5}
                        />
                      </button>
                    </div>

                    {/* Volume Overlay — Fixed elegant floating bar using Portal for perfect Z-index */}
                    <AnimatePresence>
                      {showVolume && (
                        <Portal>
                          {/* Backdrop to close on outside click */}
                          <motion.div
                            key="volume-backdrop"
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            onClick={() => setShowVolume(false)}
                            className="fixed inset-0 bg-black/40 backdrop-blur-sm"
                            style={{ zIndex: 1000 }}
                          />

                          {/* Volume Panel */}
                          <motion.div
                            key="volume-panel"
                            initial={{ opacity: 0, y: 40, scale: 0.95 }}
                            animate={{ opacity: 1, y: 0, scale: 1 }}
                            exit={{ opacity: 0, y: 40, scale: 0.95 }}
                            transition={{
                              type: "spring",
                              damping: 25,
                              stiffness: 400,
                            }}
                            className="fixed left-1/2 -translate-x-1/2 bottom-40 w-full max-w-[360px] rounded-[2.5rem] border border-brass/30 px-8 py-7 shadow-[0_30px_100px_rgba(0,0,0,0.8)]"
                            style={{
                              background:
                                "linear-gradient(180deg, rgba(25, 20, 15, 0.95) 0%, rgba(10, 8, 5, 0.98) 100%)",
                              backdropFilter: "blur(40px) saturate(200%)",
                              zIndex: 1001,
                            }}
                          >
                            <div className="space-y-6">
                              <div className="flex justify-between items-end">
                                <div className="space-y-1">
                                  <h3 className="text-[10px] font-bold uppercase tracking-[0.4em] text-brass">
                                    Master Gain
                                  </h3>
                                  <p className="text-[8px] font-medium text-white/30 uppercase tracking-[0.2em]">
                                    Lossless Audio Engine
                                  </p>
                                </div>
                                <span className="text-2xl font-primary text-brass tabular-nums">
                                  {volume}
                                  <span className="text-[10px] ml-1 opacity-50">
                                    %
                                  </span>
                                </span>
                              </div>

                              <div className="relative pt-2">
                                <Slider
                                  value={[volume]}
                                  onValueChange={(vals) =>
                                    setVolume(
                                      Array.isArray(vals) ? vals[0] : vals,
                                    )
                                  }
                                  max={100}
                                  step={1}
                                  className="w-full h-2"
                                />
                              </div>

                              <div className="flex justify-center">
                                <button
                                  onClick={() => setShowVolume(false)}
                                  className="text-[9px] font-bold uppercase tracking-[0.4em] text-white/20 hover:text-white transition-all"
                                >
                                  Close Control
                                </button>
                              </div>
                            </div>
                          </motion.div>
                        </Portal>
                      )}
                    </AnimatePresence>

                    <div className="flex-1">
                      <button
                        onClick={nextStation}
                        className="text-[9px] font-bold uppercase tracking-[0.4em] text-white/20 hover:text-brass transition-all py-3 w-full text-right"
                      >
                        Next
                      </button>
                    </div>
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
