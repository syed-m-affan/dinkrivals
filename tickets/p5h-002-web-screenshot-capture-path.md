---
id: P5H-002
phase: 5H
status: todo
priority: medium
parallel_group: B
depends_on: [P5G-001]
blocks: []
owner: unassigned
last_updated: 2026-05-11
---

# P5H-002 - Web Screenshot Capture Path

## Goal

Evaluate and, if accepted, add a Flutter web target so gameplay screenshots can be captured in a browser when Android is unavailable.

## Background

P5G-001 could not use browser screenshots because `flutter build web --debug` reported that the project is not configured for web.

## Requirements

- Decide whether web support is appropriate for this prototype.
- If accepted, add the minimal Flutter web platform files using Flutter tooling.
- Verify the game launches in Chrome and can capture menu and gameplay states.
- Document any web-specific rendering differences.

## Non-Goals

- No production web deployment.
- No web-specific gameplay changes.
- No replacement for physical Android QA.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build web --debug
```

