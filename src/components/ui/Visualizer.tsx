"use client";

import { motion } from "framer-motion";

interface VisualizerProps {
  isPlaying: boolean;
  count?: number;
}

export function Visualizer({ isPlaying, count = 4 }: VisualizerProps) {
  return (
    <div className="flex items-center gap-[2px] h-3">
      {[...Array(count)].map((_, i) => (
        <motion.div
          key={i}
          initial={{ height: "4px" }}
          animate={{
            height: isPlaying 
              ? ["4px", "12px", "6px", "10px", "4px"][i % 5] 
              : "4px",
          }}
          transition={{
            duration: 0.8,
            repeat: Infinity,
            delay: i * 0.1,
            ease: "easeInOut",
          }}
          className="w-[2px] bg-white rounded-full opacity-80"
        />
      ))}
    </div>
  );
}
