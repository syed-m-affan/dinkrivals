---
id: P1-003
phase: 1
status: done
priority: high
parallel_group: C
depends_on: [P1-001, P1-002]
blocks: [P1-006, P1-007]
owner: codex
last_updated: 2026-05-10
---

# P1-003 - Point, Serve, and Match Flow Integration

## Goal

Wire `MatchState`, scoring, and rule results into `DinkRivalsGame` so a full first-to-7 match can be played.

## Build Spec Coverage

Phase 1 tasks:

- Add serve/start point flow.
- Add match-over state.
- Integrate scorekeeping.
- Make full match playable to 7.

## Suggested File Ownership

- `dink_rivals/lib/game/dink_rivals_game.dart`
- `dink_rivals/lib/game/systems/ball_physics_system.dart`
- `dink_rivals/lib/game/components/reset_button_component.dart`
- Integration tests only if practical; otherwise add focused unit tests around new pure helpers.

Coordinate carefully if `P1-006` is also active, because both may touch overlay/HUD data exposed by `DinkRivalsGame`.

## Requirements

- Add a `MatchState` instance to the game.
- Start each point from a serve/reset state.
- Use `MatchRulesSystem` after physics updates to decide whether the point ended.
- Use `ScoringSystem` to award points.
- Reset ball and player/opponent positions after a completed point.
- Stop active play when `matchOver` is true.
- Keep the reset button useful for debug, but do not let it corrupt score state.
- Preserve Phase 0 controls and racket hitbox behavior: left stick moves, right stick swings, and all hits come from racket contact rather than shot buttons.

## Design Notes

Use simple arcade flow:

- No detailed real pickleball side-out serving.
- Rally scoring.
- First to 7.
- Win by 1.
- Serving side can be tracked but does not need full serve rotation.

## Verification

Run:

```bash
cd dink_rivals
flutter analyze
flutter test
flutter build apk --debug
```

Manual checks:

- Start a point.
- Force player point.
- Force opponent point.
- Confirm match ends at 7.
- Confirm reset button does not crash or leave impossible state.

## Acceptance Criteria

- A match can progress from 0-0 to match over.
- Rule outcomes award points correctly.
- Existing Phase 0 tests still pass.
- No menu, end-match screen, persistence, or ads are added.
- `tickets/status.md` and this ticket metadata are updated.
