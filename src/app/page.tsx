import { FALLBACK_STATIONS } from "@/lib/constants";
import { DashboardHero } from "@/components/dashboard/DashboardHero";
import { StationGrid } from "@/components/dashboard/StationGrid";

export default async function Home() {
  const featuredStations = [...FALLBACK_STATIONS];

  return (
    <div className="flex flex-col gap-16 max-w-lg mx-auto overflow-hidden pb-40">
      <DashboardHero />

      <div className="space-y-16">
        <StationGrid title="Featured Stations" stations={featuredStations} />

        <div className="px-8 flex justify-center">
          <div className="relative glass-brass rounded-[2rem] p-12 text-center space-y-4 w-full border-brass/5 overflow-hidden group">
            <div className="absolute top-4 right-4 bg-brass/10 border border-brass/20 px-3 py-1 rounded-full">
              <p className="text-[8px] font-bold text-brass uppercase tracking-[0.2em]">Coming Soon</p>
            </div>
            <h3 className="text-2xl font-primary text-white">The Archive.</h3>
            <p className="text-xs text-white/30 font-bold uppercase tracking-[0.3em]">
              Curating the Soul of Nagpur
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
