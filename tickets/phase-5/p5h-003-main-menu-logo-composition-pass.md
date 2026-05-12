---
id: P5H-003
phase: 5H
status: done
priority: medium
parallel_group: C
depends_on: [P5G-001]
blocks: []
owner: unassigned
last_updated: 2026-05-11
---

# P5H-003 - Main Menu Logo Composition Pass

## Goal

Make the main menu read as a branded first screen instead of a button panel with excess empty space.

## Background

`docs/art/phase-5/phase-5g-menu.png` shows a large top band and weak logo presence in the golden capture.

## Requirements

- Improve logo prominence and vertical rhythm on the main menu.
- Preserve one-tap Quick Match behavior and existing route keys.
- Re-generate the menu golden after changes.

## Non-Goals

- No new menu routes.
- No landing page or marketing copy.
- No gameplay changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter test --update-goldens test/phase5g_visual_golden_test.dart
```

## Implementation Notes

- Absorbed by the Phase 5.2 menu/comparison closeout rather than kept as a
  separate follow-up. Current menu evidence and residual composition notes live
  in `docs/art/phase-5.2/phase-5.2-comparison.md`.
