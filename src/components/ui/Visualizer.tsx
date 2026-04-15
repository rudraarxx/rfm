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
          initial={{ scaleY: 0.3 }}
          animate={{
            scaleY: isPlaying 
              ? [0.3, 1, 0.5, 0.8, 0.3][i % 5] 
              : 0.3,
          }}
          transition={{
            duration: 0.8,
            repeat: Infinity,
            delay: i * 0.1,
            ease: "easeInOut",
          }}
          style={{ transformOrigin: "bottom" }}
          className="w-[2px] h-3 bg-white rounded-full opacity-80"
        />
      ))}
    </div>
  );
}
