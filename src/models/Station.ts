import mongoose, { Schema, Document } from 'mongoose';
import { Station } from '@/types/radio';

export interface IStation extends Station, Document {
  changeuuid: string; // explicitly required to override Document's auto `id` if needed, but we'll use string
}

const StationSchema: Schema = new Schema({
  changeuuid: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  url: { type: String, required: true },
  url_resolved: { type: String, required: true },
  homepage: { type: String, default: "" },
  favicon: { type: String, default: "" },
  tags: { type: String, default: "" },
  country: { type: String, required: true },
  state: { type: String, required: true },
  votes: { type: Number, default: 0 },
  city: { type: String, default: "" },
  language: { type: String, default: "" },
  codec: { type: String, default: "" },
  bitrate: { type: Number, default: 0 },
  source: { type: String, default: "" },
}, {
  timestamps: true // adds createdAt and updatedAt
});

// Index for faster searching
StationSchema.index({ state: 1, city: 1 });
StationSchema.index({ name: 'text', tags: 'text' });

export default mongoose.models.Station || mongoose.model<IStation>('Station', StationSchema);
