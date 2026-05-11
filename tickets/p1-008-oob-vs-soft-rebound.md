---
id: P1-008
phase: 1
status: in_progress
priority: high
parallel_group: A
depends_on: []
blocks: [P1-007]
owner: claude
last_updated: 2026-05-10
---

# P1-008 - Out-of-Bounds Faults Masked by Soft Rebound

## Problem

During the 2026-05-10 playtest, the out-of-bounds fault never triggered — the ball always rebounded back into the court instead of landing OOB.

## Root Cause

`BallPhysicsSystem.update` unconditionally clamps the ball to the court rectangle and reverses its velocity each frame (the seventh-pass "soft boundary rebound"). Because the rebound runs every frame the ball is airborne, the ball never actually *lands* past the boundary — `landedOutOfBounds` stays false and `MatchRulesSystem.evaluatePhysicsResult` never returns the OOB fault.

The soft rebound was added in Phase 0 to stop the ball getting stuck at court edges when it had come to rest. It should not be running on a live in-play ball.

## Fix

Gate the soft rebound on `!ball.isInPlay` (i.e., only nudge stationary/resting balls back into the court). While `ball.isInPlay`, allow the ball to fly past the boundary and let the next ground contact resolve to `landedOutOfBounds = true` and the OOB fault.

## Verification

- New test: in-play ball driven past `Court.right` should land OOB and produce `landedOutOfBounds = true`.
- Existing edge-rebound test (post-rest ball) should still pass.
- On device: hitting the ball hard into the side fence triggers FAULT: OUT.

## Acceptance Criteria

- OOB faults trigger in real gameplay.
- Resting balls still don't pin to court edges.
- All existing tests green.
