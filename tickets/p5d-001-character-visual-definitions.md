---
id: P5D-001
phase: 5D
status: done
priority: high
parallel_group: A
depends_on: [P5A-002]
blocks: [P5D-002, P5D-003]
owner: unassigned
last_updated: 2026-05-11
---

# P5D-001 - Character Visual Definitions

## Goal

Create data-driven visual definitions for Rookie, Rally Queen, Veteran, and Showman so sprite and portrait work stays consistent.

## Build Spec Coverage

Phase 5D - Character Personality and Animation Polish:

- Character-specific colors and silhouettes.
- Paddle color/shape variants that do not imply pay-to-win.
- Character visual definitions in data/config rather than branching inside components.

## Suggested File Ownership

- `dink_rivals/lib/game/config/character_visuals.dart` (new)
- `dink_rivals/lib/screens/roster_screen.dart`
- `dink_rivals/lib/game/config/visual_palette.dart`
- `dink_rivals/test/character_visuals_test.dart` (new)
- `tickets/status.md`

Avoid editing sprite sheets in this ticket.

## Requirements

- Add a `CharacterVisuals` config with entries for Rookie, Rally Queen, Veteran, and Showman.
- Include display name, portrait asset path, primary/secondary colors, paddle skin path or color, and silhouette notes.
- Wire roster portrait lookup to the config instead of duplicating asset path logic in `roster_screen.dart`.
- Add tests confirming all roster characters have unique visual entries and existing portrait paths.
- Document that visual variants are cosmetic only and do not affect stats or gameplay.

## Non-Goals

- No gameplay character selection or stat differences.
- No tournament/unlock logic.
- No new sprite sheets.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Character visual data exists and is used by roster UI.
- All four MVP characters have visual definitions.
- No gameplay behavior changes.

## Implementation Notes

- Added `CharacterVisuals` data for Rookie, Rally Queen, Veteran, and Showman.
- Roster portrait lookup now reads from the config instead of duplicating asset paths.
- Added tests for unique definitions, existing portrait/paddle assets, lookup behavior, and cosmetic-only notes.
