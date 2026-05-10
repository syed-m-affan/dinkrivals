---
id: P1-007
phase: 1
status: review
priority: high
parallel_group: final
depends_on: [P1-003, P1-005, P1-006]
blocks: []
owner: codex
last_updated: 2026-05-10
---

# P1-007 - Phase 1 Verification and QA

## Goal

Verify Phase 1 as a playable gray-box arcade pickleball match and update handoff notes for the next phase.

## Build Spec Coverage

Phase 1 acceptance criteria and Android QA checklist.

## Suggested File Ownership

- `dink_rivals/PHASE_NOTES.md`
- `tickets/p1-007-phase-1-verification.md`
- `tickets/status.md`
- New follow-up tickets under `tickets/` if QA finds issues.

Do not make gameplay code changes in this ticket unless they are tiny fixes required to complete QA. Larger issues should become new tickets.

## Verification Commands

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter run -d <ANDROID_DEVICE_ID>
```

## Manual Android QA

- Play 3 full matches.
- Force out-of-bounds.
- Force double bounce.
- Try kitchen volley.
- Produce dink, drive, lob, and smash contact classifications.
- Confirm these shot labels are produced by swing/contact physics, not by player-facing shot buttons.
- Confirm match ends at 7.
- Confirm score updates correctly.
- Confirm feedback text appears for shots and faults.
- Confirm opponent can sustain beginner rallies.
- Play for 5 minutes without crash.
- Record tuning notes.

## Acceptance Criteria

- Full match can be played to 7.
- Score updates correctly.
- Out-of-bounds awards point.
- Double bounce awards point.
- Kitchen volley fault works.
- Dink, drive, lob, and smash are produced by racket contact and are visible in feedback.
- No dink/drive/lob/smash buttons are present.
- Opponent can sustain beginner rallies.
- Android build runs on a physical device.
- No crash after 5 minutes.
- `dink_rivals/PHASE_NOTES.md` includes Phase 1 QA results and known issues.
- `tickets/status.md` marks Phase 1 complete only if all `P1-*` tickets are done.

## Automated Evidence

Completed on 2026-05-10:

- `flutter analyze` passed.
- `flutter test` passed 27/27.
- `flutter build apk --debug` passed.
- `flutter install --debug -d 58011FDCQ00992` passed.
- Android launch smoke test passed via `adb shell am start -W -n com.example.dink_rivals/.MainActivity` with status `ok` and wait time 3053ms.
- `dumpsys window` showed `mFocusedApp=ActivityRecord ... com.example.dink_rivals/.MainActivity`, but the screen was locked (`mCurrentFocus=NotificationShade`), so gameplay scene visuals remain unverified.
- After unlocking, a device screenshot verified the gameplay scene renders with the score display, court/kitchen/net, player/opponent, ball/shadow, reset button, movement stick, and swing stick.
- A limited `adb shell input swipe` on the swing control visibly changed gameplay state, but this is not a substitute for full-match manual QA.

Implementation present:

- `MatchState` and `ScoringSystem`.
- `MatchRulesSystem` for out-of-bounds, double bounce, and kitchen volley.
- Game-loop point reset and first-to-7 match state.
- Expanded racket-contact classifications for dink, drive, lob, and smash.
- Opponent AI classification choices.
- Score display and rally/fault feedback.

## Manual QA Still Required

Keep this ticket in `review` until a human verifies on Android:

- Play 3 full matches.
- Force out-of-bounds.
- Force double bounce.
- Try kitchen volley for player and opponent if practical.
- Produce dink, drive, lob, and smash contact classifications.
- Confirm no explicit shot buttons are present or needed for those classifications.
- Confirm match ends at 7.
- Confirm score updates correctly throughout a match.
- Confirm feedback text appears for shots and faults.
- Confirm opponent can sustain beginner rallies.
- Play for 5 minutes without crash.
