---
id: P5B-002
phase: 5B
status: todo
priority: high
parallel_group: B
depends_on: [P5B-001]
blocks: [P5B-003, P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5B-002 - Classic Environment Component and Placement Data

## Goal

Render a park environment around Classic Court using data-driven prop placement while preserving court and gameplay readability.

## Build Spec Coverage

Phase 5B - Courtside Environment and Depth Dressing:

- Off-court ground surface.
- Back fence/wall.
- Near/far prop scaling.
- Render layer behind court lines and gameplay objects.

## Suggested File Ownership

- `dink_rivals/lib/game/components/classic_environment_component.dart` (new)
- `dink_rivals/lib/game/config/environment_layout.dart` (new)
- `dink_rivals/lib/game/dink_rivals_game.dart`
- `dink_rivals/test/environment_layout_test.dart` (new)
- `dink_rivals/assets/images/environment/classic/` (read-only unless missing asset fix is required)
- `tickets/status.md`

Do not edit scoring, rules, physics, AI, input, or controls.

## Requirements

- Add a `ClassicEnvironmentComponent` rendered behind the court and gameplay objects.
- Store prop placement data in config/data rather than scattering screen coordinates through render code.
- Render off-court surface, far fence/wall, and a first pass of props around the court.
- Use existing projection/layout helpers where possible; do not modify `CourtProjection` or `CourtLayoutSystem`.
- Ensure props do not overlap joystick, swing stick, serve button, score, pause, or feedback regions.
- Add tests or assertions for placement bounds where practical.

## Non-Goals

- No court material rewrite (P5C).
- No VFX.
- No UI restyle.
- No new court selection system.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- Classic Court no longer appears to float on black.
- Full court, kitchen, net, ball, and controls remain readable.
- Prop placement is data-driven and bounded.

