---
id: P0-004
phase: 0
status: in_progress
priority: high
parallel_group: A
depends_on: []
blocks: [P0-002]
owner: claude
last_updated: 2026-05-10
---

# P0-004 - Serve Mechanic: Ball-On-Racket + Serve Button

## Goal

Replace "swing to serve" with a deliberate serve: the ball rests on the racket tip until the player taps a SERVE button, at which point it launches in the racket-aim direction.

## Motivation

Playtest 2026-05-10 surfaced that serving feels off — the player has to bump the static ball with the racket, which is inconsistent and unsatisfying. A discrete serve action mirrors real pickleball and removes the racket-positioning fiddle.

## Behavior

- While `ball.isInPlay == false`, the ball is *attached* to the player's racket tip and inherits its position each frame.
- The swing stick acts purely as an aim control during the serve state — no auto-launch on swing.
- A round SERVE button is rendered between the movement and swing joysticks (bottom-center). Visible only while `!ball.isInPlay`.
- Tapping SERVE calls a new `ShotSystem.serve(...)` (or reuses `attemptRacketContact` with a synthetic swing velocity along racket direction) that launches the ball forward along the current racket direction at `Tuning.serveMinOutputSpeed` with `Tuning.serveMinLift` arc.
- After the serve, normal in-play racket contact rules apply.

## Suggested File Ownership

- `dink_rivals/lib/game/dink_rivals_game.dart`
- `dink_rivals/lib/game/systems/shot_system.dart`
- `dink_rivals/lib/game/config/tuning_constants.dart`
- `dink_rivals/test/shot_system_test.dart`

## Verification

- New unit test: `serve()` launches ball forward at min speed + lift.
- Existing serve tests updated.
- On device: clean, predictable serve in the aim direction.

## Acceptance Criteria

- Ball visibly attaches to racket tip when not in play.
- SERVE button only appears in serve state and is hit-testable.
- Tapping SERVE puts the ball in play with consistent speed/arc along racket direction.
- No regression in in-play swing contact behavior.
