---
id: P3-006
phase: 3
status: review
priority: high
parallel_group: final
depends_on: [P3-001, P3-002, P3-003, P3-004, P3-005]
blocks: []
owner: codex
last_updated: 2026-05-11
---

# P3-006 - Phase 3 Verification and QA

## Goal

Verify the complete fake ad framework on a physical Android device before Phase 4 real AdMob test ads begin.

## Build Spec Coverage

Phase 3 acceptance criteria and Android QA checklist.

## Suggested File Ownership

- `dink_rivals/PHASE_NOTES.md`.
- `tickets/phase-3/p3-006-phase-3-verification.md`.
- `tickets/status.md`.
- New follow-up tickets under `tickets/` if QA finds issues.

Do not make non-trivial implementation changes in this ticket. Anything more than a tiny QA documentation fix should become a follow-up ticket.

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

From build-spec Phase 3:

- Fresh install.
- Launch app and start Quick Match.
- Play first 3 matches.
- Confirm no interstitial appears before it is eligible.
- Complete enough matches/time for fake interstitial eligibility.
- Confirm fake interstitial appears only after a match, not during gameplay.
- Dismiss fake interstitial and confirm navigation remains usable.
- Tap rewarded ad button from post-match screen.
- Confirm fake rewarded ad is user-initiated and reward doubles.
- Confirm fake ads never appear during rallies, point reset, pause, main menu launch, settings, or roster.
- Play for at least 5 minutes without crash.
- Record results in `PHASE_NOTES.md`.

## Acceptance Criteria

- All Phase 3 implementation tickets are complete.
- Fake rewarded ad only appears after user taps button.
- Fake rewarded ad grants the placeholder reward.
- Fake interstitial appears only after allowed match breaks.
- No fake ad appears during gameplay.
- No interstitial appears during the first 3 completed matches.
- Frequency caps work.
- App runs on a local Android phone.
- `PHASE_NOTES.md` records Phase 3 QA results and any known issues.

## Automated Evidence

Completed on 2026-05-11:

- `flutter analyze`: passed with no issues.
- `flutter test`: passed 73/73.
- `flutter build apk --debug`: passed.
- `flutter install -d 58011FDCQ00992 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk`: passed.
- Android launch command returned `Status: ok` for `com.example.dink_rivals/.MainActivity`.

## Manual QA Still Required

This ticket stays in `review` until a human completes the full Phase 3 Android QA checklist. In-session screenshot capture after launch showed the physical device lock screen, so visual confirmation of the app and manual fake-ad flows could not be completed from the desktop tooling.
