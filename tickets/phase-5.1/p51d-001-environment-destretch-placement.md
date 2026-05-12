---
id: P51D-001
phase: 5.1D
status: done
priority: high
parallel_group: D
depends_on: [P51A-001, P5B-002]
blocks: [P51E-001, P51F-001, P51I-001]
owner: unassigned
last_updated: 2026-05-11
---

# P51D-001 - Environment De-Stretch and Asset Placement

## Goal

Fix stretched-looking fence, trees, shrubs, and courtside props by replacing broad raster stretching with proportionate assets and data-driven perspective placement.

## Build Spec Coverage

Phase 5.1D - Environment De-Stretch and Asset Placement:

- De-stretched courtside fence, trees, shrubs, and props.
- Properly proportioned environment assets.
- Data-driven placement that reinforces 3/4 depth.

## Suggested File Ownership

- `dink_rivals/assets/images/environment/classic/`
- `dink_rivals/assets/images/environment/shared/`
- `dink_rivals/lib/game/components/classic_environment_component.dart`
- `dink_rivals/lib/game/config/environment_layout.dart`
- `dink_rivals/test/environment_layout_test.dart`
- `docs/art/phase-5.1/phase-5.1-delta-inventory.md` (reference only)
- `tickets/status.md`

Avoid editing court/net/player/HUD files unless the triage ticket explicitly says their layers are involved.

## Requirements

- Replace or revise fence rendering so it reads as a physical background object, not a horizontally stretched strip.
- Replace or revise tree/shrub usage so it does not look uniformly scaled or repeated.
- Keep prop placement in config/data rather than scattered screen pixels.
- Ensure props remain outside active gameplay readability zones.
- Keep decorative props lower contrast than court lines, ball, players, net, score, pause, and controls.
- Add layout tests or assertions for bounds/overlap where practical.

## Non-Goals

- No animated crowd.
- No weather, day/night, or dynamic environment system.
- No new gameplay collisions with props.
- No UI or character sprite work.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- Fence and trees no longer look stretched or warped in the Phase 5.1 screenshot set.
- Trees/shrubs use varied sizes and placements without obvious repeated bands.
- Prop placement remains data-driven.
- Props do not overlap court lines, ball, players, score, pause button, feedback, joystick, swing stick, or serve button.
- Android performance remains acceptable if device QA is available.

## Planning Notes

- This ticket should land before adding more environment richness so bad scale/stretch patterns are not multiplied.
