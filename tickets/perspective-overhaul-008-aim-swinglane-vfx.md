---
id: PERSP-008
phase: perspective-overhaul
status: done
priority: high
parallel_group: input-overlay
depends_on: [PERSP-001, PERSP-002]
blocks: [PERSP-009, PERSP-010]
owner: unassigned
last_updated: 2026-05-11
---

# PERSP-008 - Aim Indicator, Swing Lane, and VFX in the New Projection

## Goal

The swing lane preview, racket tip, contact VFX, point-bursts, and any aim/serve indicator must all draw through the new projection at the correct z plane so the player can trust what they see for hitting decisions.

## Reference

- `docs/art/concept-screenshot.png` — aim indicator and ball arc both look like they live on the court, not on top of it.

## Suggested file ownership

- `dink_rivals/lib/game/components/racket_component.dart` (swing lane already lives here)
- `dink_rivals/lib/game/components/vfx/*.dart`
- `dink_rivals/lib/game/components/touch_controls_component.dart` (only for the on-court aim ring / serve indicator, if it draws one in court space — the on-screen joystick stays in screen space)
- `dink_rivals/test/vfx_layer_component_test.dart`

Do not change `InputSystem`, `TouchInputController`, `ShotSystem`, or `ServeFlowSystem`.

## What is wrong today

- `RacketComponent._drawPlayerSwingLane` projects `path.start` and `path.end` at `z = Tuning.racketContactZ` — correct in principle. But the lane stroke width is scaled by `depthScale = game.depthScaleForY(state.position.y)` *once*. With the new perspective the start and end of the lane can be at materially different depths (the lane extends in court y), so the stroke should taper between start and end.
- VFX impact rings and point-bursts (`vfx_layer_component.dart`) typically draw at the ball's contact court position. Whatever they multiply by `depthScaleForY` for size must use *the contact point's* `courtY`, not the hitter's.
- Any on-court aim ring (if present) needs the same treatment.
- HUD elements (scoreboard, feedback banner, joysticks, SERVE button) remain in screen space — do not project them.

## Requirements

- Swing lane:
  - `start` and `end` are projected at `z = Tuning.racketContactZ` using `game.courtToWorld(...)`.
  - The lane is drawn as a series of segmented quads (e.g. 6 sub-segments) so the stroke width can taper from `depthScaleForY(path.start.y)` to `depthScaleForY(path.end.y)`. Alternative acceptable: draw two narrow polygons (lane + border) using projected corners for the four end-points of the lane rectangle.
- Contact VFX (bounce ring, shot burst, point burst) uses `depthScaleForY(courtPosition.y)` at the VFX's own court position.
- Ball trail (covered by PERSP-004) is unchanged here.
- HUD components (`ScoreComponent`, `RallyFeedbackComponent`, `TouchControlsComponent` joysticks) are not modified.

## Tests to extend

- `swing lane stroke at path.start equals depthScaleForY(start.y) * baseStroke` (with `baseStroke` exposed for test) — and similarly for `end`.
- `vfx contact ring at courtY=Court.bottom is wider than at courtY=Court.top for the same ring radius value`.
- `point burst draws at courtToWorld(Vector2(Court.width/2, Court.netY), 0)` (precise equality), to assert the point burst is a court-anchored effect, not screen-space.

## Verification

```bash
flutter analyze
flutter test
```

Manual: trigger a drive and a smash on emulator. Confirm the swing lane visibly tapers along its length and the contact VFX size differs between rallies near the player and near the rival.

## Acceptance criteria

- All court-anchored overlays draw through `game.courtToWorld` and `depthScaleForY` at the **overlay's own court position**.
- Swing lane visibly tapers along its length.
- HUD elements still draw in screen space.
- Tests pass.

## Implementation notes

(Filled in by the implementing agent.)
