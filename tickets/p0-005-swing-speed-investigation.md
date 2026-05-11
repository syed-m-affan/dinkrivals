---
id: P0-005
phase: 0
status: in_progress
priority: medium
parallel_group: A
depends_on: []
blocks: [P0-002]
owner: claude
last_updated: 2026-05-10
---

# P0-005 - Swing Speed Impact + Ball Speed Tuning

## Goal

Make the difference between a soft and a firm swing actually feelable, and slow the ball down overall so rallies can build.

## Findings

Reading `ShotSystem.attemptRacketContact`:

- `swingPowerScale = 0.62` plus `racketSwingRadiansPerPixel = 0.016` × `racketReach = 42` produces tangential speeds of 2000+ from even a small drag, but the output is clamped between `softContactSpeed = 88` and `firmContactSpeed = 176`. Anything beyond a trivial flick saturates the cap, so swing speed has almost no expressive range in practice.
- The post-saturation outputs (88-176) combined with low gravity already feel fast at the current court scale.

## Fix

- Lower swing input sensitivity so the dynamic range of "soft vs firm" lives inside the speed clamp:
  - `racketSwingRadiansPerPixel`: 0.016 → 0.011
  - `swingPowerScale`: 0.62 → 0.18
- Tighten ball top-end:
  - `firmContactSpeed`: 176 → 150
  - `driveSpeedXY`: 132 → 116
  - `smashSpeedXY`: 170 → 150
- Make drive vs dink contrast clearer:
  - `driveContactThreshold`: 124 → 118 (drive easier to reach with a real fast swing)
  - `driveArcGravityScale`: 0.42 → 0.36 (drive flatter)
  - `dinkArcGravityScale`: 0.75 → 0.92 (dink drops faster)

## Verification

- `flutter analyze`, `flutter test` (existing "faster swing → faster ball" test must still pass — it uses 45 vs 180 swing which now lives inside the working range).
- On device: slow controlled swing produces an obviously soft ball; whip swing produces an obviously fast ball.

## Acceptance Criteria

- Existing tests pass.
- Soft / firm swings produce visibly different shot speeds and arcs.
- Average ball speed slower than 2026-05-10 build.
