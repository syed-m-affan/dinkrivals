# Visual Overhaul Completion Audit

Date: 2026-05-11

Objective audited: implement the visual overhaul plan as fully as possible
without human intervention, using generated bitmap assets where practical and
subagent validation for human-review-style checks.

## Verdict

Not complete.

The implementation has materially advanced environment density, screen cohesion,
shot VFX, HUD feedback, menu styling, generated character sheets, court surface
polish, perspective tuning, and Android build/install coverage. It does not yet
satisfy the visual-overhaul definition of done because subjective perspective
signoff and physical-device gameplay evidence remain outside the current
automated evidence set.

## Requirement Checklist

| Requirement | Evidence | Status |
| --- | --- | --- |
| Use generated bitmap art for new core visuals | `assets/images/environment/classic/park_background_overhaul.png`, `assets/images/vfx/*_generated.png`, `assets/images/sprites/player_*.png`, `assets/images/sprites/opponent_*.png`, `assets/images/court/court_surface_texture_generated.png`, `docs/art/visual-overhaul/contact-sheets/shot-vfx-generated-sheet.png`, `docs/art/visual-overhaul/contact-sheets/character-sprite-generated-atlas.png`, `docs/art/visual-overhaul/contact-sheets/character-sprite-mid-detail-runtime-sheet.png`, `docs/art/visual-overhaul/contact-sheets/character-sprite-simple-mid-runtime-sheet.png`, `docs/art/visual-overhaul/contact-sheets/court-surface-texture-generated.png`, `docs/art/visual-overhaul/prompts/shot-vfx-generated-sheet.md`, `docs/art/visual-overhaul/prompts/character-sprite-generated-atlas.md`, `docs/art/visual-overhaul/prompts/court-surface-texture-generated.md` | Done for current pass |
| Preserve gameplay logic and controls while improving visuals | Guard tests passed after reverting the failed projection experiment: `flutter test test/court_projection_test.dart test/court_layout_system_test.dart test/environment_layout_test.dart`; full suite passed after the generated character integration | Partial |
| Environment reads denser and layered | `ClassicEnvironmentComponent`, `EnvironmentLayout.classicProps`, `park_background_overhaul.png`, shared park backdrop on menu/roster/settings/end-match | Done for current pass |
| Court/net polish without breaking geometry | `CourtComponent`, `NetComponent`, `court_projection_test.dart`, `court_layout_system_test.dart`, `court_component_test.dart`, generated court-surface texture overlay | Done for current pass |
| Perspective should match concept art better and not feel top-down | `docs/art/visual-overhaul/perspective-fix-spec.md` documents the safe approach; `perspective-metrics.md` records the baseline and first linear tuning pass; before/after emulator screenshots are archived | Partial: improved with a guarded linear pass, but still needs human visual review |
| Player/opponent have distinct animation states | `PlayerComponent` and `OpponentComponent` route ready/run/swing/hit-confirm/point-win/point-loss and now load generated dink/drive/lob/smash sheets; `player_component_test.dart` verifies shot-specific pose selection and asset presence | Done for current pass |
| Dink/drive/lob/smash have distinct animation/VFX indicators | `VfxLayerComponent` maps shot types to generated `dinkSpark`, `driveArc`, `lobArc`, `smashBand`, and `missWhiff`; character components load generated shot-specific animation sheets; `vfx_layer_component_test.dart` and `player_component_test.dart` verify sprite/pose selection | Done for current pass |
| Hitbox indicators match active swing zones | `RacketComponent` draws committed swing lane from `ShotSystem.committedSwingPath`; miss VFX spawns on expired swing command | Partial |
| Remove assisted controls and obsolete swing-power affordances | `settings_screen_test.dart` verifies assisted toggle removal; `docs/art/phase-5.2-comparison.md` now states only serve charge has percentage/ring feedback | Done |
| Android gameplay canvas is full-bleed | `GameScreen` renders `GameWidget` outside of view-padding while keeping the pause button inset-aware; evidence is archived at `docs/art/visual-overhaul/evidence/full-bleed-game-screen-pass/serve.png` | Done for current pass |
| Menu and result screens share gameplay visual identity | `ParkBackdrop`, updated menu/roster/settings/end-match screens, refreshed `phase-5g-*.png` goldens | Done |
| Asset manifests document generated sources and ownership | VFX, character, and court generated prompt/source docs exist; runtime asset README files link back to source contact sheets | Done for current pass |
| Emulator and physical Pixel screenshots are captured and archived | Pixel menu screenshot exists at `docs/art/visual-overhaul/evidence/pixel-latest-menu.png`; generated character pass Pixel screenshots exist; final evidence files now exist for menu, serve, rally/countdown, feedback, pause, and end-match | Done for current pass; end-match uses UI golden rather than ADB gameplay capture |
| Physical Android gameplay readability and performance checked | Current generated character build installed and launched on Pixel 10 Pro XL; no complete five-minute gameplay smoke is archived. Per user direction, physical Pixel evidence is no longer a blocker for continuing implementation unless the device is currently available. | Missing for final closeout only |
| Closeout has residual gap backlog | `docs/art/visual-overhaul/perspective-fix-spec.md` covers perspective; this audit lists remaining gaps | Partial |

