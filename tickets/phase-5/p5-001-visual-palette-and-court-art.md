---
id: P5-001
phase: 5
status: done
priority: high
parallel_group: A
depends_on: []
blocks: [P5-002, P5-003, P5-004, P5-007]
owner: codex
last_updated: 2026-05-11
---

# P5-001 - Visual Palette and Pixel Court Art

## Goal

Establish the Phase 5 asset pipeline and replace the gray-box court trapezoid with retro pixel-style court art, while preserving the existing 3/4 projection. Centralize all color constants so later sprite/UI tickets read from one palette.

## Build Spec Coverage

Phase 5 tasks (build-spec §13):

- Add asset folders.
- Add court art.
- Add consistent palette.

## Suggested File Ownership

- `dink_rivals/assets/images/court/` (new directory).
- `dink_rivals/assets/images/ui/` (new directory).
- `dink_rivals/assets/images/sprites/` (new directory, content lands in P5-002 / P5-003).
- `dink_rivals/assets/audio/sfx/` (new directory, content lands in P5-005).
- `dink_rivals/lib/game/config/visual_palette.dart` (new).
- `dink_rivals/lib/game/components/court_component.dart`.
- `dink_rivals/lib/game/components/kitchen_zone_component.dart`.
- `dink_rivals/lib/app/app_config.dart` — bump `phaseLabel` to `Phase 5`.
- `dink_rivals/pubspec.yaml` — declare new asset directories.

Avoid editing player/opponent/ball/racket components, screens, scoring, or AI in this ticket. Those belong to P5-002 / P5-003 / P5-004.

## Requirements

- Create `lib/game/config/visual_palette.dart` exporting a single `VisualPalette` class (or top-level constants) for: `courtSurface`, `courtLineWhite`, `kitchenOverlay`, `netRail`, `netMesh`, `playerPrimary`, `opponentPrimary`, `ballPrimary`, `feedbackDink`, `feedbackDrive`, `feedbackLob`, `feedbackSmash`, `feedbackFault`, `uiBackground`, `uiSurface`, `uiAccent`. Pull current hardcoded values out of components and into this file as the single source of truth.
- Add retro pixel-art court asset(s) under `assets/images/court/` (`court_classic.png`). Prefer a single texture sized for the logical 220×480 court (e.g. 4× = 880×1920) so projection still applies via a textured quad. If a textured-quad path is impractical inside `CourtComponent.render`, fall back to a `CustomPainter` that draws palette-driven primitives. Either approach **must** continue to call `game.courtToWorld(...)` for every coordinate — no baked screen pixels.
- Add UI assets under `assets/images/ui/`:
  - `logo.png` (game title logo for main menu).
  - `portrait_rookie.png`, `portrait_rally_queen.png`, `portrait_veteran.png`, `portrait_showman.png` (roster portraits).
  - All assets ship as placeholder retro pixel art; do not commit licensed art.
- Update `pubspec.yaml` `flutter.assets` to declare:
  - `assets/images/court/`
  - `assets/images/sprites/`
  - `assets/images/ui/`
  - `assets/audio/sfx/`
- Update `lib/app/app_config.dart` `phaseLabel` from `Phase 3` (or whatever it currently reads) to `Phase 5`.
- Replace inline color literals in `court_component.dart`, `net_component.dart`, `kitchen_zone_component.dart` with `VisualPalette` references.
- Court component must still render through `game.courtToWorld` — no changes to `CourtProjection` or `CourtLayoutSystem`.

## Non-Goals

- No player/opponent/ball/paddle sprite work (P5-002, P5-003).
- No scoreboard or feedback restyle (P5-004).
- No audio / SFX wiring (P5-005).
- No haptics (P5-006).
- No real AdMob, IAP, tournament, unlock, or progression work.
- No new shot buttons or control changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Required checks:

- `flutter analyze` reports zero issues.
- Existing 73+ tests stay green.
- Debug APK builds.
- Manual visual spot-check: court reads as pixel-style at portrait and landscape orientations; kitchen zone still visible; net still readable; logical bounds still align under the same `CourtProjection` math.

## Acceptance Criteria

- `VisualPalette` exists and is used by `CourtComponent`, `NetComponent`, `KitchenZoneComponent`.
- Asset directories exist and are declared in `pubspec.yaml`.
- Court art renders without distorting the 3/4 projection.
- `phaseLabel` reads `Phase 5` in the debug overlay.
- No regressions to existing tests, AI, scoring, physics, or controls.
