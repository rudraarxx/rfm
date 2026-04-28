import { NextResponse } from 'next/server';
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { join } from 'path';

const SYNC_DIR = join(process.cwd(), 'src', 'data', 'sync');

// Ensure sync directory exists
if (!existsSync(SYNC_DIR)) {
  mkdirSync(SYNC_DIR, { recursive: true });
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const id = searchParams.get('id');

  if (!id || id.length < 4) {
    return NextResponse.json({ error: 'Invalid Sync ID' }, { status: 400 });
  }

  const filePath = join(SYNC_DIR, `${id}.json`);

  if (!existsSync(filePath)) {
    return NextResponse.json({ favorites: [] });
  }

  try {
    const data = readFileSync(filePath, 'utf-8');
    return NextResponse.json(JSON.parse(data));
  } catch (error) {
    return NextResponse.json({ error: 'Failed to read sync data' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const { id, favorites } = await request.json();

    if (!id || id.length < 4) {
      return NextResponse.json({ error: 'Invalid Sync ID' }, { status: 400 });
    }

    const filePath = join(SYNC_DIR, `${id}.json`);
    writeFileSync(filePath, JSON.stringify({ favorites, lastUpdated: new Date().toISOString() }));

    return NextResponse.json({ success: true });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to save sync data' }, { status: 500 });
  }
}
