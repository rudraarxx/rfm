"use client";

import { motion } from "framer-motion";
import { X, Moon, Sun, Monitor, Palette, Radio } from "lucide-react";
import { useTheme } from "next-themes";
import { cn } from "@/lib/utils";
import { useRadioStore } from "@/store/useRadioStore";

interface SettingsPanelProps {
  onClose: () => void;
}

import { useState, useEffect } from "react";
import { Check } from "lucide-react";

interface SettingsPanelProps {
  onClose: () => void;
}

export function SettingsPanel({ onClose }: SettingsPanelProps) {
  const { theme: currentTheme, setTheme } = useTheme();
  const { visualizerStyle: currentVisualizer, setVisualizerStyle } = useRadioStore();

  // Staging state
  const [pendingTheme, setPendingTheme] = useState(currentTheme);
  const [pendingVisualizer, setPendingVisualizer] = useState(currentVisualizer);
  const [isApplying, setIsApplying] = useState(false);

  // Sync state if it changes outside (e.g. system theme)
  useEffect(() => {
    setPendingTheme(currentTheme);
    setPendingVisualizer(currentVisualizer);
  }, [currentTheme, currentVisualizer]);

  const handleApply = async () => {
    setIsApplying(true);
    
    // Slight delay for tactile feedback
    await new Promise(resolve => setTimeout(resolve, 600));
    
    if (pendingTheme) setTheme(pendingTheme);
    setVisualizerStyle(pendingVisualizer);
    
    setIsApplying(false);
    onClose();
  };

  const hasChanges = pendingTheme !== currentTheme || pendingVisualizer !== currentVisualizer;

  return (
    <motion.div
      initial={{ y: "100%" }}
      animate={{ y: 0 }}
      exit={{ y: "100%" }}
      transition={{ type: "spring", damping: 25, stiffness: 300 }}
      className="fixed inset-x-0 bottom-0 z-[60] bg-background/95 backdrop-blur-2xl rounded-t-[3rem] border-t border-brass/20 p-8 pb-12 shadow-[0_-20px_80px_rgba(0,0,0,0.8)] flex flex-col"
      style={{
        maxHeight: "90vh",
      }}
    >
      {/* Header */}
      <div className="flex justify-between items-center mb-10 shrink-0">
        <h2 className="text-3xl font-primary text-foreground tracking-tight">System Settings</h2>
        <button
          onClick={onClose}
          className="w-10 h-10 flex items-center justify-center rounded-full bg-foreground/5 hover:bg-foreground/10 transition-colors text-foreground/40 hover:text-foreground"
        >
          <X className="w-5 h-5" />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto space-y-12 no-scrollbar pb-24">
        {/* Theme Settings placeholder — now functional */}
        <section className="space-y-4">
          <div className="flex items-center gap-3 text-brass/60">
            <Sun className="w-4 h-4" />
            <h3 className="text-[10px] font-bold uppercase tracking-[0.4em]">Appearance</h3>
          </div>
          <div className="grid grid-cols-3 gap-3">
            {[
              { id: "dark", icon: Moon, label: "Dark" },
              { id: "light", icon: Sun, label: "Light" },
              { id: "system", icon: Monitor, label: "Auto" },
            ].map((t) => (
              <button
                key={t.id}
                onClick={() => setPendingTheme(t.id)}
                className={cn(
                  "flex flex-col items-center gap-3 p-5 rounded-2xl border transition-all duration-300",
                  pendingTheme === t.id 
                    ? "bg-brass/10 border-brass/30 text-brass ring-1 ring-brass/20" 
                    : "bg-foreground/5 border-foreground/5 text-foreground/30 hover:bg-foreground/10"
                )}
              >
                <t.icon className="w-5 h-5" />
                <span className="text-[10px] font-bold uppercase tracking-widest">{t.label}</span>
              </button>
            ))}
          </div>
        </section>

        {/* Visualizer Settings - Functional */}
        <section className="space-y-4">
          <div className="flex items-center gap-3 text-brass/60">
            <Palette className="w-4 h-4" />
            <h3 className="text-[10px] font-bold uppercase tracking-[0.4em]">Visualizer Style</h3>
          </div>
          <div className="space-y-3">
            {[
              { id: "classic", label: "Classic Brass", desc: "Traditional analog gold aesthetic" },
              { id: "colorful", label: "Neon Pulse", desc: "Vibrant Cyan to Pink gradient mapping" },
            ].map((style) => (
              <button
                key={style.id}
                onClick={() => setPendingVisualizer(style.id as "classic" | "colorful")}
                className={cn(
                  "w-full flex items-center justify-between p-5 rounded-2xl border transition-all duration-300 text-left",
                  pendingVisualizer === style.id
                    ? "bg-brass/10 border-brass/30 text-brass ring-1 ring-brass/20"
                    : "bg-foreground/5 border-foreground/5 text-foreground/40 hover:bg-foreground/10"
                )}
              >
                <div>
                  <p className={cn(
                    "text-sm font-semibold tracking-tight",
                    pendingVisualizer === style.id ? "text-brass" : "text-foreground"
                  )}>{style.label}</p>
                  <p className="text-[10px] opacity-60 font-medium font-sans mt-0.5">{style.desc}</p>
                </div>
                {pendingVisualizer === style.id && <div className="w-1.5 h-1.5 rounded-full bg-brass animate-pulse" />}
              </button>
            ))}
          </div>
        </section>

        {/* Info Section */}
        <section className="pt-4 border-t border-foreground/5 pb-8">
          <div className="flex items-start gap-4 p-5 rounded-2xl bg-foreground/5 border border-foreground/5">
            <div className="w-10 h-10 rounded-xl bg-brass/10 flex items-center justify-center text-brass">
              <Radio className="w-5 h-5" />
            </div>
            <div>
              <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-foreground/60">RFM PRO</p>
              <p className="text-xs text-foreground/30 font-medium leading-relaxed mt-1">
                More controls for audio fidelity and custom analog themes coming soon in the next update.
              </p>
            </div>
          </div>
        </section>
      </div>

      {/* Apply Button Container */}
      <div className="absolute bottom-10 left-8 right-8 shrink-0">
        <motion.button
          disabled={!hasChanges || isApplying}
          onClick={handleApply}
          whileHover={{ scale: hasChanges ? 1.02 : 1 }}
          whileTap={{ scale: hasChanges ? 0.98 : 1 }}
          className={cn(
            "w-full py-5 rounded-2xl font-primary text-xl tracking-tight transition-all duration-500 relative overflow-hidden group shadow-2xl",
            hasChanges 
              ? "bg-brass text-mahogany shadow-brass/20" 
              : "bg-foreground/5 text-foreground/20 cursor-not-allowed opacity-50"
          )}
        >
          {isApplying ? (
            <div className="flex items-center justify-center gap-3">
              <div className="w-5 h-5 border-2 border-mahogany/30 border-t-mahogany rounded-full animate-spin" />
              <span>Applying...</span>
            </div>
          ) : (
            <div className="flex items-center justify-center gap-3">
              {hasChanges && <Check className="w-5 h-5" />}
              <span>{hasChanges ? "Apply Pulse Changes" : "No Changes"}</span>
            </div>
          )}
          
          {/* Shine effect */}
          {hasChanges && (
            <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:animate-[shimmer_2s_infinite]" />
          )}
        </motion.button>
      </div>
    </motion.div>
  );
}
