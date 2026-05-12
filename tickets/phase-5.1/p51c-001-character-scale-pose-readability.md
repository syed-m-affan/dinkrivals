---
id: P51C-001
phase: 5.1C
status: done
priority: high
parallel_group: C
depends_on: [P51B-001]
blocks: [P51I-001]
owner: unassigned
last_updated: 2026-05-11
---

# P51C-001 - Character Scale, Pose, and Direction Readability

## Goal

Make player and opponent models read as consistent concept-style chibi sports characters before serve, during rally, on hit-confirm, and after point result.

## Build Spec Coverage

Phase 5.1C - Character Scale, Pose, and Direction Readability:

- Unified player/opponent proportions across gameplay states.
- No model identity jump before/after serve.
- Strong head/body/paddle separation.

## Suggested File Ownership

- `dink_rivals/assets/images/sprites/`
- `dink_rivals/lib/game/components/player_component.dart`
- `dink_rivals/lib/game/components/opponent_component.dart`
- `dink_rivals/lib/game/config/character_visuals.dart`
- `dink_rivals/test/player_component_test.dart`
- `docs/art/phase-5.1/phase-5.1-delta-inventory.md` (reference only)
- `tickets/status.md`

Do not edit hit detection, movement, physics, rules, scoring, AI, or input systems.

## Requirements

- Ensure waiting-to-serve, serve-release, rally idle/run, swing, hit-confirm, and point-result visuals share:
  - the same character proportions
  - the same outline weight
  - the same palette
  - the same foot baseline
  - compatible paddle placement
- Keep the far opponent readable without making perspective nonsensical.
- Avoid sudden silhouette swaps between pre-serve and post-serve states.
- If placeholder special-state sheets are not good enough, replace them or alias them intentionally rather than shipping mismatched art.
- Add tests for pose/state selection when possible without pixel rendering.

## Non-Goals

- No new gameplay animation timing that changes contact windows.
- No new character stats, unlocks, or roster behavior.
- No full character redesign outside gameplay-scale readability.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

If an Android device is available, capture before-serve and after-serve screenshots for comparison.

## Acceptance Criteria

- The player does not appear to change into a different model after serve.
- The opponent and player remain visually related but clearly distinct.
- Ready/idle/run/swing/special states do not obscure ball/racket contact.
- Head, torso, legs, paddle, and shadow read clearly at gameplay scale.
- No hitbox, physics, scoring, AI, or control regressions.

## Planning Notes

- This ticket may supersede `P5H-007` if it adds or replaces idle/ready micro-animation.
