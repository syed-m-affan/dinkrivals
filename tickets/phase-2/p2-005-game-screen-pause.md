---
id: P2-005
phase: 2
status: done
priority: high
parallel_group: E
depends_on: [P2-001]
blocks: [P2-006, P2-007]
owner: claude
last_updated: 2026-05-10
---

# P2-005 - Game Screen Wrapper and Pause/Resume

## Goal

Wrap `DinkRivalsGame` in a real Flutter screen with a Pause button, a Pause overlay, and a Resume / Return-to-Menu flow. While paused, gameplay must fully freeze (no physics, no AI, no input consumption).

## Build Spec Coverage

Phase 2 tasks:

- Create game screen wrapper.
- Add pause/resume.
- Add return-to-menu flow (resume + quit paths only; the post-match summary belongs to `P2-006`).

## Suggested File Ownership

- `dink_rivals/lib/screens/game_screen.dart`.
- `dink_rivals/lib/game/dink_rivals_game.dart` (minimal additions — pause flag, controlled `update(dt)` short-circuit).
- `dink_rivals/lib/game/components/pause_overlay_component.dart` **or** a Flutter `Overlay` widget — pick one and document the choice in implementation notes; do not ship both.
- `dink_rivals/test/dink_rivals_game_pause_test.dart` (or equivalent) testing the pause short-circuit on `update(dt)`.

Do not modify the main menu, settings, save service, router definitions, or any other `lib/screens/**` file. Do not touch the end-match summary — that is `P2-006`.

## Requirements

- The `/game` route renders a `Stack` with the `GameWidget<DinkRivalsGame>` on the bottom and a small Pause button overlay on top. The Pause button must not overlap the movement stick, swing stick, score, feedback text, or reset button. Reuse the touch-control safe zones documented in `dink_rivals_game.dart`.
- Tapping Pause:
  - Sets a `paused` flag on `DinkRivalsGame`.
  - Shows a Pause overlay (Resume / Return to Menu).
  - Clears any held movement/swing pointer input on entry so the player does not return to a held stick.
- While paused, `update(dt)` must early-return before running input, movement, shot, physics, and AI systems. Rendering may still occur.
- Resume:
  - Dismisses the overlay.
  - Unsets `paused`.
  - Does not snap the ball or player to a new state. Rally continues from the paused state.
- Return to Menu from pause:
  - Calls `DinkRivalsGame.resetPoint()` (existing API) before navigating.
  - Resets `MatchState` so the next Quick Match starts at 0-0.
  - Routes back to `/`.
- Hardware back press on Android while in `/game` opens the pause overlay (if not already open). It does **not** silently quit the match.

## Design Notes

- Keep pause logic in `DinkRivalsGame` itself, not in a sibling system. The game owns its own update gate.
- Do not add a Settings entry inside the pause menu in this ticket; settings live on `/settings`. A future polish ticket can add an in-pause shortcut after Phase 2.
- Do not implement match-over UI here. When `matchState.matchOver` becomes true, this ticket only needs to ensure the game stops responding to input. The summary screen is `P2-006`'s responsibility.

## Verification

```bash
cd dink_rivals
flutter analyze
flutter test
flutter build apk --debug
```

Required tests:

- Pausing `DinkRivalsGame` causes `update(dt)` to leave ball/player state unchanged.
- Resuming restores normal `update(dt)` behavior.
- `resetPoint()` + pause exit leaves a sane `MatchState` (0-0, not match-over).

Manual smoke:

- Start a Quick Match, pause mid-rally — ball freezes, opponent freezes.
- Resume — rally continues without a teleport.
- Pause → Return to Menu → start new Quick Match — score reads 0-0.
- Hardware back from `/game` opens the pause overlay.

## Acceptance Criteria

- Pause fully freezes physics, AI, and input handling.
- Resume continues the rally without disruption.
- Return to Menu cleans up `MatchState` so the next match is fresh.
- Pause button does not interfere with existing on-screen controls.
- No regressions on existing tests.
- `tickets/status.md` and this ticket metadata are updated.
