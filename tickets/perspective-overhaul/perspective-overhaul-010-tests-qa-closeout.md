---
id: PERSP-010
phase: perspective-overhaul
status: review
priority: high
parallel_group: closeout
depends_on: [PERSP-001, PERSP-002, PERSP-003, PERSP-004, PERSP-005, PERSP-006, PERSP-007, PERSP-008, PERSP-009]
blocks: []
owner: unassigned
last_updated: 2026-05-11
---

# PERSP-010 - Tests, Screenshot Set, and Physical-Device QA

## Goal

Land the overhaul: collect before/after screenshots, run the full test matrix, and complete physical-Android QA per `docs/specs/build-spec.md` §5.4.

## Suggested file ownership

- `docs/art/perspective-overhaul/perspective-overhaul-comparison.md` (new doc)
- `docs/art/perspective-overhaul/perspective-after-screenshot.png` (new asset, captured on a physical device)
- `docs/art/perspective-overhaul/perspective-overhaul-002-layout.png` etc. (already captured by intermediate tickets — referenced from the comparison doc)
- `tickets/status.md`
- Existing test files only as needed for closeout regressions.

## Required deliverables

1. **Before/after composite.** Create `docs/art/perspective-overhaul/perspective-overhaul-comparison.md` with side-by-side references:
   - Before: `docs/art/perspective-overhaul/perspective-before-screenshot.png` (existing, untracked — stage and commit as part of this ticket).
   - After: `docs/art/perspective-overhaul/perspective-after-screenshot.png` (new; captured on a physical Pixel-class Android device).
   - Concept target: `docs/art/concepts/concept-screenshot.png`.
   - Short paragraph on what changed and what is still gap vs. concept.

2. **Test sweep.**
   - `flutter analyze` — zero issues.
   - `flutter test` — all green.
   - Explicit re-run of the projection contract tests added in PERSP-001 and the headline tests in PERSP-003 (opponent height ratio), PERSP-004 (ball/shadow gap grows toward camera), PERSP-005 (net cord horizontal in screen space), PERSP-008 (swing lane taper).

3. **Build + install.**
   - `flutter build apk --debug` succeeds.
   - Installed on a physical Pixel 10 Pro XL-class device.
   - 5-minute rally without crash. Frame rate stays at the platform default for the device.

4. **Status update.**
   - Mark `PERSP-001` through `PERSP-009` as `done`.
   - Mark `PERSP-010` as `done` only when all of the above are complete.
   - Append a single-line summary entry under `tickets/status.md`.

## Acceptance criteria

- `docs/art/perspective-overhaul/perspective-after-screenshot.png` exists and shows a court with the trapezoid, near vs. far entity scaling, and visible ball/shadow separation matching the concept direction.
- Side-by-side comparison shows: near baseline ≥ 1.7× far baseline width, opponent ≤ 0.7× player projected height at start positions, lob ball/shadow gap visibly larger near than far.
- Full test suite is green.
- Physical Android device QA done.
- All ten perspective-overhaul tickets resolved.

## Implementation notes

Before/after screenshots and `docs/art/perspective-overhaul/perspective-overhaul-comparison.md` are present. The latest recorded verification for this pass is `flutter analyze`, `flutter test`, `flutter build apk --debug`, install to Pixel 10 Pro XL (`58011FDCQ00992`) for `docs/art/perspective-overhaul/perspective-after-screenshot.png`, and latest APK install/smoke on `emulator-5554` when Pixel was not visible. PERSP-010 remains in `review`, not `done`, because the remaining gate is the user's 5-minute human rally/signoff against `docs/art/concepts/concept-screenshot.png`.
