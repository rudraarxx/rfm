import type { Metadata, Viewport } from "next";
import { Marcellus, DM_Sans, Geist_Mono } from "next/font/google";
import Script from "next/script";
import "./globals.css";
import { AudioEngine } from "@/components/audio/AudioEngine";
import { Player } from "@/components/player/Player";
import { PWARegistration } from "@/components/pwa/PWARegistration";
import { DeviceOptimizer } from "@/components/ui/DeviceOptimizer";

const marcellus = Marcellus({
  variable: "--font-marcellus",
  weight: "400",
  subsets: ["latin"],
});

const dmSans = DM_Sans({
  variable: "--font-dm-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "RFM | Nagpur Pulse Radio",
  description: "Premium radio streaming for Nagpur and Maharashtra.",
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
    title: "RFM Radio",
  },
  icons: {
    icon: "/icons/icon.svg",
    apple: "/icons/icon.svg",
  },
};

export const viewport: Viewport = {
  themeColor: "#000000",
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark h-[100dvh] overflow-hidden">
      <body className={`${marcellus.variable} ${dmSans.variable} ${geistMono.variable} font-sans h-full flex flex-col bg-black text-white antialiased selection:bg-white/10 overflow-hidden`}>
        <DeviceOptimizer />
        <PWARegistration />
        <Script 
          src="https://cdn.jsdelivr.net/npm/hls.js@latest" 
          strategy="beforeInteractive"
        />
        <AudioEngine />
        <main className="flex-1 overflow-y-auto pb-32 no-scrollbar">
          {children}
        </main>
        <Player />
      </body>
    </html>
  );
}

