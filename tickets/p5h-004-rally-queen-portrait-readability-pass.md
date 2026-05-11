---
id: P5H-004
phase: 5H
status: todo
priority: medium
parallel_group: D
depends_on: [P5D-003]
blocks: []
owner: unassigned
last_updated: 2026-05-11
---

# P5H-004 - Rally Queen Portrait Readability Pass

## Goal

Make Rally Queen's portrait read as a distinct character with a clear headband and hair/kit separation at roster-card size.

## Background

P5D-003 Claude review noted that Rally Queen currently reads more as yellow hair on pink than a distinct headband.

## Requirements

- Re-author `assets/images/ui/portrait_rally_queen.png`.
- Preserve the existing asset path and roster layout.
- Re-generate the roster golden and character-check sheet.

## Non-Goals

- No new roster characters.
- No gameplay stat differences.
- No roster interaction changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter test --update-goldens test/phase5g_visual_golden_test.dart
```

