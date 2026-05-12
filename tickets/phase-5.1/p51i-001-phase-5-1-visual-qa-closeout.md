---
id: P51I-001
phase: 5.1I
status: review
priority: high
parallel_group: final
depends_on: [P51B-001, P51C-001, P51D-001, P51E-001, P51F-001, P51G-001, P51H-001]
blocks: []
owner: unassigned
last_updated: 2026-05-11
---

# P51I-001 - Phase 5.1 Visual QA and Closeout

## Goal

Verify that Phase 5.1 materially moves the current gameplay screenshot closer to the concept screenshot, then document remaining gaps for future work.

## Build Spec Coverage

Phase 5.1I - Visual QA, Android Capture, and Closeout:

- Final Android screenshot set.
- Side-by-side concept / before / after comparison.
- Android readability and performance check.
- Residual gap backlog.

## Suggested File Ownership

- `docs/art/phase-5.1/phase-5.1-comparison.md`
- `docs/art/phase-5.1/phase-5.1-*.png`
- `dink_rivals/PHASE_NOTES.md`
- `tickets/status.md`
- New follow-up tickets if gaps remain

Do not make implementation changes in this closeout ticket unless the change is limited to documentation or ticket metadata.

## Requirements

- Run final verification commands.
- Install and launch on a physical Android device if available.
- Capture the Phase 5.1 acceptance screenshot set defined by P51A:
  - waiting-to-serve / serve
  - post-serve rally
  - point feedback
  - pause
  - post-match or menu if needed
- Create side-by-side comparison notes against:
  - `docs/art/concepts/concept-screenshot.png`
  - the Phase 5.1 baseline screenshot
  - final Phase 5.1 screenshots
- Confirm each P51A high-priority delta is resolved, improved, or explicitly deferred.
- Record remaining gaps as follow-up tickets, likely Phase 5.2.
- Update `tickets/status.md` and `PHASE_NOTES.md`.

## Non-Goals

- No new implementation work.
- No additional visual scope beyond follow-up ticket creation.
- No Phase 6 tournament work.

## Verification

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter install -d <ANDROID_DEVICE_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

If Android is unavailable or locked, document the blocker and keep this ticket in `review`.

## Acceptance Criteria

- `flutter analyze`, `flutter test`, and `flutter build apk --debug` pass.
- Android install/launch and 5-minute readability/performance QA are complete, or the blocker is documented and the ticket remains in `review`.
- `docs/art/phase-5.1/phase-5.1-comparison.md` shows concept / before / after evidence.
- Remaining visual gaps are converted into follow-up tickets.
- No gameplay, scoring, controls, ads, audio toggle, or haptics regressions are observed.

## Planning Notes

- This ticket is the only Phase 5.1 closeout gate; do not mark Phase 5.1 complete from implementation tickets alone.

## Review Notes

- 2026-05-11: Android install and launch passed on Pixel 10 Pro XL (`58011FDCQ00992`).
- 2026-05-11: Captured `docs/art/phase-5.1/phase-5.1-final-serve.png`, `docs/art/phase-5.1/phase-5.1-final-rally.png`, and `docs/art/phase-5.1/phase-5.1-final-pause.png`.
- 2026-05-11: The 5-minute Android smoke remains incomplete. A long-running smoke command was interrupted at about 3 minutes, and the Pixel disconnected from Flutter/ADB before a clean restart could complete.
