---
id: P5B-003
phase: 5B
status: review
priority: medium
parallel_group: final
depends_on: [P5B-002]
blocks: [P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5B-003 - Environment Android Readability QA

## Goal

Verify the Classic Court environment pass on Android and document any readability issues as follow-up tickets.

## Build Spec Coverage

Phase 5B Android QA Checklist:

- Serve, rally, and point-feedback screenshots.
- Player/opponent never hidden by props.
- Ball shadow remains visible.
- Environment does not distract from in/out calls.

## Suggested File Ownership

- `docs/art/phase-5/phase-5b-serve.png` (new)
- `docs/art/phase-5/phase-5b-rally.png` (new)
- `docs/art/phase-5/phase-5b-feedback.png` (new)
- `dink_rivals/PHASE_NOTES.md`
- `tickets/status.md`
- New follow-up tickets under `tickets/` only if QA finds issues.

Do not make implementation fixes in this ticket beyond trivial documentation corrections.

## Verification Commands

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
flutter install -d <ANDROID_DEVICE_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

## Acceptance Criteria

- Automated verification passes.
- Android screenshots are captured or capture blockers are documented.
- `PHASE_NOTES.md` records environment readability results.
- Follow-up tickets exist for any non-trivial issues.

## Review Notes

- Automated verification passed during the Phase 5A-G implementation pass.
- Android screenshot capture is blocked in this session because `flutter devices` did not show an Android device, only Windows, Chrome, and Edge.
- The latest debug APK was copied to workspace root as `dink_rivals-debug.apk` for manual install/retry and is covered by `.gitignore`.
- Environment readability results still need a physical Android pass before this ticket can move to `done`.
