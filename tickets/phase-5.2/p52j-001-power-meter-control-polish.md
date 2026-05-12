---
id: P52J-001
phase: 5.2I
status: done
priority: high
parallel_group: H
depends_on: [P52A-002]
blocks: [P52L-001, P52M-001]
owner: codex
last_updated: 2026-05-11
---

# P52J-001 - Serve Meter and Swing-Control Polish

## Goal

Polish the manual controls while preserving all control hit regions and shot physics. The obsolete swing power meter concept is removed; only serve charge keeps percentage/ring feedback.

## Build Spec Coverage

Phase 5.2I - Serve Meter and HUD Control Polish:

- Serve charge meter.
- D-pad chevrons.
- Refined swing/aim control presentation.
- Pause/control proportion check.

## Suggested File Ownership

- `dink_rivals/lib/game/components/touch_controls_component.dart`
- `dink_rivals/lib/game/systems/input_system.dart` only for cleanup if needed
- `dink_rivals/lib/game/systems/touch_input_controller.dart` only for tests proving hit regions are unchanged
- `dink_rivals/test/touch_input_controller_test.dart`
- `dink_rivals/test/shot_system_test.dart` only for no-physics-regression assertions if needed
- `docs/art/phase-5.2/phase-5.2-final-serve.png`
- `tickets/status.md`

Coordinate with P52L before making broader pause/control layout changes.

## Requirements

- Keep serve charge feedback near the serve button using existing serve charge data.
- Do not add swing power feedback for drive/lob/smash; the manual swipe control intentionally has miss risk rather than a power bar.
- Add D-pad chevrons inside the move ring.
- Refine swing/aim control presentation.
- Preserve existing touch hit regions, pointer behavior, and input contract.
- Add tests proving touch layout hit regions remain stable.
- Add or update no-regression coverage if touch regions or shot physics are touched.

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

- Serve meter responds visually to existing serve charge data.
- No swing power meter is rendered.
- Move/swing/serve hit regions are unchanged.
- Controls remain readable and concept-like.

## Planning Notes

- Every reviewer called the power meter a scope-creep risk. Later playtest
  feedback rejected the swing power bar, so the final scope keeps serve charge
  feedback only.

## Implementation Notes

- Implemented: added move-control chevrons and retained visual-only serve charge
  feedback while preserving touch layout/hit regions. The earlier swing power
  meter idea was removed after playtest feedback.
- Verification: `flutter analyze`, `flutter test`, `flutter build apk --debug`, emulator install/launch on `emulator-5554`, and `docs/art/phase-5.2/phase-5.2-gameplay-emulator-smoke.png`.
