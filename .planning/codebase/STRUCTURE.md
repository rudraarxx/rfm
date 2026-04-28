# Codebase Structure

**Analysis Date:** 2026-04-28

## Directory Layout

```
RFM/
├── .agent/              # GSD skills and configuration
├── .planning/           # Project management and codebase maps
├── public/              # Static assets (Web)
├── rfm_mobile/          # Flutter mobile application
│   ├── android/         # Android native code
│   ├── ios/             # iOS native code
│   ├── lib/             # Dart source code
│   └── assets/          # App-specific images/fonts
├── scripts/             # Maintenance and data sync scripts
├── src/                 # Next.js web application source
│   ├── app/             # App Router pages and API
│   ├── components/      # UI components (shadcn/ui)
│   ├── data/            # Local data and JSON caches
│   ├── hooks/           # React hooks
│   ├── lib/             # Utilities and DB connection
│   ├── models/          # Database schemas
│   └── store/           # Frontend state (Zustand)
├── package.json         # Web project manifest
└── README.md            # Project overview
```

## Directory Purposes

**rfm_mobile/lib/**
- Purpose: Core logic and UI for the Flutter app.
- Contains: `presentation/`, `logic/`, `data/`, `core/`.
- Key files: `main.dart`.

**src/app/**
- Purpose: Next.js routing and server-side logic.
- Contains: `api/` for backend endpoints, `page.tsx` for entry point.

**scripts/**
- Purpose: Data aggregation and cloud synchronization.
- Contains: `.mjs` scripts for scraping and fetching stations.

## Naming Conventions

**Files:**
- Web: `PascalCase.tsx` for components, `kebab-case.ts` for utilities.
- Mobile: `snake_case.dart` (Standard Dart convention).

**Directories:**
- `kebab-case` for both web and mobile.

## Where to Add New Code

**New Radio Feature (Mobile):**
- UI: `rfm_mobile/lib/presentation/widgets/`
- Logic: `rfm_mobile/lib/logic/controllers/`
- Data: `rfm_mobile/lib/data/repositories/`

**New API Endpoint (Web):**
- `src/app/api/[feature]/route.ts`

**New UI Component (Web):**
- `src/components/dashboard/` or `src/components/ui/`

---

*Structure analysis: 2026-04-28*
