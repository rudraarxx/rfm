"use client";

import { useEffect, useRef } from "react";
import { useRadioStore } from "@/store/useRadioStore";

interface AudioSpectrumProps {
  width?: number;
  height?: number;
  barWidth?: number;
  gap?: number;
  color?: string;
  className?: string;
}

export function AudioSpectrum({
  width = 320,
  height = 120,
  barWidth = 3,
  gap = 2,
  color = "#D4AF37", // Theme Brass
  className = "",
}: AudioSpectrumProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const { analyser, isPlaying } = useRadioStore();
  const animationRef = useRef<number>(0);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const dpr = window.devicePixelRatio || 1;
    canvas.width = width * dpr;
    canvas.height = height * dpr;
    ctx.scale(dpr, dpr);

    const barCount = Math.floor(width / (barWidth + gap));
    const centerY = height / 2;

    const render = () => {
      if (!analyser || !isPlaying) {
        ctx.clearRect(0, 0, width, height);
        animationRef.current = requestAnimationFrame(render);
        return;
      }

      const bufferLength = analyser.frequencyBinCount;
      const dataArray = new Uint8Array(bufferLength);
      analyser.getByteFrequencyData(dataArray);

      ctx.clearRect(0, 0, width, height);

      for (let i = 0; i < barCount; i++) {
        // Distance from center (0 at middle, 1 at edges)
        const distFromCenter = Math.abs(i - barCount / 2) / (barCount / 2);
        
        // Map frequency: center of canvas gets bass (index 0), edges get treble
        const dataIndex = Math.floor(distFromCenter * (bufferLength * 0.7));
        const value = dataArray[dataIndex] || 0;
        const percent = value / 255;

        // Quadratic fade out towards edges
        const fadeScale = Math.pow(1 - distFromCenter, 1.5);

        const actualBarHeight = Math.max(2, percent * height * 0.9 * fadeScale);

        const x = i * (barWidth + gap);
        const yTop = centerY - actualBarHeight / 2;

        // Remove expensive shadowBlur
        
        // Draw Bar
        ctx.fillStyle = color;
        ctx.globalAlpha = 0.3 + percent * 0.7; 
        
        // Rounded rectangle for the bar
        drawRoundedRect(ctx, x, yTop, barWidth, actualBarHeight, barWidth / 2);
        ctx.fill();
      }

      animationRef.current = requestAnimationFrame(render);
    };

    render();

    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, [analyser, isPlaying, width, height, color, barWidth, gap]);

  // Helper to draw rounded bars
  const drawRoundedRect = (
    ctx: CanvasRenderingContext2D,
    x: number,
    y: number,
    w: number,
    h: number,
    r: number
  ) => {
    if (w < 2 * r) r = w / 2;
    if (h < 2 * r) r = h / 2;
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.arcTo(x + w, y, x + w, y + h, r);
    ctx.arcTo(x + w, y + h, x, y + h, r);
    ctx.arcTo(x, y + h, x, y, r);
    ctx.arcTo(x, y, x + w, y, r);
    ctx.closePath();
  };

  return (
    <canvas
      ref={canvasRef}
      width={width * 2} // Retina support
      height={height * 2}
      style={{
        width: width,
        height: height,
      }}
      className={className}
    />
  );
}
