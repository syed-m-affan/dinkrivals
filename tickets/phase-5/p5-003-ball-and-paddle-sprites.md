---
id: P5-003
phase: 5
status: done
priority: high
parallel_group: C
depends_on: [P5-001]
blocks: [P5-007]
owner: codex
last_updated: 2026-05-11
---

# P5-003 - Ball and Paddle Sprites

## Goal

Replace the yellow ball circle and the line+circle racket with retro sprite art. Preserve height-scaled rendering for the ball and rotation by `racketAngle` for the paddle. Shadow component stays untouched.

## Build Spec Coverage

Phase 5 tasks (build-spec §13):

- Add ball/paddle sprites.

## Suggested File Ownership

- `dink_rivals/assets/images/sprites/ball.png` (single frame).
- `dink_rivals/assets/images/sprites/paddle_player.png`
- `dink_rivals/assets/images/sprites/paddle_opponent.png`
- `dink_rivals/lib/game/components/ball_component.dart`
- `dink_rivals/lib/game/components/racket_component.dart`
- `dink_rivals/test/ball_component_test.dart` (new smoke test for scale curve).

Do not edit `shadow_component.dart`, `BallState`, `BallPhysicsSystem`, or `ShotSystem`.

## Requirements

- Ball sprite is rendered at `game.courtToWorld(x, y, z)` and scaled by the same `(1 + heightScale)` curve currently used in `ball_component.dart`. Pull the radius math into a single private helper so the test can assert it.
- Paddle sprite is positioned at the player/opponent racket tip and rotated by `state.racketAngle`. Player paddle uses `paddle_player.png`; opponent uses `paddle_opponent.png`. Tint via `VisualPalette` (P5-001) only if necessary.
- Stroke width / depth scaling continues to follow `depthScaleForY` for both ball and paddle.
- Shadow component remains the gray-box oval. Z-ordering: shadow under sprite ball; sprite ball above shadow (priority unchanged).
- Honor `debugFlags.useSprites` (introduced in P5-002): if `false`, fall back to existing primitive render.

## Non-Goals

- No change to ball physics, racket geometry, or shot classification.
- No new shot buttons.
- No racket trail / particle effects.
- No spin or wind.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Required tests:

- Ball sprite scale curve matches the prior circle's radius curve within tolerance (single-value assertion at z=0 and z=zMaxArc).
- Smoke test: `BallComponent` mounts with ball sprite without throwing.
- Existing physics and shot tests remain green.

## Acceptance Criteria

- Ball reads as a retro sprite that visibly scales with height.
- Player and opponent paddles read as distinct sprites that rotate with racket angle.
- Shadow still tracks under the ball.
- No regressions in `ball_physics_system_test.dart` or `shot_system_test.dart`.
- `flutter analyze` and `flutter test` pass.

## Implementation Notes

- Added generated placeholder `ball.png`, `paddle_player.png`, and `paddle_opponent.png`.
- `BallComponent` now renders the ball sprite through the prior height/depth radius curve and exposes that curve for tests.
- `RacketComponent` now renders player/opponent paddle sprites at racket tips, rotated along the current racket segment, with primitive fallback when sprites are disabled.
- `ShadowComponent`, ball state, physics, and shot classification were not changed.

## Verification

- `flutter analyze`: passed, zero issues.
- `flutter test`: passed, 96 tests.
- `flutter build apk --debug`: passed.
