---
id: P1-005
phase: 1
status: done
priority: medium
parallel_group: E
depends_on: [P1-004]
blocks: [P1-007]
owner: codex
last_updated: 2026-05-10
---

# P1-005 - Beginner Rally Opponent AI

## Goal

Adjust opponent AI so Phase 1 rallies are sustainable and readable while respecting lob, smash, and rule outcomes.

## Build Spec Coverage

Phase 1 contents:

- Improved bot AI.
- Opponent can sustain beginner rallies.
- Dink, drive, lob, smash contact classifications exist.

## Suggested File Ownership

- `dink_rivals/lib/game/systems/opponent_ai_system.dart`
- `dink_rivals/lib/game/config/tuning_constants.dart`
- `dink_rivals/test/opponent_ai_system_test.dart` if practical.

Avoid changing scoring, rules, UI, or player input in this ticket.

## Requirements

- Update AI contact/classification behavior for dink, drive, lob, and smash.
- Keep these as AI/contact outcomes only; do not add player shot buttons or new input surfaces.
- Make AI less perfect than a bot that always intercepts, but not so weak that rallies die immediately.
- Keep reaction delay and miss chance centralized in `Tuning`.
- Ensure AI does not intentionally hit constant out balls under normal beginner rally conditions.
- Preserve or improve the current ready-position behavior from Phase 0.

## Suggested Tuning Targets

- AI should return a majority of reasonable shots.
- AI should occasionally miss or choose suboptimal shots.
- AI should not classify low-ball contact as smash.
- AI should produce lob-like returns when pulled forward or when the player is near the kitchen.

## Verification

Run:

```bash
cd dink_rivals
flutter analyze
flutter test
flutter build apk --debug
```

Manual checks:

- Play several rallies.
- Confirm AI uses more than one shot type.
- Confirm beginner rallies can last at least 10 seconds.
- Confirm AI faults feel understandable, not random.

## Acceptance Criteria

- AI compiles against expanded shot types.
- AI sustains beginner rallies during manual QA.
- Any new deterministic AI tests pass.
- `PHASE_NOTES.md` records tuning observations if manual QA is performed.
- `tickets/status.md` and this ticket metadata are updated.
