import { describe, it, expect, beforeEach } from "vitest";
import { useRadioStore } from "../store/useRadioStore";

describe("useRadioStore", () => {
  beforeEach(() => {
    // We don't need to manually clear state for simple store tests if we don't persist it in tests
    // But for safety, we can reset if needed.
  });

  it("should initialize with default values", () => {
    const state = useRadioStore.getState();
    expect(state.currentStation).toBeNull();
    expect(state.isPlaying).toBe(false);
    expect(state.volume).toBe(80);
  });

  it("should set a station and start playing", () => {
    const station = {
      changeuuid: "test-id",
      name: "Test Radio",
      url: "http://test.url",
      url_resolved: "http://test.url",
      homepage: "",
      favicon: "",
      tags: "",
      country: "",
      state: "",
      votes: 0
    };

    useRadioStore.getState().setStation(station);
    
    expect(useRadioStore.getState().currentStation).toEqual(station);
    expect(useRadioStore.getState().isPlaying).toBe(true);
  });

  it("should toggle play state", () => {
    useRadioStore.getState().togglePlay();
    const state1 = useRadioStore.getState().isPlaying;
    
    useRadioStore.getState().togglePlay();
    const state2 = useRadioStore.getState().isPlaying;
    
    expect(state1).not.toBe(state2);
  });
});
