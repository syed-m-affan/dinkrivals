---
id: VO3-001
phase: visual-overhaul-v3
status: todo
priority: high
parallel_group: validation
depends_on: [VO3-003, VO3-004, VO3-005, VO3-006]
owner: Visual QA Agent
last_updated: 2026-05-12
---

# VO3-001 - Physical Pixel Visual Validation

## Goal

Run the VO2 final build on a physical Pixel-class Android device and capture the evidence set that was unavailable during automated closeout.

This validation must run after the failed art QA fixes land; do not use the rejected VO2 art build as final validation evidence.

## Tasks

- Connect a physical Pixel device.
- Install `dink_rivals/build/app/outputs/flutter-apk/app-debug.apk`.
- Capture menu, roster, settings, serve, rally, dink, drive, lob, smash, point-win, pause, and end-match screenshots under `docs/art/visual-overhaul/evidence/vo3-pixel-*`.
- Run a 5-minute smoke test with no crash and no obvious sustained jank.
- Record findings in `docs/art/visual-overhaul/visual-overhaul-v2-comparison.md` or a VO3 comparison doc.

## Acceptance

- Physical Pixel install succeeds.
- Required screenshots are archived.
- 5-minute smoke test result is recorded.
