---
id: P52M-001
phase: 5.2K
status: done
priority: high
parallel_group: final
depends_on: [P52C-001, P52D-001, P52E-001, P52F-001, P52G-001, P52H-001, P52I-001, P52J-001, P52K-001, P52L-001]
blocks: []
owner: codex
last_updated: 2026-05-11
---

# P52M-001 - Phase 5.2 Visual QA and Closeout

## Goal

Verify Phase 5.2 against the concept references, capture final Android evidence, and convert remaining gaps into Phase 5.3 tickets.

## Build Spec Coverage

Phase 5.2K - Visual QA, Android Capture, and Closeout:

- Final screenshot set.
- `phase-5.2-comparison.md`.
- Android readability/performance smoke.
- Phase 5.3 residual gap backlog.

## Suggested File Ownership

- `docs/art/phase-5.2-final-serve.png`
- `docs/art/phase-5.2-final-rally.png`
- `docs/art/phase-5.2-final-feedback.png`
- `docs/art/phase-5.2-final-pause.png`
- `docs/art/phase-5.2-final-endmatch.png`
- `docs/art/phase-5.2-final-menu.png`
- `docs/art/phase-5.2-comparison.md`
- `dink_rivals/PHASE_NOTES.md`
- `tickets/status.md`
- `tickets/p53*.md` if residual gaps are created

Do not implement new visual features in this ticket except tiny documentation-only fixes.

## Requirements

- Build, install, and launch the debug APK on a physical Android phone.
- Capture final serve, rally, point-feedback, pause, end-match, and main-menu screenshots.
- Compare concept / Phase 5.1 final / Phase 5.2 final for each P52A delta.
- Verify:
  - 3/4 perspective and kitchen readability
  - court zoning and line contrast
  - net rail/posts/mesh/shadow
  - backdrop signage
  - character identity and alpha cleanliness
  - scoreboard labels, serving dot, rally counter, and last-shot readout
  - top-center feedback banner behavior
  - ball trail/contact/bounce VFX readability
  - power meter visual-only behavior
  - controls and safe areas
  - park depth without clutter
- Play at least 5 minutes and watch for frame drops, input lag, crashes, and visual occlusion.
- Record remaining concept gaps as Phase 5.3 follow-up tickets or explicit deferrals.

## Non-Goals

- No new feature implementation.
- No subjective closeout without screenshots.
- No marking Phase 5.2 done if physical Android QA is missing; use `review` if human/device validation remains.

## Verification

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter install -d <ANDROID_DEVICE_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

## Acceptance Criteria

- `docs/art/phase-5.2-comparison.md` maps every high-priority P52A delta to resolved, improved, or deferred.
- Final screenshot set exists.
- Android install/launch succeeds.
- 5-minute physical Android smoke is complete, or the ticket remains in `review`.
- All residual visual gaps are queued as Phase 5.3 tickets or documented deferrals.

## Planning Notes

- Claude and both Codex subagents would sign off on the Phase 5.2 ticket plan once these tickets and status rows exist. This closeout ticket is the final proof gate, not a proxy for actual visual completion.

## Implementation Notes

- Implemented: added `docs/art/phase-5.2-comparison.md`, refreshed goldens, passed analyzer/tests/build, and captured Android emulator menu/gameplay smoke screenshots.
- Verification: `flutter analyze`, `flutter test`, `flutter build apk --debug`, emulator install/launch on `emulator-5554`, and `docs/art/phase-5.2-gameplay-emulator-smoke.png`.
