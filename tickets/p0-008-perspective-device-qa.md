---
id: P0-008
phase: 0
status: todo
priority: high
parallel_group: final
depends_on: [P0-006, P0-007]
blocks: []
owner: unassigned
last_updated: 2026-05-11
---

# P0-008 - Perspective Device QA

## Goal

Verify the gray-box perspective pass on a physical Android device and record whether the game now feels meaningfully closer to the concept screenshot.

This is the checkpoint for the user-reported issue: Phase 2 perspective feels too top-down and lacks depth compared with `docs/art/concept-screenshot.png`.

## Build Spec Coverage

Build-spec requirement: 3/4 court perspective only, with full court, net, kitchen zones, players, ball, and shadow visible.

## Suggested File Ownership

- `dink_rivals/PHASE_NOTES.md`.
- `tickets/p0-008-perspective-device-qa.md`.
- `tickets/status.md`.
- Optional: add a new screenshot under `docs/art/` if captured during QA.

Do not make gameplay or projection changes in this ticket beyond tiny documentation corrections. If QA finds more perspective work, create a follow-up ticket.

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

- Launch app on a physical Android device.
- Start Quick Match.
- Capture or inspect a gameplay screenshot during a normal rally.
- Compare against:
  - `docs/art/concept-screenshot.png`.
  - `docs/art/phase-2-screenshot.png`.
- Confirm whether the court feels less top-down and has clearer depth.
- Confirm the full court, kitchens, net, player, opponent, ball, ball shadow, score, feedback, and controls are visible.
- Confirm controls do not overlap the active court in a way that blocks play.
- Play at least 5 minutes and watch for visual jitter, bad draw order, or unreadable ball height.

## Acceptance Criteria

- Human QA confirms the perspective is materially improved over the Phase 2 screenshot.
- `PHASE_NOTES.md` records the screenshot comparison result and any remaining issues.
- `tickets/status.md` is updated with the final ticket status.
- `flutter analyze`, `flutter test`, and debug APK build pass.
- App launches and runs on Android for at least 5 minutes without crash.
