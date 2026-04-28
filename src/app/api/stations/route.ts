import { NextResponse } from 'next/server';
import { readFileSync, existsSync } from 'fs';
import { join } from 'path';
import crypto from 'crypto';

// Cache the station data in memory to avoid repeated disk reads
let cachedData: any = null;
let cachedEtag: string = '';

function loadStations() {
  if (cachedData) return { data: cachedData, etag: cachedEtag };

  const dataPath = join(process.cwd(), 'src', 'data', 'radio-browser-cache.json');
  
  if (!existsSync(dataPath)) {
    return { data: { stations: [] }, etag: '' };
  }

  const fileContent = readFileSync(dataPath, 'utf-8');
  const parsed = JSON.parse(fileContent);
  
  // We only care about the stations array
  cachedData = parsed.stations || [];
  cachedEtag = crypto.createHash('md5').update(fileContent).digest('hex');
  
  return { data: cachedData, etag: cachedEtag };
}

export async function GET(request: Request) {
  try {
    const { data: stations, etag } = loadStations();
    
    // 1. Check ETag for conditional fetching
    const ifNoneMatch = request.headers.get('If-None-Match');
    if (ifNoneMatch === etag) {
      return new NextResponse(null, { status: 304 });
    }

    const { searchParams } = new URL(request.url);
    const state = searchParams.get('state')?.toLowerCase();
    const city = searchParams.get('city')?.toLowerCase();
    const search = searchParams.get('search')?.toLowerCase();
    const recommend = searchParams.get('recommend') === 'true';
    const limit = parseInt(searchParams.get('limit') || '200');

    // 2. Perform in-memory filtering
    let filtered = [...stations];

    if (recommend) {
      // Discovery Logic: Mix of local and top global
      const local = stations.filter((s: any) => 
        (state && s.state?.toLowerCase().includes(state)) || 
        (city && s.city?.toLowerCase().includes(city))
      ).slice(0, 10);
      
      const topGlobal = stations
        .sort((a: any, b: any) => (b.votes || 0) - (a.votes || 0))
        .slice(0, 50);
      
      // Shuffle and pick
      filtered = [...new Set([...local, ...topGlobal])].sort(() => Math.random() - 0.5);
    } else {
      if (state) {
        filtered = filtered.filter((s: any) => s.state?.toLowerCase().includes(state));
      }
      if (city) {
        filtered = filtered.filter((s: any) => s.city?.toLowerCase().includes(city));
      }
      if (search) {
        filtered = filtered.filter((s: any) => 
          s.name?.toLowerCase().includes(search) || 
          s.tags?.toLowerCase().includes(search)
        );
      }
      // Sort by votes descending
      filtered.sort((a: any, b: any) => (b.votes || 0) - (a.votes || 0));
    }

    // 3. Limit result
    const result = filtered.slice(0, limit);

    return NextResponse.json(
      { stations: result },
      {
        headers: {
          'ETag': etag,
          'Cache-Control': 'public, max-age=3600',
        }
      }
    );
  } catch (error: any) {
    console.error("GET /api/stations Error:", error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
