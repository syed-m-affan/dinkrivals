---
id: P5D-002
phase: 5D
status: todo
priority: high
parallel_group: B
depends_on: [P5D-001]
blocks: [P5D-003, P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5D-002 - Expanded Character Sprite Sheets and Animation States

## Goal

Expand basic Phase 5 player/opponent sprites into richer ready, run, swing, hit-confirm, point-win, and point-loss animations without changing hit detection.

## Build Spec Coverage

Phase 5D - Character Personality and Animation Polish:

- Idle, run, ready, swing, hit-confirm, point-win, and point-loss poses.
- 4-frame run cycles where practical.
- Swing anticipation and follow-through frames.
- Animation driven by existing state and match events.

## Suggested File Ownership

- `dink_rivals/assets/images/sprites/`
- `dink_rivals/lib/game/components/player_component.dart`
- `dink_rivals/lib/game/components/opponent_component.dart`
- `dink_rivals/lib/game/dink_rivals_game.dart` only for exposing existing match-event cues if needed
- `dink_rivals/test/player_component_test.dart`
- `tickets/status.md`

Do not edit `ShotSystem`, `BallPhysicsSystem`, `MatchRulesSystem`, or hitbox constants.

## Requirements

- Add expanded sprite sheets or compatible frames for ready, hit-confirm, point-win, and point-loss states.
- Preserve current idle/run/swing behavior and primitive fallback.
- Drive animation from existing `PlayerState`, `MatchState`, and existing point/contact events.
- Keep swing visuals synchronized with contact enough that the paddle and ball contact moment remain readable.
- Add tests for animation-state selection where possible without requiring pixel rendering.

## Non-Goals

- No movement speed, hitbox, racket reach, or timing changes.
- No character stats or unlocks.
- No roster redesign.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- Characters have visibly richer animation states.
- Player/opponent remain distinct at gameplay scale.
- No animation hides the paddle or ball contact moment.
- Existing physics, shot, and rules tests remain green.

