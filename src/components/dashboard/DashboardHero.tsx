"use client";

import { motion } from "framer-motion";
import { Radio } from "lucide-react";

export function DashboardHero() {
  return (
    <section className="px-6 pt-20 pb-12 flex flex-col items-center text-center space-y-8">
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        className="flex items-center gap-3 px-4 py-1.5 rounded-full glass-brass border-brass/20"
      >
        <div className="w-2 h-2 rounded-full bg-amber shadow-[0_0_12px_rgba(255,176,59,0.5)] animate-pulse" />
        <span className="text-[10px] font-bold uppercase tracking-[0.3em] text-brass">Live Nagpur Pulse</span>
      </motion.div>

      <div className="space-y-4">
        <motion.h1
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.1 }}
          className="text-6xl font-primary tracking-tight text-white"
        >
          Nagpur <span className="text-white/20 italic">Pulse.</span>
        </motion.h1>
        <motion.p
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.2 }}
          className="text-lg text-white/40 font-medium max-w-[320px] mx-auto leading-relaxed"
        >
          Curated Radio Shell for the Analog Soul.
        </motion.p>
      </div>

      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3 }}
        className="flex items-center gap-6"
      >
        <div className="w-14 h-14 rounded-full glass-brass flex items-center justify-center text-brass/40 relative">
          <div className="absolute inset-0 rounded-full border border-brass/10 animate-[ping_3s_linear_infinite]" />
          <Radio className="w-6 h-6" strokeWidth={1} />
        </div>
        <div className="text-left">
          <p className="text-sm font-semibold text-white tracking-tight">Studio Quality</p>
          <p className="text-[10px] text-white/20 font-bold uppercase tracking-widest">Hi-Fi Analytics</p>
        </div>
      </motion.div>
    </section>
  );
}
