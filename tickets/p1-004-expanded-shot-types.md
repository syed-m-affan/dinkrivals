---
id: P1-004
phase: 1
status: done
priority: high
parallel_group: D
depends_on: []
blocks: [P1-005, P1-006, P1-007]
owner: codex
last_updated: 2026-05-10
---

# P1-004 - Expanded Shot Types

## Goal

Expand the current Phase 0 racket-contact shot system so swing/contact physics can classify lob and smash in addition to soft dink/block and firm drive outcomes.

## Build Spec Coverage

Phase 1 contents:

- Dink, drive, lob, smash.
- Racket-contact shot classification.
- Contact window logic.
- Centralized tuning constants.

## Suggested File Ownership

- `dink_rivals/lib/game/models/shot_type.dart`
- `dink_rivals/lib/game/systems/shot_system.dart`
- `dink_rivals/lib/game/systems/input_system.dart` only if racket swing state needs additional data.
- `dink_rivals/lib/game/config/tuning_constants.dart`
- `dink_rivals/test/shot_system_test.dart`

Avoid modifying opponent AI except for compile fixes; behavior tuning belongs to `P1-005`.

## Requirements

- Extend `ShotType` to include `lob`, `smash`, and optionally `block`/`serve` if needed for feedback.
- Preserve Phase 0 two-stick controls: left stick moves, right stick swings the racket. Do not add dink/drive/lob/smash buttons.
- Classify lob from high/upward racket contact or open-angle swing contact.
- Classify smash contextually: high ball plus fast downward/forward contact should become smash when ball height passes a tuning threshold.
- Keep all new speed, height, and threshold values in `Tuning`.
- Dink/block should come from soft contact and produce a shorter/slower return.
- Drive should come from firm forward contact and produce a deeper/faster return.
- Lob should use higher lift and slower travel.
- Smash should be fast with low/downward arc.

## Verification

Run:

```bash
cd dink_rivals
flutter analyze
flutter test
```

Required tests:

- Lob produces higher peak/initial vertical velocity than drive.
- Smash requires ball height threshold.
- Smash is not selected for low balls.
- Soft contact, firm contact, lob contact, and smash contact classify distinctly.
- Existing full racket-segment hitbox validation still works.

## Acceptance Criteria

- `ShotType` supports all Phase 1 shot classifications.
- Shot logic remains testable without rendering.
- Existing Phase 0 swing controls still work.
- No scoring/rules integration is included.
- `tickets/status.md` and this ticket metadata are updated.
