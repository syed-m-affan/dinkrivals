---
id: P5F-001
phase: 5F
status: todo
priority: high
parallel_group: A
depends_on: [P5A-002]
blocks: [P5F-002, P5F-003, P5F-004]
owner: unassigned
last_updated: 2026-05-11
---

# P5F-001 - Arcade UI Primitives and Theme Tokens

## Goal

Create reusable arcade UI widgets and theme tokens so HUD, menus, roster, settings, pause, and end-match screens share one visual system.

## Build Spec Coverage

Phase 5F - Concept HUD, Menus, and Court Cards:

- Shared HUD colors, borders, shadows, and typography.
- Reusable arcade UI widgets.
- Same visual language across screens.

## Suggested File Ownership

- `dink_rivals/lib/app/app_theme.dart`
- `dink_rivals/lib/game/config/visual_palette.dart`
- `dink_rivals/lib/widgets/arcade_panel.dart` (new)
- `dink_rivals/lib/widgets/arcade_button.dart` (new, if needed)
- `dink_rivals/test/arcade_ui_test.dart` (new, if practical)
- `tickets/status.md`

Avoid editing individual screens in this ticket except for a minimal usage smoke if needed.

## Requirements

- Add reusable panel/button primitives or style helpers for chunky arcade UI.
- Move common borders, shadows, panel colors, and typography into shared theme/config.
- Preserve accessibility and text contrast.
- Keep widgets flexible enough for HUD and Material screens.

## Non-Goals

- No screen restyle beyond primitives.
- No scoreboard or control changes.
- No new routes or menu features.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Shared UI primitives exist.
- Later Phase 5F tickets can replace generic screen widgets without duplicating style code.
- Existing screen tests remain green.

