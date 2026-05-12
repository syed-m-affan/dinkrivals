---
id: P5G-001
phase: 5G
status: done
priority: high
parallel_group: A
depends_on: [P5B-003, P5C-003, P5D-003, P5E-003, P5F-002, P5F-003, P5F-004]
blocks: [P5G-002, P5G-003]
owner: unassigned
last_updated: 2026-05-11
---

# P5G-001 - Automated Visual Verification and Screenshot Set

## Goal

Create a repeatable screenshot set for the expanded visuals and run automated verification before human QA.

## Build Spec Coverage

Phase 5G - Visual QA and Performance Gate:

- Screenshot set for menu, roster, settings, serve, rally, point banner, pause, and end match.
- Side-by-side comparison against concept screenshot and latest Phase 5 screenshot.
- `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`.

## Suggested File Ownership

- `docs/art/phase-5/phase-5g-menu.png` (new)
- `docs/art/phase-5/phase-5g-roster.png` (new)
- `docs/art/phase-5/phase-5g-settings.png` (new)
- `docs/art/phase-5/phase-5g-serve.png` (new)
- `docs/art/phase-5/phase-5g-rally.png` (new)
- `docs/art/phase-5/phase-5g-point.png` (new)
- `docs/art/phase-5/phase-5g-pause.png` (new)
- `docs/art/phase-5/phase-5g-endmatch.png` (new)
- `docs/art/phase-5/phase-5g-comparison.md` (new)
- `dink_rivals/PHASE_NOTES.md`
- `tickets/status.md`

Avoid implementation fixes in this ticket unless they are trivial screenshot/test harness corrections.

## Verification Commands

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Requirements

- Capture or document blockers for all requested screenshot states.
- Create a comparison note against `docs/art/concepts/concept-screenshot.png` and the latest Phase 5 baseline screenshot.
- Record automated verification command results in `PHASE_NOTES.md`.

## Acceptance Criteria

- Automated verification passes.
- Screenshot set exists or missing captures are blocker-documented.
- Comparison note identifies remaining visual gaps.

## Implementation Notes

- Added `dink_rivals/test/phase5g_visual_golden_test.dart` as a repeatable golden harness for UI screenshot states.
- Captured and checked in:
  - `docs/art/phase-5/phase-5g-menu.png`
  - `docs/art/phase-5/phase-5g-roster.png`
  - `docs/art/phase-5/phase-5g-settings.png`
  - `docs/art/phase-5/phase-5g-endmatch.png`
- Added `docs/art/phase-5/phase-5g-comparison.md` with concept/baseline comparison notes and explicit blockers for the missing game-canvas screenshots.
- `phase-5g-serve.png`, `phase-5g-rally.png`, `phase-5g-point.png`, and `phase-5g-pause.png` are not checked in because the widget golden harness renders the Flame game canvas as black, web is not configured, and no Android device was visible for physical capture.

## Verification Result

Passed from `dink_rivals/` on 2026-05-11:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```
