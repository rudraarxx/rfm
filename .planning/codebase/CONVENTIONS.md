# Coding Conventions

**Analysis Date:** 2026-04-28

## Naming Patterns

**Files:**
- **Web**: `PascalCase.tsx` for components, `kebab-case.ts` for logic.
- **Mobile**: `snake_case.dart` for all files.

**Functions/Variables:**
- **Web**: `camelCase` for functions and variables.
- **Mobile**: `camelCase` for functions and variables.

**Types/Classes:**
- **Web**: `PascalCase` for Interfaces and Types.
- **Mobile**: `PascalCase` for Classes and Models.

## Code Style

**Formatting:**
- **Web**: ESLint + Prettier (implicit in Next.js setup).
- **Mobile**: `flutter format` (Standard Dart formatter).

**Linting:**
- **Web**: `eslint.config.mjs` using Next.js recommendations.
- **Mobile**: `analysis_options.yaml` with `flutter_lints`.

## Import Organization

**Web (Next.js):**
- Path aliases: `@/` maps to `src/`.
- Order: React/Next -> External Libraries -> App Components -> Types/Utils.

**Mobile (Flutter):**
- Flutter packages -> External packages -> Project imports.

## Error Handling

**Patterns:**
- Use of `try/catch` at the controller or repository level.
- Error logs to console in development.
- Fallback UI states (e.g., "Station Offline").

---

*Convention analysis: 2026-04-28*
