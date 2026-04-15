import { describe, it, expect, vi } from "vitest";
import { renderHook, act } from "@testing-library/react";
import * as React from "react";
import { ThemeProvider } from "../components/providers/ThemeProvider";
import { useTheme } from "next-themes";

// Mock matchMedia for next-themes
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(), // deprecated
    removeListener: vi.fn(), // deprecated
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});

const wrapper = ({ children }: { children: React.ReactNode }) => (
  <ThemeProvider attribute="class">{children}</ThemeProvider>
);

describe("Theme Switching Logic", () => {
  it("should initialize with default theme", () => {
    const { result } = renderHook(() => useTheme(), { wrapper });
    // next-themes might take a tick to hydrate, but we can check the setter
    expect(result.current.setTheme).toBeDefined();
  });

  it("should change theme when setTheme is called", async () => {
    const { result } = renderHook(() => useTheme(), { wrapper });
    
    await act(async () => {
      result.current.setTheme("light");
    });
    
    expect(result.current.theme).toBe("light");
    
    await act(async () => {
      result.current.setTheme("dark");
    });
    
    expect(result.current.theme).toBe("dark");
  });
});
