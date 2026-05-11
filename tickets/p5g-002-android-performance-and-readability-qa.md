---
id: P5G-002
phase: 5G
status: todo
priority: high
parallel_group: B
depends_on: [P5G-001]
blocks: [P5G-003]
owner: unassigned
last_updated: 2026-05-11
---

# P5G-002 - Android Performance and Readability QA

## Goal

Run the physical Android visual QA checklist and performance gate for the expanded Phase 5A-5F visuals.

## Build Spec Coverage

Phase 5G Android QA Checklist:

- Fresh install.
- Start Quick Match in under 3 taps.
- Play at least 3 full matches.
- 10 minute uptime.
- Readability checks for ball, shadow, court lines, kitchen, net, score, pause, and controls.
- SFX/haptics settings still respected.

## Suggested File Ownership

- `dink_rivals/PHASE_NOTES.md`
- `tickets/status.md`
- New follow-up bug tickets under `tickets/` if QA finds issues.

Do not bundle implementation fixes in this ticket.

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

- Fresh install on Android phone.
- Launch and start Quick Match in under 3 taps.
- Play at least 3 full matches.
- Keep the app running for at least 10 minutes.
- Confirm no UI overlaps notch, gesture nav, joystick, swing stick, serve button, score, pause, or feedback.
- Confirm ball, ball shadow, court lines, kitchen, and net remain readable during active play.
- Confirm SFX and haptics still respect settings.
- Record performance observations and device model.

## Acceptance Criteria

- Debug APK installs and launches on Android.
- Manual QA results are recorded in `PHASE_NOTES.md`.
- Any non-trivial issues have follow-up tickets.

