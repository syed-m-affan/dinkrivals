---
id: PERSP-005
phase: perspective-overhaul
status: done
priority: high
parallel_group: entities
depends_on: [PERSP-001, PERSP-002]
blocks: [PERSP-009, PERSP-010]
owner: unassigned
last_updated: 2026-05-11
---

# PERSP-005 - Net Rebuild for Forced Perspective

## Goal

Rebuild `NetComponent` so the net's two posts have screen-space heights that respect the new projection — the back-court (far) side of the net is shorter than the near-court side because both top cord and bottom cord are projected through the same pinhole camera.

## Reference

- `docs/art/concepts/concept-screenshot.png` — net cord is a clean line that *looks* parallel to the baseline but is shorter on the far side; mesh strokes converge with the side lines; posts cast a shadow on the court that respects the new perspective.

## Suggested file ownership

- `dink_rivals/lib/game/components/net_component.dart`
- `dink_rivals/test/net_component_test.dart` (new) or extend existing component tests.

Do not modify net hit logic in `match_rules_system.dart` or `ball_physics_system.dart`.

## What is wrong today

- `NetComponent` draws ground points `(Court.left, Court.netY)` and `(Court.right, Court.netY)` and top points at z=31. The math itself is fine, but with the current weak projection the resulting trapezoid is so subtle that the net reads as a flat band. After PERSP-001 it should read correctly, but the **mesh stroke widths and the cast shadow polygon** in `NetComponent.render` use logical multipliers tuned to the old projection (`game.logicalToScreen(0.72)` for `_meshStroke`, fixed `Court.right + 5/+12` offsets for the cast shadow). Recalibrate these to the new scale.
- The "drop outline" beneath the net assumed a small lift. With stronger perspective the same offset reads as a fat shadow at the far side. Express the drop outline offset in court units passed through `courtToWorld`, not in `logicalToScreen(1.4)`.

## Requirements

- All net geometry (top cord, ground line, posts, mesh struts, diagonals) is built from court points and z-altitudes only, then projected via `game.courtToWorld(courtPos, z)`.
- The cast shadow polygon is defined in court units (e.g. offset by `(+5, +10)` court units) and projected via `game.courtToWorld(..., 0)` so it tapers correctly with the projection.
- Net height `_netHeight = 31` stays but the *stroke widths* are derived from `depthScaleForY(Court.netY)` plus an explicit clamp `[1, 4]` screen px, not arbitrary `logicalToScreen(0.72)` constants.
- Posts are drawn as a strokeline from `(Court.left/right, Court.netY)@z=0` to `(Court.left/right, Court.netY)@z=netHeight`. Their projected screen height is shorter on the far side because the projection says so; do not patch it back to equal heights.
- Ball-net contact: not handled in this codebase yet, so out of scope. If you notice ball passes through the net visually, leave it; PERSP-009 audits collisions but does not add net collision.

## Tests to extend

- After resize, `topRight.y - topLeft.y == 0` (top cord is horizontal in screen space because both ends are at the same court y and same z).
- `topRight.x - topLeft.x` (projected width of top cord) equals `groundRight.x - groundLeft.x` (projected width of ground line) — because both lie at the same court y. This is the test that confirms the net does *not* taper along the horizontal cord (it would only taper if it had depth in y, which it does not).
- Post screen height in pixels at the projected net y exceeds `12` screen px on a 2400-tall viewport.
- Cast shadow polygon vertices are all generated via `courtToWorld`.

## Verification

```bash
flutter analyze
flutter test
```

Manual: emulator screenshot of a serve state, confirm the net reads as a 3D obstacle and the mesh diagonals follow the side-line vanishing.

## Acceptance criteria

- Net geometry and shadow polygon entirely defined in court space; projected once.
- Stroke widths derive from `depthScaleForY(Court.netY)`.
- Tests pass.

## Implementation notes

`NetComponent` replays a tightly aligned crop of the painted background's net strip at `Court.netY`. The crop uses the exact same pixels as the background, so far-side balls/opponents can render under the net without adding mismatched procedural net art.
