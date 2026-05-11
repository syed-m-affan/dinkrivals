---
id: P0-003
phase: 0
status: in_progress
priority: high
parallel_group: A
depends_on: []
blocks: [P0-002]
owner: claude
last_updated: 2026-05-10
---

# P0-003 - Movement Pointer Survives Point Reset

## Goal

When a point ends and `resetPoint()` runs, the left movement joystick should keep tracking a finger that is still on the screen. Today the user has to lift and replant their finger before they can move again, which can cost them the next ball.

## Reproduction

1. Hold the left joystick in any direction.
2. Let the opponent score (or trigger any fault).
3. After the reset, observe that the player no longer moves until the finger is lifted and re-pressed on the joystick.

## Root Cause

`DinkRivalsGame.resetPoint()` nulls `_movementPointerId` and calls `inputSystem.clearMovement()`. Subsequent `onDragUpdate` events for the still-held pointer no longer match `_movementPointerId`, so the joystick reading stays at zero.

## Fix

Do not null `_movementPointerId` / `_swingPointerId` or clear input state in `resetPoint()`. Let Flame's drag/tap end events clean up naturally when the user actually lifts. The match-end / pause flows that *do* need a hard input wipe should call an explicit reset there.

## Verification

- `flutter analyze`, `flutter test`, `flutter build apk --debug`.
- On device: hold the joystick through a point loss; player keeps moving after reset.

## Acceptance Criteria

- Movement and swing pointers survive `resetPoint()`.
- Pause flow still freezes movement.
- No regression in existing pointer tests.
