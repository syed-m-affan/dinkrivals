---
id: P5F-003
phase: 5F
status: todo
priority: high
parallel_group: C
depends_on: [P5F-001]
blocks: [P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5F-003 - Menu, Roster, Settings, Pause, and End-Match Restyle

## Goal

Restyle the app screens using the shared arcade UI system while preserving the existing route flow and quick path to gameplay.

## Build Spec Coverage

Phase 5F - Concept HUD, Menus, and Court Cards:

- Main menu background treatment and stronger logo presentation.
- Roster cards matching concept layout.
- Settings, pause, and end-match screens restyled to match the same UI system.
- Text fits on small and large phones.

## Suggested File Ownership

- `dink_rivals/lib/screens/main_menu_screen.dart`
- `dink_rivals/lib/screens/roster_screen.dart`
- `dink_rivals/lib/screens/settings_screen.dart`
- `dink_rivals/lib/screens/game_screen.dart` (pause overlay only)
- `dink_rivals/lib/screens/end_match_screen.dart`
- `dink_rivals/lib/widgets/`
- `dink_rivals/test/settings_screen_test.dart`
- `dink_rivals/test/end_match_screen_test.dart`
- `dink_rivals/test/roster_screen_test.dart`
- `tickets/status.md`

Do not add new routes, monetization features, tournament UI, unlock logic, or extra settings toggles.

## Requirements

- Apply shared arcade panels/buttons to main menu, roster, settings, pause overlay, and end-match screen.
- Add a stronger main-menu logo/background treatment without making a marketing landing page.
- Preserve Quick Match as a one-tap path from menu to game.
- Ensure all text fits on phone viewports and respects SafeArea.
- Keep existing fake ad surfaces and settings persistence behavior intact.

## Non-Goals

- No court cards (P5F-004).
- No new gameplay modes.
- No real AdMob/IAP work.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- Main menu, roster, settings, pause, and end-match screens feel like the same game.
- Existing screen tests pass.
- New player can still start first match in under 3 taps.

