---
id: P51H-001
phase: 5.1H
status: done
priority: medium
parallel_group: H
depends_on: [P51A-001, P5F-002]
blocks: [P51I-001]
owner: unassigned
last_updated: 2026-05-11
---

# P51H-001 - HUD and Controls Proportion Pass

## Goal

Tune HUD and control proportions against the concept screenshot and latest Phase 5.1 gameplay screenshot, without changing the locked control contract.

## Build Spec Coverage

Phase 5.1H - HUD and Control Proportion Pass:

- Score, pause, feedback, joystick, swing stick, and serve button review.
- SafeArea-aware visual proportions.
- Controls remain easy to hit while visually less dominant than gameplay.

## Suggested File Ownership

- `dink_rivals/lib/game/components/score_component.dart`
- `dink_rivals/lib/game/components/rally_feedback_component.dart`
- `dink_rivals/lib/game/components/touch_controls_component.dart`
- `dink_rivals/lib/game/systems/touch_input_controller.dart` only for visual/touch target tuning that preserves the contract
- `dink_rivals/lib/screens/game_screen.dart`
- `dink_rivals/lib/game/config/visual_palette.dart`
- `dink_rivals/test/touch_input_controller_test.dart`
- `docs/art/phase-5.1/phase-5.1-delta-inventory.md` (reference only)
- `tickets/status.md`

Coordinate with environment/court tickets if court framing changes affect HUD overlap.

## Requirements

- Review score panels, pause button, feedback area, joystick, swing stick, and serve button against the concept and device screenshot.
- Reduce oversized/crowded elements only where they distract from gameplay or concept fidelity.
- Keep touch targets comfortable for mobile.
- Keep notch/status/nav safe behavior.
- Preserve the movement stick + swing stick + automatic racket-contact control contract.
- Do not add shot buttons.

## Non-Goals

- No menu/roster/settings redesign unless P51A identifies a direct gameplay-HUD regression.
- No new tutorial, monetization, unlock, or progression UI.
- No change to shot classification or racket hit detection.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

If Android is available, capture serve and rally screenshots.

## Acceptance Criteria

- Score panels, pause button, feedback, joystick, swing stick, and serve button are SafeArea-aware.
- Controls remain easy to hit but do not visually overpower the court.
- Top HUD does not collide with opponent, fence, or feedback.
- New player can still start and play without extra taps or new control concepts.

## Planning Notes

- Claude recommended this as a separate pass only after triage confirms proportion issues; avoid changing controls just because other visual tickets are active.
