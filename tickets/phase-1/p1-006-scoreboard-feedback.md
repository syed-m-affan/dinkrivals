---
id: P1-006
phase: 1
status: done
priority: medium
parallel_group: F
depends_on: [P1-001, P1-003, P1-004]
blocks: [P1-007]
owner: codex
last_updated: 2026-05-10
---

# P1-006 - Scoreboard and Rally Feedback

## Goal

Make Phase 1 scoring and shot/rule outcomes visible during gameplay.

## Build Spec Coverage

Phase 1 contents:

- Scorekeeping.
- Feedback text: DINK, DRIVE, LOB, SMASH, FAULT.
- Debug overlay remains useful.

## Suggested File Ownership

- `dink_rivals/lib/game/components/debug_overlay_component.dart`
- `dink_rivals/lib/game/components/score_component.dart`
- `dink_rivals/lib/game/components/rally_feedback_component.dart`
- `dink_rivals/lib/game/dink_rivals_game.dart` only for adding/exposing state to components.

Coordinate with `P1-003` before editing `DinkRivalsGame`.

## Requirements

- Show current player and opponent score.
- Show match-over state when someone reaches 7.
- Show short feedback for successful racket-contact classifications: `DINK`, `DRIVE`, `LOB`, `SMASH`.
- Show `FAULT` with a brief reason for out, double bounce, or kitchen volley.
- Treat `DINK`, `DRIVE`, `LOB`, and `SMASH` as feedback labels generated after contact, not controls the player taps.
- Keep the existing Phase 0 debug information visible or easily readable.
- Do not add a main menu or end-match screen.

## Verification

Run:

```bash
cd dink_rivals
flutter analyze
flutter test
flutter build apk --debug
```

Manual checks:

- Scores are readable on phone.
- Feedback text appears and clears.
- Debug overlay does not obscure controls.
- Match-over text is visible.

## Acceptance Criteria

- Score and feedback are visible in the game scene.
- Feedback correctly reflects contact-classification and fault events from game state.
- No gameplay rules are implemented here beyond consuming existing state.
- `tickets/status.md` and this ticket metadata are updated.
