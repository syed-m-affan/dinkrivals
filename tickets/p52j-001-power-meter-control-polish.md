---
id: P52J-001
phase: 5.2I
status: todo
priority: high
parallel_group: H
depends_on: [P52A-002]
blocks: [P52L-001, P52M-001]
owner: unassigned
last_updated: 2026-05-11
---

# P52J-001 - Power Meter and Swing-Control Polish

## Goal

Add a visual-only swing power meter and concept-style control polish while preserving all control hit regions and shot physics.

## Build Spec Coverage

Phase 5.2I - Power Meter and HUD Control Polish:

- Lightning-style power meter.
- D-pad chevrons.
- Refined SWING label.
- Pause/control proportion check.

## Suggested File Ownership

- `dink_rivals/lib/game/components/touch_controls_component.dart`
- `dink_rivals/lib/game/systems/input_system.dart` only for read-only visual getter if needed
- `dink_rivals/lib/game/systems/touch_input_controller.dart` only for tests proving hit regions are unchanged
- `dink_rivals/test/touch_input_controller_test.dart`
- `dink_rivals/test/shot_system_test.dart` only for no-physics-regression assertions if needed
- `docs/art/phase-5.2-power-meter-controls.png`
- `tickets/status.md`

Coordinate with P52L before making broader pause/control layout changes.

## Requirements

- Add a power meter near the swing stick using read-only existing swing velocity or serve charge data.
- Meter fill must reset naturally when swing/serve input ends and must not store progression.
- Add D-pad chevrons inside the move ring.
- Refine SWING label placement and sizing.
- Preserve existing touch hit regions, pointer behavior, and input contract.
- Add tests proving touch layout hit regions remain stable.
- Add or update a no-regression test showing the meter does not affect shot physics/scoring outputs.

## Non-Goals

- No shot buffs.
- No cooldowns, costs, gates, unlocks, energy, gems, gacha, or monetization.
- No new shot buttons.
- No input behavior changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Power meter responds visually to existing input data.
- Meter has no gameplay effect.
- Move/swing/serve hit regions are unchanged.
- Controls remain readable and concept-like.

## Planning Notes

- Every reviewer called the power meter a scope-creep risk. Treat it as an instrument panel only.
