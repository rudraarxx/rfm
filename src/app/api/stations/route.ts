import { NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import Station from '@/models/Station';

export async function GET(request: Request) {
  try {
    await dbConnect();
    const { searchParams } = new URL(request.url);
    const state = searchParams.get('state');
    const city = searchParams.get('city');
    const search = searchParams.get('search');

    const query: any = {};

    if (state) {
      if (state.length > 0) query.state = state;
    }
    if (city) {
      if (city.length > 0) query.city = city;
    }
    if (search) {
      query.$text = { $search: search };
    }

    // Limit to 200 stations generally, but wait, discovery needs all if state/city matches.
    // If we only have state/city filters, return all matches or limit to a reasonable number.
    const stations = await Station.find(query)
      .sort(search ? { score: { $meta: 'textScore' } } : { votes: -1 })
      .limit(200)
      .lean();

    return NextResponse.json({ stations });
  } catch (error: any) {
    console.error("GET /api/stations Error:", error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
