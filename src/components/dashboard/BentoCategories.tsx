"use client";

import { motion } from "framer-motion";
import { CATEGORIES } from "@/lib/constants";
import * as Icons from "lucide-react";
import { cn } from "@/lib/utils";

export function BentoCategories() {
  return (
    <section className="px-6 space-y-6">
      <h2 className="text-2xl font-bold tracking-tight text-white">Categories</h2>
      <div className="grid grid-cols-2 gap-4">
        {CATEGORIES.map((category, i) => {
          const IconComponent = (Icons as any)[category.icon];
          return (
            <motion.div
              key={category.id}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className={cn(
                "relative h-40 rounded-3xl p-6 flex flex-col justify-between cursor-pointer overflow-hidden border border-white/5",
                i === 0 ? "col-span-2 h-44" : ""
              )}
            >
              <div className={cn("absolute inset-0 bg-gradient-to-br opacity-40", category.color)} />
              <div className="absolute inset-0 glass opacity-50" />
              
              <div className="relative w-12 h-12 rounded-2xl glass flex items-center justify-center">
                <IconComponent className="w-6 h-6 text-white" strokeWidth={1.5} />
              </div>
              
              <div className="relative space-y-1">
                <h3 className="text-lg font-bold text-white tracking-tight">{category.name}</h3>
                <p className="text-xs text-white/40 font-bold uppercase tracking-widest">Explore Stations</p>
              </div>
            </motion.div>
          );
        })}
      </div>
    </section>
  );
}
