# Testing Patterns

**Analysis Date:** 2026-04-28

## Test Frameworks

**Web:**
- **Runner**: Vitest.
- **Library**: `@testing-library/react`.
- **Command**: `npm test`.

**Mobile:**
- **Runner**: `flutter_test`.
- **Command**: `flutter test`.

## Test File Organization

**Location:**
- **Web**: `src/test/` and `src/__tests__/`.
- **Mobile**: `rfm_mobile/test/`.

**Naming:**
- **Web**: `[module].test.ts` or `[component].test.tsx`.
- **Mobile**: `[feature]_test.dart`.

## Common Patterns

**Mocking:**
- Web: Vitest mocks for API calls and MongoDB connections.
- Mobile: Riverpod `ProviderContainer` overrides for mocking repositories.

**Async Testing:**
- Extensive use of `await` for stream initialization and data fetching tests.

---

*Testing analysis: 2026-04-28*
