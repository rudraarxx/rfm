"use client";

import { motion, AnimatePresence } from "framer-motion";
import { useEffect, useState } from "react";
import { Smartphone, Tablet, Monitor } from "lucide-react";

export function DeviceOptimizer() {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const checkViewport = () => {
      // Show for screens wider than 1024px (standard desktop)
      setIsVisible(window.innerWidth > 1024);
    };

    checkViewport();
    window.addEventListener("resize", checkViewport);
    return () => window.removeEventListener("resize", checkViewport);
  }, []);

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-[100] bg-background/95 backdrop-blur-xl flex items-center justify-center p-8 text-center"
        >
          <div className="max-w-md space-y-8">
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ delay: 0.2 }}
              className="flex justify-center"
            >
              <div className="w-32 h-32 rounded-full glass border-brass/20 flex items-center justify-center p-6 bg-gradient-to-b from-brass/10 to-transparent">
                <img src="/icons/icon.svg" alt="RFM Retro Logo" className="w-full h-full opacity-80" />
              </div>
            </motion.div>

            <div className="space-y-4">
              <h2 className="text-4xl font-primary text-foreground tracking-tight leading-tight">
                Designed for the <span className="text-brass">Analog Hand.</span>
              </h2>
              <p className="text-lg text-foreground/40 font-medium font-sans px-4">
                RFM is optimized for tactile, touch-first interaction. For the ultimate audio experience, please open this on your 
                <span className="text-foreground/60"> iPad, iPhone, or Android device.</span>
              </p>
            </div>

            <div className="flex items-center justify-center gap-8 pt-4">
              <div className="flex flex-col items-center gap-2 text-foreground/20">
                <Smartphone className="w-6 h-6" />
                <span className="text-[10px] font-bold uppercase tracking-widest">Mobile</span>
              </div>
              <div className="w-px h-8 bg-foreground/5" />
              <div className="flex flex-col items-center gap-2 text-brass/40">
                <Tablet className="w-6 h-6" />
                <span className="text-[10px] font-bold uppercase tracking-widest">iPad</span>
              </div>
              <div className="w-px h-8 bg-foreground/5" />
              <div className="flex flex-col items-center gap-2 text-foreground/20">
                <Monitor className="w-8 h-8 opacity-20" />
                <span className="text-[10px] font-bold uppercase tracking-widest">Desktop</span>
              </div>
            </div>

            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setIsVisible(false)}
              className="px-8 py-3 rounded-full border border-foreground/10 hover:border-foreground/20 text-foreground/40 hover:text-foreground transition-all text-xs font-bold uppercase tracking-[0.2em]"
            >
              Continue Anyway
            </motion.button>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
