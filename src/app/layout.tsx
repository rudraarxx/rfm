import type { Metadata, Viewport } from "next";
import { Marcellus, DM_Sans, Geist_Mono } from "next/font/google";
import Script from "next/script";
import "./globals.css";
import { ThemeProvider } from "@/components/providers/ThemeProvider";
import { AudioEngine } from "@/components/audio/AudioEngine";
import { Player } from "@/components/player/Player";
import { PWARegistration } from "@/components/pwa/PWARegistration";
import { DeviceOptimizer } from "@/components/ui/DeviceOptimizer";
import { Toaster } from "sonner";

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
  title: {
    default: "RFM | Nagpur Pulse Radio",
    template: "%s | RFM Radio",
  },
  description: "Experience the pulse of Central India with RFM. High-fidelity radio streaming, live broadcasts, and the premium 'Machinist' Music OS aesthetic.",
  keywords: ["Radio", "Nagpur", "Maharashtra", "Live Streaming", "Music OS", "RFM", "Analog Player"],
  authors: [{ name: "The Machinist" }],
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
  openGraph: {
    type: "website",
    locale: "en_IN",
    url: "https://rfm-radio.vercel.app",
    siteName: "RFM Nagpur Pulse",
    title: "RFM | The Machinist Radio",
    description: "High-fidelity radio streaming for Central India.",
    images: [{ url: "/icons/icon.svg", width: 512, height: 512 }],
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
    <html lang="en" className="h-dvh overflow-hidden" suppressHydrationWarning>
      <body
        className={`${marcellus.variable} ${dmSans.variable} ${geistMono.variable} font-sans h-full flex flex-col bg-background text-foreground antialiased selection:bg-brass/20 overflow-hidden`}
      >
        <ThemeProvider attribute="class" defaultTheme="dark" enableSystem>
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
          <Toaster
            theme="dark"
            position="top-center"
            closeButton
            richColors={false}
            toastOptions={{
              style: {
                background: "var(--mahogany)",
                backdropFilter: "blur(40px)",
                border: "1px solid var(--brass)",
                color: "#FFFFFF",
                borderRadius: "1rem",
                fontFamily: "var(--font-marcellus)",
                boxShadow: "0 20px 40px rgba(0,0,0,0.5)",
              },
              className: "glass-brass",
            }}
          />
        </ThemeProvider>
      </body>
    </html>
  );
}
