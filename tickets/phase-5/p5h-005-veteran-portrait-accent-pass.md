---
id: P5H-005
phase: 5H
status: done
priority: medium
parallel_group: D
depends_on: [P5D-003]
blocks: []
owner: unassigned
last_updated: 2026-05-11
---

# P5H-005 - Veteran Portrait Accent Pass

## Goal

Strengthen Veteran's mint accent so the character remains identifiable at portrait and roster-card scale.

## Background

P5D-003 Claude review noted that Veteran's mint accent is subtle against the gray kit.

## Requirements

- Re-author `assets/images/ui/portrait_veteran.png`.
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

## Implementation Notes

- Absorbed by `P52F-001`. Veteran portrait readability was handled in the
  Phase 5.2 character identity pass together with the refreshed runtime sprite
  sheets and roster portraits.
