"use client";

import { motion } from "framer-motion";
import { Radio, ShieldCheck } from "lucide-react";

export function DashboardHero() {
  return (
    <section className="relative px-6 pt-24 pb-16 flex flex-col items-center text-center overflow-hidden">
      {/* Cinematic Ambient Background Blobs */}
      <div className="absolute inset-0 -z-10 overflow-hidden pointer-events-none">
        <motion.div
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.1, 0.2, 0.1],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut",
          }}
          className="absolute -top-[10%] -left-[10%] w-[400px] h-[400px] bg-brass/20 rounded-full blur-[120px]"
        />
        <motion.div
          animate={{
            scale: [1.2, 1, 1.2],
            opacity: [0.05, 0.15, 0.05],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 1,
          }}
          className="absolute top-[20%] -right-[10%] w-[350px] h-[350px] bg-amber/10 rounded-full blur-[100px]"
        />
      </div>

      <div className="relative z-10 w-full max-w-lg space-y-12">
        {/* Animated Badge */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          className="inline-flex items-center gap-3 px-6 py-2 rounded-full glass-brass border border-brass/20 shadow-[0_8px_32px_rgba(212,175,55,0.1)] self-center mx-auto"
        >
          <div className="relative flex items-center justify-center">
            <div className="w-2 h-2 rounded-full bg-amber shadow-[0_0_8px_rgba(255,176,59,1)]" />
            <div className="absolute w-4 h-4 rounded-full border border-amber/40 animate-ping" />
          </div>
          <span className="text-[11px] font-bold uppercase tracking-[0.4em] text-brass dark:text-brass/80">
            Live Nagpur Pulse
          </span>
        </motion.div>

        {/* Hero Title & Tagline */}
        <div className="space-y-6">
          <div className="relative">
            <motion.h1
              initial={{ y: 30, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.1, duration: 0.8, ease: "easeOut" }}
              className="text-7xl font-primary tracking-tighter text-foreground leading-[0.9]"
            >
              Nagpur
              <br />
              <span className="text-foreground/10 italic font-light">Pulse.</span>
            </motion.h1>
            {/* Reflective Accents */}
            <div className="absolute -inset-10 bg-gradient-to-r from-brass/0 via-brass/5 to-brass/0 blur-2xl -z-10 opacity-50" />
          </div>

          <motion.p
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.2, duration: 0.8 }}
            className="text-lg text-foreground/40 font-medium max-w-[280px] mx-auto leading-relaxed font-sans"
          >
            Curated Radio Shell for the <span className="text-foreground/60">Analog Soul.</span>
          </motion.p>
        </div>

        {/* Status Indicator Card */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.3, duration: 0.8 }}
          className="flex items-center justify-center pt-4"
        >
          <div className="flex items-center gap-5 px-6 py-4 rounded-2xl glass border border-foreground/5 shadow-2xl">
            <div className="w-12 h-12 rounded-xl bg-brass/10 flex items-center justify-center text-brass relative overflow-hidden group">
              <div className="absolute inset-0 bg-brass/5 translate-y-full group-hover:translate-y-0 transition-transform duration-500" />
              <ShieldCheck className="w-6 h-6 relative z-10" strokeWidth={1.5} />
            </div>
            <div className="text-left space-y-0.5">
              <p className="text-sm font-semibold text-foreground tracking-tight">Studio Quality</p>
              <p className="text-[9px] text-foreground/30 font-bold uppercase tracking-[0.2em] flex items-center gap-2">
                <span className="w-1 h-1 rounded-full bg-brass/40" />
                Hi-Fi Analytics
              </p>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
