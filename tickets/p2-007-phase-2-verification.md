---
id: P2-007
phase: 2
status: review
priority: high
parallel_group: final
depends_on: [P2-002, P2-003, P2-004, P2-005, P2-006]
blocks: []
owner: claude
last_updated: 2026-05-10
---

# P2-007 - Phase 2 Verification and QA

## Goal

Verify the Phase 2 app shell on a physical Android device and record results before Phase 3 begins.

## Build Spec Coverage

Phase 2 acceptance criteria and Android QA checklist (build-spec §13 Phase 2).

## Suggested File Ownership

- `dink_rivals/PHASE_NOTES.md`.
- `tickets/p2-007-phase-2-verification.md`.
- `tickets/status.md`.
- New follow-up tickets under `tickets/` if QA finds issues.

Do not make non-trivial gameplay or UI changes in this ticket. Anything more than a one-line fix to clear QA should become a new ticket.

## Verification Commands

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter install -d <ANDROID_DEVICE_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

## Manual Android QA Checklist

From build-spec §13 Phase 2:

- Launch app — boots into main menu, not directly into gameplay.
- Start Quick Match from the menu.
- Pause mid-rally — physics and AI freeze.
- Resume — rally continues without snapping.
- Return to Menu from pause — match resets to 0-0.
- Finish a match by playing to 7 — end-match summary appears with correct winner and score.
- Tap Rematch — fresh 0-0 match starts.
- Tap Return to Menu — app sits cleanly on `/`.
- Open Settings — toggle Sound off, return to menu, reopen Settings: toggle still off.
- Kill and relaunch the app, reopen Settings — Sound toggle still reflects off.
- Open Roster — four MVP characters listed.
- Hardware back from `/game` opens pause overlay, not silent quit.
- Play for at least 5 minutes total without crash.
- Record framerate or layout issues (notch, nav bar, control overlap) in `PHASE_NOTES.md`.

## Acceptance Criteria

- All Phase 2 ticket acceptance criteria are met across `P2-001..P2-006`.
- App launches to the menu and respects the build-spec rule of no forced ad before first gameplay (Phase 3 hasn't shipped yet; this should remain trivially true).
- Settings persist across an actual app restart on device.
- Match can pause and resume, and end-match summary appears at match completion.
- App runs 5 minutes on device without crash.
- `PHASE_NOTES.md` includes Phase 2 QA results and any known issues.
- `tickets/status.md` marks Phase 2 complete only after this ticket and all `P2-*` tickets are `done`.

## Automated Evidence

Completed on 2026-05-10:

- `flutter analyze` passed with zero warnings.
- `flutter test` passed 47/47 (30 prior + 17 Phase 2: save_service, save_data_notifier, settings_screen widget, end_match_screen widget, dink_rivals_game pause).
- `flutter build apk --debug` succeeded.
- Android install was attempted via `flutter install -d 58011FDCQ00992 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk`; device was disconnected at install time, so the install + on-device smoke test was not completed in-session.

## Manual QA Still Required

This ticket stays in `review` until a human verifies on a physical Android device. Automated install + smoke from the desktop tooling is **not** a substitute for the manual checklist above.
