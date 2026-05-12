---
id: P52H-001
phase: 5.2G
status: done
priority: high
parallel_group: F
depends_on: [P52G-001]
blocks: [P52M-001]
owner: codex
last_updated: 2026-05-11
---

# P52H-001 - Top-Center Feedback Banner

## Goal

Replace the floating mid-court rally number with a concept-like top-center feedback banner for shot classifications, faults, and points.

## Build Spec Coverage

Phase 5.2G - Top-Center Feedback Banner:

- Shot/fault/point callout banner.
- Safe placement below the scoreboard/pause row.
- Existing event plumbing only.

## Suggested File Ownership

- `dink_rivals/lib/game/components/rally_feedback_component.dart`
- `dink_rivals/lib/game/dink_rivals_game.dart`
- `dink_rivals/lib/game/config/visual_palette.dart` token usage only
- `dink_rivals/test/score_component_test.dart` or a new focused feedback test
- `docs/art/phase-5.2/phase-5.2-feedback-banner.png`
- `tickets/status.md`

Do not edit `ShotSystem` or `MatchRulesSystem` behavior except to expose existing labels read-only if necessary.

## Requirements

- Remove the mid-court rally number visual.
- Render a top-center banner below the top HUD row for DINK, DRIVE, LOB, SMASH, FAULT, POINT, and NICE SHOT style labels.
- Reuse existing `feedbackText` / `feedbackSeconds` semantics unless a small read-only adapter is cleaner.
- Ensure the banner clears within a short interval and does not overlap scoreboard, pause, opponent, signage, or controls.
- Add tests or deterministic helper coverage for feedback text timing/position if practical.
- Capture a screenshot during a visible feedback event.

## Non-Goals

- No shot classification changes.
- No scoring/rules changes.
- No persistent tutorial text.
- No menu feedback redesign.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Concept-like top-center feedback appears for relevant events.
- Floating mid-court rally number is gone.
- Feedback does not collide with SafeArea, scoreboard, pause, or signage.
- Shot/rule behavior remains unchanged.

## Planning Notes

- Claude explicitly requested a safe-area rule for scoreboard + feedback + pause. P52G must land first so this ticket can position against the final top HUD.

## Implementation Notes

- Implemented: rally feedback now renders in a top-center banner with tested formatting and safe-area-aware placement.
- Verification: `flutter analyze`, `flutter test`, `flutter build apk --debug`, emulator install/launch on `emulator-5554`, and `docs/art/phase-5.2/phase-5.2-gameplay-emulator-smoke.png`.
