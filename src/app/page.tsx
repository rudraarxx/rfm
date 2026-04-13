import { fetchStations } from "@/lib/api";
import { FALLBACK_STATIONS } from "@/lib/constants";
import { DashboardHero } from "@/components/dashboard/DashboardHero";
import { StationGrid } from "@/components/dashboard/StationGrid";
import { BentoCategories } from "@/components/dashboard/BentoCategories";

export default async function Home() {
  // Only use fallback for now as requested
  const featuredStations = [...FALLBACK_STATIONS];

  return (
    <div className="flex flex-col gap-12 max-w-lg mx-auto overflow-hidden">
      <DashboardHero />
      
      <div className="space-y-12">
        <StationGrid 
          title="Featured" 
          stations={featuredStations} 
        />
        
        <BentoCategories />
        
        <div className="px-6 pb-12">
          <div className="glass rounded-3xl p-8 text-center space-y-4">
            <h3 className="text-xl font-bold text-white">More Coming Soon</h3>
            <p className="text-sm text-white/40">We're constantly adding new stations from Nagpur and Maharashtra.</p>
          </div>
        </div>
      </div>
    </div>
  );
}
