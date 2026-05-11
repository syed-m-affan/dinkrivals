# Phase 5G Visual Comparison

Date: 2026-05-11

## Captured Automated Goldens

The repeatable Flutter golden harness is in `dink_rivals/test/phase5g_visual_golden_test.dart`.

- `docs/art/phase-5g-menu.png`
- `docs/art/phase-5g-roster.png`
- `docs/art/phase-5g-settings.png`
- `docs/art/phase-5g-endmatch.png`

Generated with:

```bash
flutter test --update-goldens test/phase5g_visual_golden_test.dart
```

Verified with:

```bash
flutter test test/phase5g_visual_golden_test.dart
```

## Blocked Captures

The requested `phase-5g-serve.png`, `phase-5g-rally.png`, `phase-5g-point.png`, and `phase-5g-pause.png` screenshots are not checked in yet.

- `flutter build web --debug` reported that the project is not configured for web, so browser screenshots are unavailable without adding web platform files.
- The Flutter widget golden harness can load `GameScreen`, but the Flame game canvas renders as a black surface in this test environment. The Flutter pause button/overlay renders, but the gameplay scene itself is not a valid visual capture.
- `flutter devices` showed only Windows, Chrome, and Edge; no Android device was visible for physical screenshot capture.

## Comparison Against Concept and Phase 5 Baseline

Compared with `docs/art/concept-screenshot.png`, the current build is materially closer in these areas:

- Stronger arcade UI framing through shared panels/buttons.
- More cohesive roster/end-match character presentation through refreshed portraits.
- Denser Classic Court dressing, upgraded court material, net details, shadows, VFX, and HUD treatment in runtime code.
- More discrete player/opponent animation states for ready, contact confirmation, and point result reactions.

Remaining gaps:

- Automated gameplay screenshots are still blocked, so court readability, VFX readability, and character animation polish need Android or another real-rendering capture path.
- The menu golden still has a large empty top area and does not strongly show the logo in the captured test state; this should be reviewed on device before deciding whether it is a real runtime issue or golden-harness asset timing.
- The concept art remains richer in environment depth and character personality than the current low-detail placeholder art direction.
- Rally Queen and Veteran portrait accent reads are acceptable but not final-quality: Rally Queen reads mostly as yellow hair on pink, and Veteran's mint accent is subtle.

## Automated Verification

Latest local verification passed:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Android readability/performance validation remains blocked until a physical Android device is available.

## Follow-Up Tickets

- `P5H-001`: Gameplay golden capture harness for Flame-rendered states;
  deferred in `review` because automated gameplay screenshot setup is no
  longer a closeout priority.
- `P5H-002`: Optional Flutter web screenshot capture path; deferred in
  `review` for the same reason.
- `P5H-003`: Main menu logo prominence and top-band composition; absorbed by
  Phase 5.2 closeout.
- `P5H-004`: Rally Queen portrait readability pass; absorbed by `P52F-001`.
- `P5H-005`: Veteran portrait accent pass; absorbed by `P52F-001`.
- `P5H-006`: Environment depth background band; absorbed by `P52E-001` and
  `P52K-001`.
- `P5H-007`: Character idle/ready micro-animation; deferred in `review` until
  animation polish has explicit visual signoff.
