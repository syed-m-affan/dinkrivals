---
id: P5-007
phase: 5
status: review
priority: high
parallel_group: final
depends_on: [P5-001, P5-002, P5-003, P5-004, P5-005, P5-006]
blocks: []
owner: codex
last_updated: 2026-05-11
---

# P5-007 - Phase 5 Verification and Android QA

## Goal

Verify the full Phase 5 visual identity pass on a physical Android device. Confirm sprites, palette, scoreboard, feedback styling, audio, and haptics all land without regressing Phases 0–3.

## Build Spec Coverage

Phase 5 Acceptance Criteria and Android QA Checklist (build-spec §13).

## Suggested File Ownership

- `dink_rivals/PHASE_NOTES.md` — append Phase 5 QA results and known issues.
- `tickets/p5-007-phase-5-verification.md`
- `tickets/status.md` — mark P5-001..P5-006 `done` and update the Current Assessment.
- New follow-up tickets under `tickets/` only if QA finds issues; do not bundle implementation fixes into this ticket.

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

From build-spec Phase 5:

- Fresh install on Android phone.
- Launch app — confirm new logo on main menu and themed buttons.
- Open Roster — confirm 4 character portraits render.
- Open Settings:
  - Toggle Sound off, return to a match, swing racket → no hit SFX, no bounce SFX, no fault SFX, no point SFX.
  - Toggle Sound on → SFX return on the same events.
  - Toggle Haptics off → no vibration on player hit or point win.
  - Toggle Haptics on → light buzz on hit, medium buzz on point win.
- Start Quick Match:
  - Player, opponent, ball, paddles render as sprites.
  - Court reads as retro pixel art.
  - Kitchen zone still visible.
  - Net still readable.
  - 3/4 projection still correct: ball shadow under ball, depth scale at near/far baselines, no visual flattening.
  - Scoreboard shows serving-side indicator.
  - DINK / DRIVE / LOB / SMASH / FAULT each show in distinct colors.
- Play 3 full matches. Confirm no frame drops on a modern Android device.
- Play 5+ minutes uptime — no crash.
- Confirm UI clears notch / nav bar (SafeArea from P2-008 still in effect).
- Force kill and relaunch — Sound and Haptics toggles persist.
- Record results, tuning notes, and any visual gaps in `PHASE_NOTES.md`.

## Acceptance Criteria

- All Phase 5 implementation tickets (P5-001..P5-006) are `done`.
- `flutter analyze` reports zero issues.
- `flutter test` passes including new sprite, audio, and haptics tests.
- Debug APK installs and launches on Android.
- Manual QA checklist completes without regressions.
- `PHASE_NOTES.md` records Phase 5 results.
- `tickets/status.md` Current Assessment summarizes Phase 5 outcome.

## Non-Goals

- No implementation fixes inside this ticket. Anything more than trivial copy/doc changes becomes a follow-up `p5-00x` ticket.
- No Phase 4 (real AdMob) or Phase 6 (tournament) work.

## Automated Verification

- `flutter pub get`: satisfied by `flutter pub add flame_audio` and subsequent build/test resolution.
- `flutter analyze`: passed, zero issues.
- `flutter test`: passed, 96 tests.
- `flutter build apk --debug`: passed.
- `flutter install --debug -d 58011FDCQ00992`: passed on Pixel 10 Pro XL.

## Manual QA Pending

This ticket remains in `review` because the physical-device human checklist still needs to be completed: visual readability, sound/haptics toggles by feel/hearing, 3 full matches, 5+ minute uptime, notch/nav clearance, and force-kill persistence.
