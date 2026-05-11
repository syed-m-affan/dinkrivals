# Phase 5.2 Comparison and Closeout

Last updated: 2026-05-11

## Evidence

- Baseline/delta inventory: `docs/art/phase-5.2-delta-inventory.md`
- Visual rules and prompt direction: `docs/art/phase-5.2-art-direction.md`
- Generated asset contact sheet: `docs/art/phase-5.2-generated-asset-contact-sheet.png`
- Emulator menu smoke: `docs/art/phase-5.2-emulator-smoke.png`
- Emulator gameplay smoke: `docs/art/phase-5.2-gameplay-emulator-smoke.png`
- Final menu screenshot: `docs/art/phase-5.2-final-menu.png`
- Final serve screenshot: `docs/art/phase-5.2-final-serve.png`
- Final rally screenshot: `docs/art/phase-5.2-final-rally.png`
- Final feedback screenshot: `docs/art/phase-5.2-final-feedback.png`
- Final pause screenshot: `docs/art/phase-5.2-final-pause.png`
- Final end-match screenshot: `docs/art/phase-5.2-final-endmatch.png`
- Updated UI golden: `docs/art/phase-5g-endmatch.png`

## Concept Delta Results

| Region | Result | Notes |
| --- | --- | --- |
| Projection/framing | Improved | Court projection uses stronger near/far width and z displacement while preserving logical coordinate tests. Emulator gameplay reads as a taller 3/4 court with bottom controls clear of the baseline. The final pass uses the guarded linear tuning documented in `docs/art/visual-overhaul/perspective-metrics.md`. |
| Court zoning | Resolved | Court now has a navy apron, lighter playing surface, tinted kitchen zone, stronger line contrast, generated low-opacity acrylic texture, scuffs, and subtle surface wear. |
| Net and serving indicator | Resolved | Net has thicker posts, rail, mesh, and a stronger visual footprint. Serving state is integrated into the scoreboard flow instead of relying on a loose mid-scene marker. |
| Backdrop signage | Improved | Rear environment now includes original `DINK RIVALS` and `PARK COURTS` sign assets plus lamp/planter depth props. |
| Character identity | Improved | Player and opponent sprite sheets were regenerated into a simpler mid-detail pixel style with chunkier silhouettes and fewer small details, sitting between the old placeholders and the too-detailed first generated pass. Dink, drive, lob, and smash now have distinct generated sheets. |
| Character animation framing | Resolved | Generated shot sheets now render using their actual frame counts instead of hardcoded multi-frame slicing, so one-frame shot poses no longer show only half the character. Player and opponent sprites also reflect horizontally based on movement direction. |
| Scoreboard/rally/last-shot readout | Resolved | HUD now shows YOU/RIVAL score panels, serving dot, rally count, and last-shot readout. |
| Feedback banner | Resolved | Rally feedback renders in a top-center banner with primary/secondary text helpers and safe-area-aware placement. |
| Ball trail/contact VFX | Resolved | VFX layer uses fixed-size trail buffering, refreshed contact/bounce sprites, and clears trails on contact, bounce, and point reset. |
| Controls | Resolved | Assisted controls and obsolete swing-power affordances are removed. The remaining percentage/ring feedback is tied to serve charge only, while manual move/swing touch regions are preserved. |
| Park depth | Improved | Added a darker rear tree band treatment, lamp, planters, and signage without changing gameplay bounds. |
| Android game framing | Improved | GameScreen now renders the Flame canvas full-bleed in immersive mode instead of padding the whole game below the cutout/status area. Tappable Flutter controls still respect top/right view padding. |
| Menu/end-match residual composition | Improved | Generated portraits and updated goldens keep the existing menu/end-match flow intact; deeper screen redesign is deferred unless requested. |

## Android/Emulator QA

- `flutter build apk --debug`: passed.
- `flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk`: passed.
- App launched on `emulator-5554`.
- Menu, serve, rally/countdown, feedback, and pause screenshots were captured from the current emulator build.
- Repeatable Android evidence capture is available via
  `tools/capture_android_evidence.ps1`; it launches the app, captures menu,
  enters Quick Match, captures serve, pauses, and captures pause.
- Full-bleed Android gameplay evidence after removing the top letterbox:
  `docs/art/visual-overhaul/evidence/full-bleed-game-screen-pass/serve.png`.
- The simple-mid character revision was also installed and smoke-captured on
  `emulator-5554` at
  `docs/art/visual-overhaul/evidence/emulator-character-simple-mid-gameplay.png`.
- Character frame-count/facing fix was verified on `emulator-5554` with
  evidence at
  `docs/art/visual-overhaul/evidence/character-animation-frame-fix/gameplay.png`.
- End-match evidence uses the refreshed UI golden because reaching match end deterministically from ADB is not part of the current gameplay harness.
- The latest Pixel install succeeded when the device was available; the final texture pass used emulator evidence because the Pixel was disconnected.

## Residual Gaps

- Physical-device human playtest and subjective concept-art signoff remain outside this automated closeout.
- Swing/hitbox indicator readability still needs live visual review; avoid
  spending more time on screenshot automation unless it directly unblocks a
  gameplay or visual decision.
