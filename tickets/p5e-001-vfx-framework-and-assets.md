---
id: P5E-001
phase: 5E
status: todo
priority: high
parallel_group: A
depends_on: [P5A-003]
blocks: [P5E-002, P5E-003]
owner: unassigned
last_updated: 2026-05-11
---

# P5E-001 - VFX Framework and Placeholder Assets

## Goal

Create a lightweight deterministic VFX layer and placeholder assets for contact, bounce, trail, smash, and point feedback.

## Build Spec Coverage

Phase 5E - Ball Trail, Contact VFX, and Rally Juice:

- VFX asset folder and lightweight effect components.
- Short deterministic lifetimes.
- Debug toggles only if needed.

## Suggested File Ownership

- `dink_rivals/assets/images/vfx/`
- `dink_rivals/lib/game/components/vfx/` (new directory)
- `dink_rivals/lib/game/config/debug_flags.dart`
- `dink_rivals/lib/game/dink_rivals_game.dart` only to mount the VFX component
- `dink_rivals/test/vfx_component_test.dart` (new, if practical)
- `tickets/status.md`

Do not wire gameplay events in this ticket beyond mounting an inert VFX layer.

## Requirements

- Generate placeholder VFX sprites for hit spark, bounce ring/dust, ball trail segment, smash flash, and point burst.
- Add a VFX component or system capable of spawning short-lived visual effects deterministically.
- Mount the VFX layer in the game at the correct draw order from P5A-003.
- Add a debug flag only if needed for performance testing.
- Keep all effects disabled/inert until P5E-002/P5E-003 wire events.

## Non-Goals

- No event wiring for hit/bounce/point yet.
- No physics, scoring, AI, or sound changes.
- No screen shake.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- VFX assets and an inert VFX layer exist.
- Effect lifetime/update behavior is deterministic.
- No gameplay behavior changes.

