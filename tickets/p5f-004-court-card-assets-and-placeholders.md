---
id: P5F-004
phase: 5F
status: todo
priority: medium
parallel_group: D
depends_on: [P5F-001]
blocks: [P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5F-004 - Court Card Assets and Placeholders

## Goal

Add concept-style court card assets for Classic and Park Court placeholders without introducing court selection or unlock systems.

## Build Spec Coverage

Phase 5F - Concept HUD, Menus, and Court Cards:

- Court cards for Classic and Park Court.
- Locked-state art placeholders for later courts.
- No menu/ad/unlock work beyond current scope.

## Suggested File Ownership

- `dink_rivals/assets/images/ui/court_cards/` (new)
- `dink_rivals/pubspec.yaml`
- `docs/art/visual-direction.md` (reference only)
- `tickets/status.md`

Do not edit runtime screens unless adding a non-interactive preview is explicitly required by the current visual direction note.

## Requirements

- Create original placeholder card art for:
  - Classic Court
  - Park Court
  - Locked/coming-soon court
- Register the asset directory in `pubspec.yaml`.
- Add a README/manifest describing intended use and placeholder status.
- Do not wire court cards into navigation, unlocks, purchases, tournament, or court selection.

## Non-Goals

- No court selection UI.
- No unlock or progression logic.
- No new playable court.

## Verification

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
```

## Acceptance Criteria

- Court card assets exist and are declared.
- Assets are ready for a future UI ticket.
- No runtime feature scope is added.

