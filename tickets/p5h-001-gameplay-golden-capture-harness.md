---
id: P5H-001
phase: 5H
status: todo
priority: high
parallel_group: A
depends_on: [P5G-001]
blocks: []
owner: unassigned
last_updated: 2026-05-11
---

# P5H-001 - Gameplay Golden Capture Harness

## Goal

Add a reliable automated screenshot path for actual Flame gameplay frames so visual regressions are not limited to Material UI screens.

## Background

P5G-001 widget goldens can capture menu, roster, settings, and end-match UI, but `GameScreen` renders the Flame canvas as black in the current widget golden harness.

## Requirements

- Create a gameplay-specific capture harness using Flame-friendly loading and render timing.
- Capture at least serve, rally, point-feedback, and pause states if the harness can render the canvas reliably.
- Keep the harness deterministic and avoid changing runtime gameplay behavior.
- Update `docs/art/phase-5g-comparison.md` or successor notes with the capture path.

## Non-Goals

- No web platform setup.
- No Android/manual QA.
- No gameplay tuning.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

