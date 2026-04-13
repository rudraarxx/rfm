import { Station } from "@/store/useRadioStore";

export const FALLBACK_STATIONS: Station[] = [
  {
    changeuuid: "vividh-bharti",
    name: "Vividh Bharti",
    url: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio070/playlist.m3u8",
    url_resolved: "https://air.pc.cdn.bitgravity.com/air/live/pbaudio070/playlist.m3u8",
    homepage: "https://prasarbharati.gov.in/",
    favicon: "/stations/vividh_bharti.png",
    tags: "classic,bollywood,news,national",
    country: "India",
    state: "National",
    votes: 1500
  },
  {
    changeuuid: "radio-mirchi-nagpur",
    name: "Radio Mirchi 98.3",
    url: "https://eu8.fastcast4u.com/proxy/clyedupq?mp=%2F1?aw_0_req_lsid=2c0fae177108c9a42a7cf24878625444",
    url_resolved: "https://eu8.fastcast4u.com/proxy/clyedupq?mp=%2F1?aw_0_req_lsid=2c0fae177108c9a42a7cf24878625444",
    homepage: "https://www.radiomirchi.com/",
    favicon: "/stations/radio_mirchi.png",
    tags: "bollywood,hits,top40,nagpur",
    country: "India",
    state: "Maharashtra",
    votes: 1200
  },
  {
    changeuuid: "big-fm-927",
    name: "BIG 92.7 FM",
    url: "https://stream.zeno.fm/dbstwo3dvhhtv",
    url_resolved: "https://stream.zeno.fm/dbstwo3dvhhtv",
    homepage: "https://www.bigfmindia.com/",
    favicon: "/stations/big_fm.png",
    tags: "bollywood,retro,talk,nagpur",
    country: "India",
    state: "Maharashtra",
    votes: 1100
  },
  {
    changeuuid: "radio-city-911-nagpur",
    name: "Radio City 91.1",
    url: "https://stream.zeno.fm/pxc55r5uyc9uv",
    url_resolved: "https://stream.zeno.fm/pxc55r5uyc9uv",
    homepage: "https://www.radiocity.in/",
    favicon: "/stations/radio_city.png",
    tags: "bollywood,hits,nagpur",
    country: "India",
    state: "Maharashtra",
    votes: 1050
  },
  {
    changeuuid: "red-fm-935-nagpur",
    name: "Red FM 93.5",
    url: "https://stream.zeno.fm/9phrkb1e3v8uv",
    url_resolved: "https://stream.zeno.fm/9phrkb1e3v8uv",
    homepage: "https://www.redfmindia.in/",
    favicon: "/stations/red_fm.png",
    tags: "bollywood,hits,nagpur",
    country: "India",
    state: "Maharashtra",
    votes: 1000
  }
];

export const CATEGORIES = [
  { id: "local", name: "Local", icon: "MapPin", color: "from-blue-500/20 to-indigo-500/20" },
  { id: "marathi", name: "Marathi News", icon: "Newspaper", color: "from-orange-500/20 to-red-500/20" },
  { id: "bollywood", name: "Bollywood", icon: "Music2", color: "from-pink-500/20 to-purple-500/20" },
  { id: "global", name: "Global", icon: "Globe2", color: "from-emerald-500/20 to-teal-500/20" },
];
