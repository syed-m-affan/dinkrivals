---
id: P5-004
phase: 5
status: done
priority: high
parallel_group: D
depends_on: [P5-001]
blocks: [P5-007]
owner: codex
last_updated: 2026-05-11
---

# P5-004 - UI Theme, Scoreboard, Feedback, Roster Portraits, Menu Logo

## Goal

Apply the Phase 5 visual identity to the app-level UI: centralize the theme, restyle the scoreboard and DINK/DRIVE/LOB/SMASH/FAULT rally feedback, swap the placeholder menu logo for the real one, and load the four character portraits in the roster.

## Build Spec Coverage

Phase 5 tasks (build-spec §13):

- Add scoreboard style.
- Add UI theme.
- Add DINK/SMASH/FAULT feedback styling.
- Character portraits.

## Suggested File Ownership

- `dink_rivals/lib/app/app_theme.dart`
- `dink_rivals/lib/game/components/score_component.dart`
- `dink_rivals/lib/game/components/rally_feedback_component.dart`
- `dink_rivals/lib/screens/main_menu_screen.dart`
- `dink_rivals/lib/screens/roster_screen.dart`
- `dink_rivals/lib/screens/end_match_screen.dart`
- `dink_rivals/pubspec.yaml` — declare a pixel-style monospace font under `flutter.fonts` if one is added.
- `dink_rivals/test/score_component_test.dart` (new widget/unit test).

Do not edit `lib/services/save_service.dart`, gameplay systems, sprites (P5-002 / P5-003), or audio/haptics services (P5-005 / P5-006).

## Requirements

- Centralize palette and typography in `app_theme.dart`. Re-export from `VisualPalette` (P5-001) so there is one source of truth for colors used by both Flame components and Material widgets.
- Scoreboard (`score_component.dart`):
  - Larger, pixel-style monospace numerals.
  - Add a serving-side indicator (small dot or arrow next to the serving score). Read from `MatchState.servingSide`.
  - Background plate driven by `VisualPalette.uiSurface` (no hardcoded color).
- Rally feedback (`rally_feedback_component.dart`):
  - Per-shot color: DINK = `feedbackDink`, DRIVE = `feedbackDrive`, LOB = `feedbackLob`, SMASH = `feedbackSmash`, FAULT = `feedbackFault`.
  - Brief scale-pop tween (e.g. 1.0 → 1.2 → 1.0 over 0.25 s) when text changes.
  - Existing `feedbackText` / `feedbackSeconds` contract unchanged.
- Main menu (`main_menu_screen.dart`): replace the placeholder `DR` `Container` with `assets/images/ui/logo.png`. Buttons use `AppTheme.dark` `elevatedButtonTheme`.
- Roster screen (`roster_screen.dart`): render `portrait_{rookie,rally_queen,veteran,showman}.png` next to each character card. Map by character `name` so future tickets can add data-driven characters.
- End match screen (`end_match_screen.dart`): apply themed buttons; if a winner portrait exists, show it next to the winner banner. Layout stays accessible inside `SafeArea`.
- Do not introduce a new font without ensuring the license permits redistribution. Use Flutter's built-in monospace fallback if no licensed pixel font is available.

## Non-Goals

- No new screens.
- No tournament UI, unlocks, or trophy room.
- No real ad UI changes (P3 fake-ad surfaces already wired).
- No SFX or haptics (P5-005, P5-006).
- No change to `MatchState`, scoring, or rally feedback timing logic.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Required tests:

- Widget test: scoreboard shows the serving-side indicator on the correct side when `servingSide` flips.
- Widget test: roster shows 4 portrait images.
- Existing `settings_screen_test.dart`, `end_match_screen_test.dart` stay green.

## Acceptance Criteria

- All hardcoded colors in `score_component.dart` and `rally_feedback_component.dart` are replaced by `VisualPalette` references.
- Scoreboard shows serving-side indicator and pixel-style numerals.
- Each DINK / DRIVE / LOB / SMASH / FAULT label is visually distinct.
- Main menu shows the real logo asset.
- Roster shows 4 character portraits.
- `flutter analyze` and `flutter test` pass.

## Implementation Notes

- `AppTheme.dark` now uses the shared `VisualPalette` and monospace typography.
- Scoreboard uses a palette-backed plate, larger monospace numerals, and a serving-side dot.
- Rally feedback maps DINK/DRIVE/LOB/SMASH/FAULT to distinct palette colors and applies a short scale pop when text changes.
- Main menu uses `assets/images/ui/logo.png`; roster renders the four generated portrait assets; end-match shows a winner portrait and themed controls.
- Added `score_component_test.dart` and `roster_screen_test.dart`.

## Verification

- `flutter analyze`: passed, zero issues.
- `flutter test`: passed, 96 tests.
- `flutter build apk --debug`: passed.
