---
id: P2-006
phase: 2
status: done
priority: high
parallel_group: F
depends_on: [P2-001, P2-005]
blocks: [P2-007]
owner: claude
last_updated: 2026-05-10
---

# P2-006 - End-Match Summary Screen

## Goal

When `MatchState.matchOver` flips true, transition out of the live game scene into an End Match summary screen that shows the result and offers Rematch / Return to Menu.

## Build Spec Coverage

Phase 2 tasks:

- Add end-match summary.
- Add return-to-menu flow (the post-match path; the pause path is `P2-005`).

## Suggested File Ownership

- `dink_rivals/lib/screens/end_match_screen.dart`.
- `dink_rivals/lib/screens/game_screen.dart` (only to wire the match-over → navigate transition).
- `dink_rivals/lib/game/dink_rivals_game.dart` (only if a small callback hook is needed to surface match-over to the Flutter layer).
- `dink_rivals/test/end_match_screen_test.dart` (widget test).

Do not edit `MatchState`, `ScoringSystem`, `MatchRulesSystem`, or the save service. Reuse what `Phase 1` already produces.

## Requirements

- When `MatchState.matchOver` becomes true, the game screen should detect the transition once and navigate to `/end-match` (push, do not replace, so back doesn't return to a stale game scene; pair with route-level guards so back from `/end-match` does not re-enter active gameplay).
- End-match screen shows:
  - Winner banner: "YOU WIN" or "OPPONENT WINS".
  - Final score (e.g. `7 - 4`).
  - Rally count for the match and the longest rally (already tracked in `MatchState`).
  - Two buttons:
    - **Rematch** → resets the match (`DinkRivalsGame.resetPoint()` + fresh `MatchState`) and routes back to `/game`.
    - **Return to Menu** → routes back to `/`.
- On entering the end-match screen, ensure the live game is paused or otherwise stops consuming input, so rendering behind the screen never advances physics.
- Increment `SaveService` `matchesCompleted` exactly once per completed match. This field exists for `P3-*` ad gating; do not display it.

## Design Notes

- Do not show rewarded-ad buttons, double-stars, or any monetization affordance here. `Phase 3` owns ad placement.
- Do not show character or court unlocks; `Phase 6` owns the tournament + unlock loop.
- Do not persist match history beyond the `matchesCompleted` counter. There is no detailed stat screen in Phase 2.

## Verification

```bash
cd dink_rivals
flutter analyze
flutter test
flutter build apk --debug
```

Required tests:

- Widget test: the end-match screen renders winner, final score, rally count, longest rally.
- Widget test: Rematch tap triggers reset and navigation back to `/game`.
- Widget test: Return-to-Menu tap routes to `/`.
- Save-service interaction: completing a match increments `matchesCompleted` once.

Manual smoke:

- Win a match → end-match screen shows YOU WIN with correct score.
- Tap Rematch → fresh 0-0 match starts.
- Force loss → end-match shows OPPONENT WINS.
- Tap Return to Menu → app sits cleanly on `/`.

## Acceptance Criteria

- End-match screen appears exactly once per completed match.
- Rematch and Return-to-Menu both leave `MatchState` in a clean starting state.
- `matchesCompleted` increments by one per completed match, regardless of result.
- No ad UI, unlock UI, or progression UI appears.
- No regressions on existing tests.
- `tickets/status.md` and this ticket metadata are updated.
