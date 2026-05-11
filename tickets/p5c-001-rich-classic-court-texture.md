---
id: P5C-001
phase: 5C
status: todo
priority: high
parallel_group: A
depends_on: [P5A-002]
blocks: [P5C-003, P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5C-001 - Rich Classic Court Texture and Kitchen Treatment

## Goal

Replace the early Phase 5 court surface with a richer pixel-art court texture while preserving line and kitchen readability.

## Build Spec Coverage

Phase 5C - Court Material, Net, Lighting, and Shadows:

- Detailed court texture with subtle pixel noise, scuffs, and line wear.
- Clearer kitchen zone treatment.
- Line thickness and contrast tuning.

## Suggested File Ownership

- `dink_rivals/assets/images/court/court_classic.png`
- `dink_rivals/lib/game/components/court_component.dart`
- `dink_rivals/lib/game/components/kitchen_zone_component.dart`
- `dink_rivals/lib/game/config/visual_palette.dart`
- `dink_rivals/test/` only if helper behavior is added
- `tickets/status.md`

Do not edit net, player/opponent, ball/paddle, UI, physics, scoring, or AI.

## Requirements

- Generate or hand-author a richer Classic Court texture with subtle noise, scuffs, and line wear.
- Keep the court projected through existing `courtToWorld` rendering; do not bake screen pixels.
- Preserve or improve kitchen visibility.
- Tune line contrast through `VisualPalette`, not scattered hardcoded colors.
- Keep ball visibility higher priority than texture detail.

## Non-Goals

- No environment props.
- No net rewrite.
- No shadows beyond court-surface markings.
- No `CourtProjection` or `CourtLayoutSystem` changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- Court texture feels intentional and pixel-art, not flat bands.
- Court lines and kitchen remain readable on phone.
- No gameplay behavior changes.

