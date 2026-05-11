---
id: P3-005
phase: 3
status: done
priority: medium
parallel_group: E
depends_on: [P3-001, P3-002]
blocks: [P3-006]
owner: codex
last_updated: 2026-05-11
---

# P3-005 - Ad Eligibility Debug Visibility

## Goal

Expose enough debug information to verify Phase 3 fake ad eligibility during development without cluttering gameplay or changing player-facing controls.

## Build Spec Coverage

Phase 3 build contents:

- Debug overlay for ad eligibility.

## Suggested File Ownership

- `dink_rivals/lib/game/components/debug_overlay_component.dart` if in-game visibility is needed.
- `dink_rivals/lib/screens/end_match_screen.dart` if post-match debug text is clearer.
- `dink_rivals/lib/game/systems/ad_placement_system.dart` only for read-only debug summary helpers if needed.
- `dink_rivals/test/ad_placement_system_test.dart` or widget tests for any exposed strings.

Avoid changing gameplay input, shot behavior, or production UI theme.

## Requirements

- Show ad eligibility state in a debug-only way that helps QA answer:
  - completed matches this session
  - matches until next eligible interstitial
  - time until next eligible interstitial
  - whether the current screen is a natural break
- Keep this out of active gameplay if it would overlap score, controls, or ball visibility.
- Do not expose debug eligibility as a player-facing monetization prompt.
- Do not add any real analytics or external telemetry.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Manual smoke:

- Complete matches and confirm the debug info changes as frequency gates change.
- Confirm gameplay controls and score remain readable.

## Acceptance Criteria

- QA can tell why an interstitial is or is not eligible.
- Debug text does not overlap critical gameplay UI.
- No real ad SDK, analytics, or telemetry is introduced.
- Existing tests pass.

## Implementation Notes

Completed on 2026-05-11:

- Added post-match debug line via `AdPlacementSystem.debugSummary(...)`.
- Debug text reports session matches, matches until eligible, seconds until eligible, and natural-break state.
- Kept debug visibility on end-match screen rather than active gameplay to avoid overlapping score, ball, or controls.

## Verification

- `flutter analyze`: passed with no issues.
- `flutter test`: passed 73/73.
- `flutter build apk --debug`: passed.
