---
id: P2-003
phase: 2
status: todo
priority: high
parallel_group: C
depends_on: [P2-001]
blocks: [P2-007]
owner: unassigned
last_updated: 2026-05-10
---

# P2-003 - Main Menu and Roster Placeholder

## Goal

Turn the placeholder main menu from `P2-001` into a usable entry point with a Quick Match button, a Roster placeholder screen, a Settings entry, and a placeholder logo.

## Build Spec Coverage

Phase 2 tasks:

- Create main menu screen.
- Create roster placeholder.
- Placeholder logo.

## Suggested File Ownership

- `dink_rivals/lib/screens/main_menu_screen.dart`.
- `dink_rivals/lib/screens/roster_screen.dart`.
- `dink_rivals/assets/images/logos/` (placeholder asset only if needed; a text logo is acceptable).
- `dink_rivals/pubspec.yaml` (only if a real image asset is added).

Do not edit the router, the save service, the settings body, the game screen body, the end-match screen, or any `lib/game/**` file.

## Requirements

- Main menu must include:
  - Placeholder "Dink Rivals" logo (text or simple shape; no production art).
  - Phase label sourced from `app_config.dart` (`phaseLabel`).
  - Quick Match button → routes to `/game`.
  - Roster button → routes to `/roster`.
  - Settings button → routes to `/settings`.
- Buttons must be large, finger-friendly, and not block when keyboard appears.
- New player can start their first match in **under 3 taps** (per build-spec §13 Phase 7 acceptance, applied as forward-looking guardrail): launching to menu and tapping Quick Match counts as one tap. Do not add a tutorial gate.
- Roster screen displays the four MVP characters from build-spec §12.2 as a read-only list (Rookie, Rally Queen, Veteran, Showman) with role/strength/weakness text. No selection, no unlock state, no ad-gated previews — those are later phases.
- Both screens must offer a clear back-to-menu affordance (roster) and respect the immersive portrait orientation.

## Design Notes

- Visual style is intentionally plain: dark theme from `app_theme.dart`, simple typography. Phase 5 owns visual identity.
- Do not pre-build buttons for Tournament, Trophy Room, or Remove Ads. Those routes do not exist yet; adding stubs invites dead code that future tickets will rewrite.
- Do not consume `SaveService` here. The menu does not need user prefs.

## Verification

```bash
cd dink_rivals
flutter analyze
flutter test
flutter build apk --debug
```

Manual smoke:

- App boots into the menu.
- Quick Match routes to the rally scene with no regression.
- Roster shows four characters with their spec metadata.
- Settings entry navigates to the settings route (body may still be a placeholder if `P2-004` has not landed).

## Acceptance Criteria

- Menu is the launch screen and presents Quick Match / Roster / Settings.
- Roster lists the four MVP characters as plain text.
- No new game systems, save logic, ad logic, or persistence introduced.
- No production art committed.
- `tickets/status.md` and this ticket metadata are updated.
