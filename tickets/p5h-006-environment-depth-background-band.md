---
id: P5H-006
phase: 5H
status: todo
priority: medium
parallel_group: E
depends_on: [P5B-002, P5C-003]
blocks: []
owner: unassigned
last_updated: 2026-05-11
---

# P5H-006 - Environment Depth Background Band

## Goal

Add a cheap far-background layer that improves depth without competing with gameplay readability.

## Background

P5G comparison notes still call out the concept art as richer in environment depth than the current placeholder court.

## Requirements

- Add a static far-background band behind the court/environment props.
- Keep it below all gameplay-critical render layers.
- Preserve court coordinates, projection math, physics, controls, and scoring.
- Add or update layout tests if the band can overlap HUD or control space.

## Non-Goals

- No animated crowd.
- No weather/time-of-day system.
- No gameplay changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

