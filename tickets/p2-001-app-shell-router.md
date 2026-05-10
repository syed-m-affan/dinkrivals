---
id: P2-001
phase: 2
status: todo
priority: high
parallel_group: A
depends_on: []
blocks: [P2-003, P2-004, P2-005, P2-006, P2-007]
owner: unassigned
last_updated: 2026-05-10
---

# P2-001 - App Shell and Router

## Goal

Replace the direct `GameWidget` launch with a real Flutter app shell so subsequent Phase 2 tickets can add menu, settings, game, pause, and end-match screens behind GoRouter.

## Build Spec Coverage

Phase 2 tasks:

- Add GoRouter.
- Create game screen wrapper (skeleton only; pause and game state belong to `P2-005`).
- Wire app-level state container so settings/save providers can be reached from any screen.

## Suggested File Ownership

- `dink_rivals/pubspec.yaml` (add `go_router`, `flutter_riverpod`).
- `dink_rivals/lib/main.dart`.
- `dink_rivals/lib/app/app.dart`.
- `dink_rivals/lib/app/router.dart`.
- `dink_rivals/lib/app/app_theme.dart`.
- `dink_rivals/lib/app/app_config.dart`.
- `dink_rivals/lib/screens/main_menu_screen.dart` (placeholder body only).
- `dink_rivals/lib/screens/game_screen.dart` (placeholder body only — full pause/game flow is `P2-005`).
- `dink_rivals/lib/screens/settings_screen.dart` (placeholder body only — real UI is `P2-004`).
- `dink_rivals/lib/screens/roster_screen.dart` (placeholder body only — real layout is `P2-003`).

Do not implement screen bodies in this ticket beyond a labeled scaffold and a back/menu button so navigation can be smoke-tested. Do not touch `lib/game/**`.

## Requirements

- Add `go_router` and `flutter_riverpod` via `flutter pub add`. Pin to whatever stable resolves; do not hand-edit version strings.
- Convert `lib/main.dart` to bootstrap a `ProviderScope` wrapping a `MaterialApp.router`.
- Define routes:
  - `/` → main menu
  - `/game` → game screen (placeholder reuses `GameWidget<DinkRivalsGame>` so the rally still runs on this route)
  - `/settings` → settings screen
  - `/roster` → roster screen
- Each screen must have a back-to-menu affordance so navigation is smoke-testable before the rest of Phase 2 lands.
- `MaterialApp.router` must lock to portrait + immersive sticky, matching the current `main.dart` chrome setup.
- Keep gameplay rendering correct on `/game`: the player should still be able to play a match exactly as today.
- App-level theme lives in `app_theme.dart`. Use a simple dark theme; visual identity is `Phase 5`, not now.
- `app_config.dart` exposes a `phaseLabel` string (e.g. `"Phase 2 dev"`) for debug visibility.

## Design Notes

- Use `GoRouter` with statically declared routes for now; do not introduce nested shell routes yet.
- Riverpod is added now so `P2-002` and `P2-004` can publish providers without bringing a dependency themselves.
- Do **not** add a pause overlay, end-match screen, save service, or persisted settings in this ticket — those are owned by `P2-002`, `P2-004`, `P2-005`, `P2-006`.

## Verification

```bash
cd dink_rivals
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Manual smoke:

- App launches to main menu.
- Tapping the (placeholder) Quick Match button routes to `/game` and the existing gameplay loads.
- From `/game`, a back affordance returns to the menu without crashing.
- Settings and roster routes load their placeholder scaffolds.

## Acceptance Criteria

- `flutter analyze` passes with zero warnings.
- All existing tests still pass.
- The app boots into a menu, not directly into the game.
- Each Phase 2 placeholder route is reachable and returnable.
- No game logic, save logic, pause flow, settings persistence, or end-match flow added in this ticket.
- `tickets/status.md` and this ticket metadata are updated.