## Current Evidence

Latest pushed commits:

- `1e44bd1` `simplify character sprite style`
- `9d7736a` `add generated court texture overlay`
- `27df0e5` `tune court perspective safely`
- `d208cc4` `archive perspective baselines`
- `2f0fb53` `simplify generated character sprites`
- `aa8e8eb` `add generated character shot sheets`
- `dca60ec` `differentiate shot swing poses`

Verification performed during this thread:

- `flutter analyze` passed after VFX integration.
- `flutter test` passed after VFX integration.
- `flutter build apk --debug` passed after VFX integration.
- `flutter install -d 58011FDCQ00992 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk` passed for the generated VFX build before the Pixel disconnected.
- `flutter test test/court_projection_test.dart test/court_layout_system_test.dart test/environment_layout_test.dart` passed after reverting the failed perspective experiment.
- `flutter test`, `flutter analyze`, and `flutter build apk --debug` passed after
  adding generated shot-specific character sheets.
- `flutter install -d 58011FDCQ00992 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk` passed for the generated character build.
- Pixel launch smoke succeeded with `adb shell monkey`; screenshot archived at
  `docs/art/visual-overhaul/evidence/pixel-character-pass-menu.png`.
- Character runtime sheets were simplified after review to a mid-detail style
  documented at
  `docs/art/visual-overhaul/contact-sheets/character-sprite-mid-detail-runtime-sheet.png`.
- Character runtime sheets were regenerated again into a simpler mid-detail
  style with chunkier silhouettes and fewer small clothing/facial details,
  documented at
  `docs/art/visual-overhaul/contact-sheets/character-sprite-simple-mid-runtime-sheet.png`.
- The simple-mid character build was installed on `emulator-5554` and captured
  at
  `docs/art/visual-overhaul/evidence/emulator-character-simple-mid-gameplay.png`.
- After the simple-mid character revision, `flutter test`, `flutter analyze`,
  and `flutter build apk --debug` passed. The debug APK was installed to
  `emulator-5554`; `flutter devices` did not list the physical Pixel at that
  time.
- `tools/capture_android_evidence.ps1` was added and smoke-tested on
  `emulator-5554`; it captures menu, serve, and pause evidence through ADB
  without hand-entered tap/screenshot commands.
- The Android gameplay screen was changed to render full-bleed behind hidden
  system UI instead of exposing a black top band; evidence is archived at
  `docs/art/visual-overhaul/evidence/full-bleed-game-screen-pass/serve.png`.
- Perspective baseline screenshots and projection metrics were archived before
  the next camera tuning pass:
  `docs/art/visual-overhaul/evidence/perspective-before-menu.png`,
  `docs/art/visual-overhaul/evidence/perspective-before-serve.png`, and
  `docs/art/visual-overhaul/perspective-metrics.md`.
- First linear perspective tuning pass completed with after screenshots:
  `docs/art/visual-overhaul/evidence/perspective-after-menu.png` and
  `docs/art/visual-overhaul/evidence/perspective-after-serve.png`.
- Generated court surface texture added as a low-opacity runtime overlay with
  source prompt/contact sheet documented at
  `docs/art/visual-overhaul/prompts/court-surface-texture-generated.md` and
  `docs/art/visual-overhaul/contact-sheets/court-surface-texture-generated.png`.
- Required final screenshot filenames were populated:
  `docs/art/phase-5.2-final-menu.png`,
  `docs/art/phase-5.2-final-serve.png`,
  `docs/art/phase-5.2-final-rally.png`,
  `docs/art/phase-5.2-final-feedback.png`,
  `docs/art/phase-5.2-final-pause.png`, and
  `docs/art/phase-5.2-final-endmatch.png`.

Subagent validation:

- Visual QA Agent audited current visual gaps and identified missing physical
  Pixel QA, placeholder asset manifests, shot-specific VFX gaps, and weak
  gameplay visual automation.
- Closeout Agent audit was requested for a final read-only checklist.

## Remaining Gaps

1. Perspective still needs human visual review.
   The first safe linear pass is implemented and evidenced. Avoid further
   aggressive projection changes unless environment props and controls are
   updated in the same branch.

2. Pixel gameplay evidence is incomplete.
   The current build installed and launched on Pixel, but do not mark visual
   closeout complete until fresh serve/rally/feedback screenshots and a short
   smoke run are archived.

3. End-match screenshot is not a device gameplay capture.
   The exact final filename exists, but it is copied from the refreshed UI
   golden because there is no deterministic ADB path to reach match end.

4. Gameplay visual automation is weak.
   UI goldens cover menus/screens, but Flame gameplay screenshots are still
   device-captured. A repeatable ADB capture helper now covers menu, serve, and
   pause, but rally/feedback/end-match gameplay states are not yet deterministic
   in local tests. A direct offscreen Flame render harness was attempted after
   the simple-mid character pass, but it hung before producing valid image
   evidence and was not checked in.

## Next Safe Work

1. Add a deterministic Flame gameplay screenshot harness so final rally,
   feedback, pause, and end-match states do not depend on ADB/manual timing.
2. Capture Pixel gameplay again only when the physical Pixel is already
   connected.
3. Use human visual review to decide whether the first linear perspective pass
   should be tuned further.
