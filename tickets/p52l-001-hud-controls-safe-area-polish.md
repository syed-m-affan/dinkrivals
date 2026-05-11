---
id: P52L-001
phase: 5.2I
status: done
priority: medium
parallel_group: H
depends_on: [P52J-001, P52G-001, P52H-001]
blocks: [P52M-001]
owner: codex
last_updated: 2026-05-11
---

# P52L-001 - HUD Controls and Safe-Area Polish

## Goal

Perform the final HUD/control proportion pass after scoreboard, feedback, and power-meter work are in place.

## Build Spec Coverage

Phase 5.2I - HUD Control Polish:

- Pause panel proportion check.
- Safe-area validation.
- Top HUD / feedback / pause coexistence.
- Control visual polish closeout.

## Suggested File Ownership

- `dink_rivals/lib/game/components/touch_controls_component.dart`
- `dink_rivals/lib/game/components/score_component.dart` only for spacing adjustments
- `dink_rivals/lib/game/components/rally_feedback_component.dart` only for spacing adjustments
- `dink_rivals/lib/screens/game_screen.dart`
- `dink_rivals/test/touch_input_controller_test.dart`
- `dink_rivals/test/score_component_test.dart`
- `docs/art/phase-5.2-hud-safe-area.png`
- `tickets/status.md`

Do not rework feature behavior from P52G, P52H, or P52J.

## Requirements

- Check scoreboard, pause, and feedback banner coexistence on tall/notched Android layouts.
- Check joystick, swing stick, serve button, power meter, and labels for overlap with gesture/navigation areas.
- Preserve touch hit regions from P52J.
- Make only small spacing/proportion fixes needed for readability.
- Capture a screenshot showing active controls and feedback/HUD.

## Non-Goals

- No new HUD features.
- No input behavior changes.
- No menu/roster/settings redesign.
- No gameplay changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Top HUD, feedback banner, and pause do not overlap.
- Bottom controls remain readable, reachable, and hit-region stable.
- Safe-area behavior remains valid on tall/notched Android devices.

## Planning Notes

- This ticket serializes final control/HUD polish after the higher-risk HUD tickets land.

## Implementation Notes

- Implemented: adjusted scoreboard, feedback banner, power meter, and controls together; emulator smoke confirms top/bottom safe-area readability.
- Verification: `flutter analyze`, `flutter test`, `flutter build apk --debug`, emulator install/launch on `emulator-5554`, and `docs/art/phase-5.2-gameplay-emulator-smoke.png`.
