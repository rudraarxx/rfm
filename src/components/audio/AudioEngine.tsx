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
  const { 
    currentStation, 
    isPlaying, 
    volume, 
    setIsPlaying, 
    setAnalyser,
    nextStation,
    previousStation
  } = useRadioStore();

  // 1. Initialize audio element and event listeners
  useEffect(() => {
    if (!audioRef.current) {
      audioRef.current = new Audio();
      audioRef.current.preload = "none";
      audioRef.current.crossOrigin = "anonymous";
    }
    
    const audio = audioRef.current;
    
    const handlePlay = () => setIsPlaying(true);
    const handlePause = () => setIsPlaying(false);
    
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

    audio.addEventListener('play', handlePlay);
    audio.addEventListener('pause', handlePause);
    audio.addEventListener('error', handleError);
    
    return () => {
      audio.removeEventListener('play', handlePlay);
      audio.removeEventListener('pause', handlePause);
      audio.removeEventListener('error', handleError);
      audio.pause();
      if (hlsRef.current) {
        hlsRef.current.destroy();
        hlsRef.current = null;
      }
      if (audioContextRef.current) {
        audioContextRef.current.close().catch(() => {});
        audioContextRef.current = null;
      }
      audio.removeAttribute('src');
      audio.load();
      setAnalyser(null);
    };
  }, [setIsPlaying, setAnalyser]);

  // 2. MediaSession synchronization
  useEffect(() => {
    if (!('mediaSession' in navigator)) return;

    if (currentStation) {
      navigator.mediaSession.metadata = new MediaMetadata({
        title: currentStation.name,
        artist: currentStation.tags || "Nagpur Pulse Radio",
        album: "RFM Analog Player",
        artwork: [
          { src: currentStation.favicon || "/icons/icon.svg", sizes: "512x512", type: "image/png" }
        ]
      });
    }

    navigator.mediaSession.setActionHandler('play', () => setIsPlaying(true));
    navigator.mediaSession.setActionHandler('pause', () => setIsPlaying(false));
    navigator.mediaSession.setActionHandler('nexttrack', () => nextStation());
    navigator.mediaSession.setActionHandler('previoustrack', () => previousStation());

    // Cleanup handlers
    return () => {
      navigator.mediaSession.setActionHandler('play', null);
      navigator.mediaSession.setActionHandler('pause', null);
      navigator.mediaSession.setActionHandler('nexttrack', null);
      navigator.mediaSession.setActionHandler('previoustrack', null);
    };
  }, [currentStation, setIsPlaying, nextStation, previousStation]);

  // 3. Sync Volume
  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.volume = volume / 100;
    }
  }, [volume]);

  // 4. Main Audio Control
  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const url = currentStation?.url_resolved || currentStation?.url;

    if (isPlaying) {
      if (!url) {
        setIsPlaying(false);
        return;
      }

      // 1. Initialize Web Audio API on first user interaction
      if (!audioContextRef.current) {
        try {
          const AudioContextClass = window.AudioContext || (window as any).webkitAudioContext;
          if (AudioContextClass) {
            const context = new AudioContextClass();
            const analyser = context.createAnalyser();
            analyser.fftSize = 256;
            
            const source = context.createMediaElementSource(audio);
            source.connect(analyser);
            analyser.connect(context.destination);
            
            audioContextRef.current = context;
            sourceRef.current = source;
            setAnalyser(analyser);
          }
        } catch (err) {
          console.error("Web Audio API Initialization failed:", err);
        }
      }

      // 2. Resume context safely
      if (audioContextRef.current?.state === "suspended") {
        audioContextRef.current.resume().catch(e => console.warn("AudioContext resume failed:", e));
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
          else {
            const Hls = (window as any).Hls;
            if (Hls && Hls.isSupported()) {
              const hls = new Hls();
              hls.loadSource(url);
              hls.attachMedia(audio);
              hlsRef.current = hls;
            } else {
              console.warn("HLS is not supported in this browser or yet loaded");
              setIsPlaying(false);
              return;
            }
          }
        } else {
          audio.src = url;
        }
        audio.load();
      }

      const playPromise = audio.play();
      if (playPromise !== undefined) {
        playPromise.catch((err) => {
          if (err.name !== "AbortError") { // Ignore AbortErrors caused by quick station changes
            console.error("Playback failed:", err);
            setIsPlaying(false);
          }
        });
      }
    } else {
      audio.pause();
    }
  }, [currentStation, isPlaying, setIsPlaying, setAnalyser]);

  return null;
}
