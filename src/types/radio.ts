export interface Station {
  changeuuid: string;
  name: string;
  url: string;
  url_resolved: string;
  homepage: string;
  favicon: string;
  tags: string;
  country: string;
  state: string;
  votes: number;
  // Optional fields
  city?: string;
  language?: string;
  codec?: string;
  bitrate?: number;
  source?: string;
}
