---
id: PERSP-002
phase: perspective-overhaul
status: done
priority: critical
parallel_group: foundation
depends_on: [PERSP-001]
blocks: [PERSP-003, PERSP-004, PERSP-005, PERSP-006, PERSP-007, PERSP-008, PERSP-009, PERSP-010]
owner: unassigned
last_updated: 2026-05-11
---

# PERSP-002 - Court Layout and Framing Pass

## Goal

Fit the new pinhole-projected court to a portrait phone screen without flattening the trapezoid the projection produces. Today `CourtLayoutSystem.resize` clamps the scale so the court fills available height, which can crush the new perspective.

## Reference

- `docs/art/concept-screenshot.png` — court occupies the central ~62% of the screen height, the HUD strip is at the top, controls at the bottom, near baseline is wider than far baseline by a clearly visible ratio.

## Suggested file ownership

- `dink_rivals/lib/game/systems/court_layout_system.dart`
- `dink_rivals/test/court_layout_system_test.dart`

Do not modify `CourtProjection` (PERSP-001 owns it) or any rendering component.

## What is wrong today

`CourtLayoutSystem.resize`:

- Computes the bounding box of the four projected corners at z=0.
- Reserves a top HUD band and a generous bottom controls band (`minBottomControlReserve = 430`).
- Scales by `min(size.x * 0.86 / projectedWidth, availableHeight / projectedHeight)`.

With the new projection (PERSP-001), `projectedHeight` will be **larger** than today because the near-side y is now non-linearly farther down. The current clamp will then shrink `_courtScale` and undo the trapezoid amplification.

## Requirements

- Pick `_courtScale` so the new trapezoidal court visibly fills the gameplay area without being clipped at the top or bottom. The full bottom baseline (near edge of court) must remain on screen, and the entire near sideline must be drawn even when characters are at their start positions.
- Keep `minBottomControlReserve` honored: virtual joysticks and the SERVE button overlay must not overlap the player's start baseline.
- HUD top reserve stays ≥ `minTopHudReserve` (72 logical screen px) so the scoreboard never overlaps the far baseline.
- Add a fit mode that prefers width-fit unless that pushes the projected court height beyond `availableHeight`, in which case fall back to height-fit *and* report the new effective horizontal margins so the bottom controls can be reflowed if necessary.
- The fit must work across the existing AVD `dink_rivals_qa` (1080x2400) and a 2436x1125 portrait viewport. Document the chosen fit policy in code comments.
- Keep `courtToWorld`, `logicalToScreen`, and `depthScaleForY` signatures stable — components in PERSP-003..008 will continue to call them through `game.courtToWorld(...)`.

## Tests to extend in `test/court_layout_system_test.dart`

- After `resize(Vector2(1080, 2400))`, the projected near baseline (court y = Court.bottom) y-coordinate is below `2400 - minBottomControlReserve - 12` (so the near baseline is in the visible play area) and the far baseline (court y = Court.top) y-coordinate is above `minTopHudReserve - 12`.
- After `resize`, the visible projected near-baseline width is at least 1.7× the projected far-baseline width (this re-asserts the PERSP-001 trapezoid through the layout transform).
- `logicalToScreen(Court.length)` is finite and positive.
- Existing layout assertions must still hold (no regressions in `courtToWorld` continuity around the net midpoint).

## Verification

```bash
flutter analyze
flutter test test/court_layout_system_test.dart
flutter test
```

Manual: run on `emulator-5554` with the AVD `dink_rivals_qa`, take a screenshot via `adb shell screencap` (see `CLAUDE.md`), and confirm the court is taller and more trapezoidal than `docs/art/perspective-before-screenshot.png` without clipping the near baseline.

## Acceptance criteria

- Layout fit policy documented inline and chosen to preserve the PERSP-001 trapezoid.
- `flutter analyze` clean, `flutter test` passes.
- Emulator screenshot recorded under `docs/art/perspective-overhaul-002-layout.png` and referenced in this ticket's implementation notes.
- Court fits a Pixel 10 Pro XL-class portrait viewport without overlapping top HUD or bottom controls.

## Implementation notes

(Filled in by the implementing agent.)
