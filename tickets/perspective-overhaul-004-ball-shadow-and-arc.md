---
id: PERSP-004
phase: perspective-overhaul
status: done
priority: high
parallel_group: entities
depends_on: [PERSP-001, PERSP-002]
blocks: [PERSP-009, PERSP-010]
owner: unassigned
last_updated: 2026-05-11
---

# PERSP-004 - Ball, Shadow, and Trail in the New Projection

## Goal

Sell the ball arc as 3D under the new perspective: the ball sprite floats above its shadow by an amount that grows with both `z` and how near to the camera the ball is; the shadow stays glued to the ground projection; the ball trail follows the same lift function.

## Reference

- `docs/art/concept-screenshot.png` — yellow trail clearly arcs above the court, shadow is detached from the ball, gap is largest at the apex.

## Suggested file ownership

- `dink_rivals/lib/game/components/ball_component.dart`
- `dink_rivals/lib/game/components/shadow_component.dart`
- `dink_rivals/lib/game/components/vfx/ball_trail_component.dart` (if present in `lib/game/components/vfx/`)
- `dink_rivals/test/ball_component_test.dart`
- `dink_rivals/test/projected_shadow_test.dart`

Do not change `BallState`, `BallPhysicsSystem`, or `ShotSystem`.

## What is wrong today

- `BallComponent` already calls `game.courtToWorld(Vector2(x, y), z)` — correct in principle. But `BallComponent.visualRadiusFor(z, depthScale) = (4.2 + heightScale * 4.0) * depthScale` uses `z/100` as `heightScale`. With the new projection the same `z=50` looks different near vs. far, but the radius formula only scales by `depthScale` not by `zLiftForY`. That is acceptable — the lift in the position projection already handles it — but the formula should be re-derived so radius growth matches the projection's expected screen size, not a hand-tuned constant.
- `ShadowComponent` already pins to `game.courtToWorld(Vector2(ball.x, ball.y), 0)`. The ellipse half-widths are scaled by `depthScale` only, which is fine; but the *vertical offset* of the shadow's drawn ellipse uses `ProjectedShadow.directionalOvalRect(elevationFraction: heightScale, offsetScale: 0.8)` — that constant offset does not match the new `zLiftForY`. The shadow should not move; the ball does. The drawn shadow should sit *at* the projected ground position, not be offset by elevation.
- Ball trail (in `vfx_layer_component.dart` and friends) reuses the projection at draw time, which is fine, but its line-width is depth-scaled by an independent curve. Switch it to `game.depthScaleForY(courtY)` at each sampled court point so it tapers naturally.

## Requirements

- Ball center draws at `game.courtToWorld(Vector2(x, y), z)`. No extra offsets.
- Shadow center draws at `game.courtToWorld(Vector2(x, y), 0)`. No elevation-driven offset on the shadow itself; the gap is now provided entirely by the ball's `z` lift.
- Shadow half-widths and opacity remain scaled by `depthScale` and `z` as today — wider/lighter at high altitude, tight/dark at z≈0. Document the curve in code.
- Ball radius continues to grow modestly with `z` (legibility), but the maximum-near vs. minimum-far ratio must equal `maxDepthScale / minDepthScale` from PERSP-001. No independent multipliers.
- Ball trail samples court (x, y, z) over time; each sample is projected with `game.courtToWorld(sample, z)`. Trail stroke width scales with `depthScaleForY(sample.y)` at each sample.

## Tests to extend

- `ball draws at courtToWorld(pos, z)` (precise equality).
- `shadow draws at courtToWorld(pos, 0)` and is unaffected by ball.z position.
- `screen gap between ball center and shadow center at courtY = Court.bottom is greater than the gap at courtY = Court.top for the same z = 100`. This is the headline 2.5D test.
- `ball radius scales by depthScaleForY(ball.y)`.
- Trail sample stroke width: assert two samples at different y produce different widths via the public test API.

## Verification

```bash
flutter analyze
flutter test test/ball_component_test.dart test/projected_shadow_test.dart
flutter test
```

Manual: trigger a lob during a Quick Match smoke run and confirm the ball/shadow gap visibly grows as the ball arcs and is larger near the player than across the net.

## Acceptance criteria

- Ball, shadow, and trail use the projection from PERSP-001 with no per-component perspective hacks.
- Headline test (`ball/shadow gap is larger near than far for the same z`) passes.
- `flutter analyze` and `flutter test` pass.

## Implementation notes

(Filled in by the implementing agent.)
