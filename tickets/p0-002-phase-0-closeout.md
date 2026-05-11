---
id: P0-002
phase: 0
status: done
priority: high
parallel_group: closeout
depends_on: []
blocks: [P1-007]
owner: unassigned
last_updated: 2026-05-10
---

# P0-002 - Phase 0 Closeout

## Goal

Close Phase 0 cleanly so future agents can treat the gray-box rally prototype as the foundation for Phase 1 instead of re-litigating completed setup work.

Phase 0 closeout uses the current swing-control scheme. Do not evaluate this ticket against the older tap/hold dink-drive button prototype.

## Current State

Phase 0 implementation exists in `dink_rivals/` and includes:

- Flutter + Flame project.
- Direct boot into `DinkRivalsGame`.
- 3/4 court projection with visible court, net, and kitchen zones.
- Player, opponent, ball, and ball shadow.
- Visible left movement joystick and right swing joystick.
- Automatic racket-contact hits from a 180-degree front racket swing.
- A full racket-segment hitbox from player body to racket tip.
- Pseudo-3D ball physics with bounces and boundary rebounds.
- Simple opponent AI.
- Debug overlay and reset point button.
- Unit tests for projection, ball physics, and shot hitbox behavior.
- Android playtest notes through the seventh tuning pass.
- Eighth-pass control rework removes the dink/drive button and uses automatic racket contact from a right-side swing stick.
- Tenth-pass control update extends the hitbox to the full racket segment and removes the confusing shaded endpoint circle.

## Remaining Work

1. Run the latest build on a physical Android device.
2. Answer the latest swing-control playtest questions in `dink_rivals/PHASE_NOTES.md`.
3. Confirm whether 10+ crossing rallies are achievable with the current tuning.
4. Confirm the controls feel understandable in the first 30 seconds.
5. Confirm shot labels are understandable as automatic contact classifications, not player-selected buttons.
6. Record any residual tuning problems as new tickets instead of expanding Phase 0 scope.
7. Update `tickets/status.md` and this ticket with the final closeout result.

## Suggested File Ownership

- `dink_rivals/PHASE_NOTES.md`
- `tickets/p0-002-phase-0-closeout.md`
- `tickets/status.md`

Do not edit gameplay code for this ticket unless the human explicitly asks for a final Phase 0 tuning change.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
flutter run -d <ANDROID_DEVICE_ID>
```

Manual Android QA:

- Launch app.
- Confirm `PHASE 0` label appears.
- Move with joystick.
- Swing racket with right-side swing stick.
- Confirm no separate dink/drive button is shown.
- Confirm first/reset hit uses the racket hitbox, not the player body.
- Confirm full player-to-racket-tip segment contact feels fair.
- Confirm the missing shaded endpoint circle does not reduce hitbox readability.
- Reset point.
- Play for 5 minutes.
- Attempt a 10+ crossing rally.

## Acceptance Criteria

- Latest code passes analyze and tests.
- Debug APK builds.
- Physical Android run is recorded.
- `PHASE_NOTES.md` clearly states whether Phase 0 is accepted or which follow-up ticket blocks acceptance.
- `tickets/status.md` is updated.

## Automated Evidence

Latest automated verification on 2026-05-10:

- `flutter analyze` passed.
- `flutter test` passed 27/27.
- `flutter build apk --debug` passed.
- `flutter install --debug -d 58011FDCQ00992` passed.
- Android launch smoke test passed via `adb shell am start -W -n com.example.dink_rivals/.MainActivity` with status `ok` and wait time 3053ms.
- `dumpsys window` showed `mFocusedApp=ActivityRecord ... com.example.dink_rivals/.MainActivity`, but the screen was locked (`mCurrentFocus=NotificationShade`), so gameplay scene visuals remain unverified.
- After unlocking, a device screenshot verified the gameplay scene renders with the PHASE 0 debug label, score display, court/kitchen/net, player/opponent, ball/shadow, reset button, movement stick, swing stick, and no separate dink/drive button.
- A limited `adb shell input swipe` on the swing control visibly changed gameplay state.

## Manual QA Still Required

Keep this ticket in `review` until a human confirms the current swing-control build:

- Controls are understandable in the first 30 seconds.
- First/reset hit clearly uses the racket, not the body.
- Full racket-segment hitbox feels fair.
- Dink/drive are understood as contact outcomes, not missing buttons.
- 10+ crossing rallies are achievable.
- App runs for 5 minutes without crash.
