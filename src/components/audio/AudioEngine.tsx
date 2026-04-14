"use client";

import { useEffect, useRef } from "react";
import { useRadioStore } from "@/store/useRadioStore";

declare global {
  interface Window {
    Hls: any;
  }
}

export function AudioEngine() {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const hlsRef = useRef<any>(null);
  const audioContextRef = useRef<AudioContext | null>(null);
  const sourceRef = useRef<MediaElementAudioSourceNode | null>(null);
  const { currentStation, isPlaying, volume, setIsPlaying, setAnalyser } = useRadioStore();

  // 1. Initialize audio element
  useEffect(() => {
    if (!audioRef.current) {
      audioRef.current = new Audio();
      audioRef.current.preload = "none";
      audioRef.current.crossOrigin = "anonymous";
    }
    
    const audio = audioRef.current;
    
    const handleError = (e: ErrorEvent | Event) => {
      const target = e.target as HTMLAudioElement;
      if (target.error) {
        console.error("Audio Element Error:", {
          code: target.error.code,
          message: target.error.message,
          src: target.src
        });
      }
    };

    audio.addEventListener('error', handleError);
    
    return () => {
      audio.removeEventListener('error', handleError);
      audio.pause();
      if (hlsRef.current) {
        hlsRef.current.destroy();
        hlsRef.current = null;
      }
      if (audioContextRef.current) {
        audioContextRef.current.close();
        audioContextRef.current = null;
      }
      audio.src = "";
      setAnalyser(null);
    };
  }, []);

  // 2. Sync Volume
  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.volume = volume / 100;
    }
  }, [volume]);

  // 3. Main Audio Control
  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const url = currentStation?.url_resolved || currentStation?.url;

    if (isPlaying) {
      // Initialize Web Audio API on first user interaction
      if (!audioContextRef.current) {
        try {
          const AudioContextClass = window.AudioContext || (window as any).webkitAudioContext;
          const context = new AudioContextClass();
          const analyser = context.createAnalyser();
          analyser.fftSize = 256;
          
          const source = context.createMediaElementSource(audio);
          source.connect(analyser);
          analyser.connect(context.destination);
          
          audioContextRef.current = context;
          sourceRef.current = source;
          setAnalyser(analyser);
        } catch (err) {
          console.error("Web Audio API Initialization failed:", err);
        }
      }

      // Resume context if suspended
      if (audioContextRef.current?.state === "suspended") {
        audioContextRef.current.resume();
      }

      if (!url) {
        setIsPlaying(false);
        return;
      }

      const isM3U8 = url.includes(".m3u8");

      if (audio.src !== url) {
        // Cleanup previous HLS if any
        if (hlsRef.current) {
          hlsRef.current.destroy();
          hlsRef.current = null;
        }

        if (isM3U8) {
          // Priority 1: Native HLS support (Safari)
          if (audio.canPlayType('application/vnd.apple.mpegurl')) {
            audio.src = url;
          } 
          // Priority 2: Use hls.js (Chrome/Firefox/Edge)
          else if (window.Hls && window.Hls.isSupported()) {
            const hls = new window.Hls();
            hls.loadSource(url);
            hls.attachMedia(audio);
            hlsRef.current = hls;
          } else {
            console.error("HLS is not supported in this browser");
            setIsPlaying(false);
            return;
          }
        } else {
          audio.src = url;
        }
        audio.load();
      }

      const playPromise = audio.play();
      if (playPromise !== undefined) {
        playPromise.catch((err) => {
          if (err.name === "NotSupportedError") {
            console.error("Format not supported or invalid URL:", url);
          } else if (err.name === "NotAllowedError") {
            console.warn("Playback blocked by browser (user gesture required)");
          } else {
            console.error("Playback failed:", err);
          }
          setIsPlaying(false);
        });
      }
    } else {
      audio.pause();
    }
  }, [currentStation, isPlaying, setIsPlaying]);

  return null;
}
