import { NextResponse } from 'next/server';
import { readFileSync } from 'fs';
import { join } from 'path';

export async function GET() {
  try {
    const dataPath = join(process.cwd(), 'src', 'data', 'radio-browser-cache.json');
    const fileContent = readFileSync(dataPath, 'utf8');
    const { stations } = JSON.parse(fileContent);
    
    const index: Record<string, string[]> = {};
    
    stations.forEach((s: any) => {
      const state = s.state || "India";
      const city = s.city || "";
      if (state && city) {
        const key = `${state}|${city}`;
        if (!index[key]) index[key] = [];
      }
    });

    return NextResponse.json(index);
  } catch (error: any) {
    console.error("GET /api/index Error:", error);
    return NextResponse.json({}, { status: 200 }); // Return empty index on error to avoid breaking UI
  }
}
