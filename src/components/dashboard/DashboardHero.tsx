"use client";

import { motion } from "framer-motion";
import { Radio } from "lucide-react";

export function DashboardHero() {
  return (
    <section className="px-6 pt-12 pb-8 flex flex-col items-center text-center space-y-6">
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        className="flex items-center gap-2 px-3 py-1 rounded-full glass border-white/10"
      >
        <div className="w-2 h-2 rounded-full bg-red-500 animate-pulse shadow-[0_0_8px_rgba(239,68,68,0.5)]" />
        <span className="text-[10px] font-bold uppercase tracking-[0.2em] text-white/60">Live from Nagpur, MH</span>
      </motion.div>

      <div className="space-y-2">
        <motion.h1
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.1 }}
          className="text-5xl font-black tracking-tighter text-white"
        >
          Nagpur <span className="text-white/40">Pulse.</span>
        </motion.h1>
        <motion.p
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.2 }}
          className="text-lg text-white/40 font-medium max-w-[280px] mx-auto leading-relaxed"
        >
          Premium radio streaming for the heart of India.
        </motion.p>
      </div>

      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3 }}
        className="flex items-center gap-4"
      >
        <div className="w-12 h-12 rounded-2xl glass flex items-center justify-center text-white/20">
          <Radio className="w-6 h-6" strokeWidth={1.5} />
        </div>
        <div className="text-left">
          <p className="text-sm font-bold text-white tracking-tight">24/7 Quality</p>
          <p className="text-[10px] text-white/30 font-bold uppercase tracking-widest">Hi-Fi Streams</p>
        </div>
      </motion.div>
    </section>
  );
}
