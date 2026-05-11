---
id: P5E-002
phase: 5E
status: done
priority: high
parallel_group: B
depends_on: [P5E-001]
blocks: [P5E-003, P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5E-002 - Contact, Bounce, and Shot VFX Wiring

## Goal

Wire short hit, bounce, dink, drive, lob, and smash effects to existing gameplay events without changing gameplay logic.

## Build Spec Coverage

Phase 5E - Ball Trail, Contact VFX, and Rally Juice:

- Small hit spark/paddle flash on clean contact.
- Bounce dust/ring on court contact.
- Smash impact effect.
- Events are easier to read.

## Suggested File Ownership

- `dink_rivals/lib/game/dink_rivals_game.dart`
- `dink_rivals/lib/game/components/vfx/`
- `dink_rivals/lib/game/models/shot_type.dart` (read-only unless helper mapping is needed)
- `dink_rivals/test/vfx_component_test.dart`
- `tickets/status.md`

Do not edit `ShotSystem`, `BallPhysicsSystem`, scoring, rules, or AI behavior.

## Requirements

- Spawn a small contact effect on successful player and opponent racket contact.
- Spawn a bounce effect only when `BallPhysicsResult.groundContact` is true.
- Use `ShotSystem.lastShotType` to style contact effects for dink/drive/lob/smash.
- Keep effect lifetimes short and avoid covering the ball for more than a brief moment.
- Ensure VFX do not fire while paused or before the relevant gameplay event.

## Non-Goals

- No ball trail.
- No point banner.
- No screen shake.
- No changes to audio/haptics behavior except respecting existing event timing.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- Contact and bounce events are visually clearer.
- VFX do not change physics, scoring, AI, or controls.
- Existing shot/physics/rules tests remain green.

## Implementation Notes

- Existing player/opponent contact events now spawn hit/smash contact VFX.
- Existing physics ground-contact events now spawn bounce-ring VFX.
- Claude review flagged ball-occlusion risk; smash/bounce sizes, lifetimes, and alpha curve were reduced before verification.
