---
id: P1-001
phase: 1
status: done
priority: high
parallel_group: A
depends_on: []
blocks: [P1-003, P1-006, P1-007]
owner: codex
last_updated: 2026-05-10
---

# P1-001 - Match State and Scoring System

## Goal

Add the state and pure scoring logic required for a first-to-7 rally-scoring match.

## Build Spec Coverage

Phase 1 tasks:

- Add `MatchState`.
- Add `ScoringSystem`.
- Add match-over state.
- Add unit tests for scoring.

## Suggested File Ownership

- `dink_rivals/lib/game/models/match_state.dart`
- `dink_rivals/lib/game/systems/scoring_system.dart`
- `dink_rivals/test/scoring_system_test.dart`
- `dink_rivals/lib/game/config/tuning_constants.dart` only for score constants.

Avoid editing `dink_rivals/lib/game/dink_rivals_game.dart`; integration belongs to `P1-003`.

## Requirements

- Add a `MatchState` model with player score, opponent score, serving side, point-in-progress flag, match-over flag, rally count, player dink-classification count, player smash-classification count, and longest rally.
- Add a `ScoringSystem` that awards one rally-scoring point to the winning side.
- First side to `Tuning.quickMatchWinningScore` wins; Phase 1 win-by-1.
- Keep the system pure Dart and easy to unit test.
- Preserve the build spec rule that Phase 1 stays gray-box: no menu, art, save data, or progression.

## Verification

Run:

```bash
cd dink_rivals
flutter analyze
flutter test
```

Required tests:

- Player point increments player score.
- Opponent point increments opponent score.
- Match ends at 7.
- Scores do not continue changing after match over unless an explicit reset method is called.
- Rally count and longest rally update deterministically.

## Acceptance Criteria

- New scoring tests pass.
- No Flame render layer is needed for scoring tests.
- No gameplay integration is attempted in this ticket.
- `tickets/status.md` and this ticket metadata are updated.
