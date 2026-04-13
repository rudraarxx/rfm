import "@testing-library/jest-dom";
import { vi } from "vitest";

// Mock the Audio object
global.Audio = vi.fn().mockImplementation(() => ({
  pause: vi.fn(),
  play: vi.fn().mockResolvedValue(undefined),
  load: vi.fn(),
  src: "",
  volume: 1,
}));
