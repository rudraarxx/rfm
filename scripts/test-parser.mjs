import { readFileSync } from "fs";

const html = readFileSync("/Users/kundanprasad/.gemini/antigravity/brain/ff314884-dfb9-49ea-b8da-bfc3507575c7/.system_generated/steps/148/content.md", "utf8");

const stations = [];
const blocks = html.split(/\n- \n|\n-\n/);

console.log(`Found ${blocks.length} blocks`);

for (const block of blocks) {
  // Extract station name and URL
  // Example: [Vividh Bharati 100.6 FM](https://onlineradiofm.in/maharashtra/maharashtra/nagpur/vividh-bharati)
  const nameMatch = block.match(/\[([^\]]+)\]\(https:\/\/onlineradiofm\.in\/[^)]+\/([\w-]+)\)/);
  if (!nameMatch) continue;
  
  const name = nameMatch[1].trim();
  const slug = nameMatch[2];
  
  if (!name || name.length < 2) continue;
  
  // Extract frequency
  const freqMatch = block.match(/Frequency:\s*([^\n]+)/);
  const frequency = freqMatch ? freqMatch[1].trim() : "";
  
  // Extract genre (remove markdown links)
  const genreMatch = block.match(/Genre:\s*([^\n]+)/);
  const tags = genreMatch
    ? genreMatch[1].replace(/\[([^\]]+)\]\([^)]+\)/g, "$1").replace(/\.\s*$/, "").trim()
    : "";
  
  // Extract language
  const langMatch = block.match(/Language:\s*([^\n]+)/);
  const language = langMatch
    ? langMatch[1].replace(/\[([^\]]+)\]\([^)]+\)/g, "$1").replace(/\.\s*$/, "").trim()
    : "";
  
  // Extract bitrate
  const bitrateMatch = block.match(/Bitrate:\s*(\d+)\s*Kbps/);
  const bitrate = bitrateMatch ? parseInt(bitrateMatch[1]) : 0;
  
  stations.push({ name, slug, frequency, tags, language, bitrate });
}

console.log(JSON.stringify(stations.slice(0, 5), null, 2));
console.log(`Total stations parsed: ${stations.length}`);
