import { NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Station from '@/models/Station';

export async function GET() {
  try {
    await dbConnect();
    
    // Aggregate unique state+city combinations
    const agg = await Station.aggregate([
      {
        $group: {
          _id: "$state",
          cities: { $addToSet: "$city" }
        }
      },
      {
        $sort: { _id: 1 }
      }
    ]);

    // Format like the existing station-index.json:
    // { "State|City": ["Station Name", ...] } 
    // The problem is, to match `station-index.json` structure perfectly we need station names too.
    // If we just need it for dropdowns, we can just supply available states and cities.
    // Let's create an index compatible with the previous format:
    // Actually, `updateStationIndex` expects a Record<string, string[]> where key is "State|City".
    
    const index: Record<string, string[]> = {};
    
    // Instead of agg all stations which could take memory, we just return the basic dropdown tree.
    // Wait, the client uses `station-index.json`'s keys to populate dropdowns!
    // Let's get the grouped states and cities. For the value, empty arrays are fine because 
    // `getCitiesForState` just splits the keys.
    agg.forEach(doc => {
      const state = doc._id;
      doc.cities.forEach((city: string) => {
        if (state && city) {
          index[`${state}|${city}`] = [];
        }
      });
    });

    return NextResponse.json(index);
  } catch (error: any) {
    console.error("GET /api/index Error:", error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
