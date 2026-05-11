---
id: P5F-002
phase: 5F
status: done
priority: high
parallel_group: B
depends_on: [P5F-001]
blocks: [P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5F-002 - Concept HUD, Scoreboard, Feedback, and Controls

## Goal

Bring the in-match HUD closer to the concept screenshot while preserving notch/nav safety and gameplay readability.

## Build Spec Coverage

Phase 5F - Concept HUD, Menus, and Court Cards:

- Chunky blue/red scoreboard panels with serving indicator.
- Pause button treatment matching concept screenshot.
- Top-center rally feedback and point banners.
- Refined joystick, swing-stick, and serve-button skins.

## Suggested File Ownership

- `dink_rivals/lib/game/components/score_component.dart`
- `dink_rivals/lib/game/components/rally_feedback_component.dart`
- `dink_rivals/lib/game/components/touch_controls_component.dart`
- `dink_rivals/lib/screens/game_screen.dart`
- `dink_rivals/lib/widgets/` shared UI primitives from P5F-001
- `dink_rivals/assets/images/ui/hud/`
- `dink_rivals/test/score_component_test.dart`
- `tickets/status.md`

Do not change gameplay input behavior, control hit regions, scoring, or match flow.

## Requirements

- Replace the simple score plate with concept-like blue/red score panels and a serving indicator.
- Restyle pause button to match the HUD system.
- Refine feedback/point banner presentation without changing `feedbackText` / `feedbackSeconds` contract.
- Restyle joystick, swing-stick, and serve-button visuals while preserving existing pointer behavior.
- Confirm HUD and controls remain SafeArea aware on tall Android phones.

## Non-Goals

- No menu/rest-of-app restyle.
- No new controls.
- No shot buttons.
- No scoring or feedback timing logic changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- In-match HUD resembles the concept art while staying readable.
- Scores, serving indicator, pause, feedback, joystick, swing stick, and serve button do not clip or overlap.
- New player can still start and control a match without changed input behavior.

## Implementation Notes

- Reworked score rendering into separate chunky player/opponent panels with active-serve border and center status chip.
- Added rally feedback panel backing, bordered pause button treatment, and outer rings for movement/swing controls without changing hit regions.
- Claude review flagged match-over chip overflow and serve-dot/digit collision; both were corrected before verification.
