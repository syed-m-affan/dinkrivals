# Visual Overhaul Completion Audit

Date: 2026-05-11

Objective audited: implement the visual overhaul plan as fully as possible
without human intervention, using generated bitmap assets where practical and
subagent validation for human-review-style checks.

## Verdict

Not complete.

The implementation has materially advanced environment density, screen cohesion,
shot VFX, HUD feedback, menu styling, and Android build/install coverage. It
does not yet satisfy the visual-overhaul definition of done because physical
Pixel gameplay screenshot coverage is incomplete, the perspective fix needs a
separate safe pass, and character sprites remain below the concept-art quality
bar at gameplay scale.

## Requirement Checklist

| Requirement | Evidence | Status |
| --- | --- | --- |
| Use generated bitmap art for new core visuals | `assets/images/environment/classic/park_background_overhaul.png`, `assets/images/vfx/*_generated.png`, `docs/art/visual-overhaul/contact-sheets/shot-vfx-generated-sheet.png`, `docs/art/visual-overhaul/prompts/shot-vfx-generated-sheet.md` | Partial: environment and VFX comply; court surface and character sprite provenance are still weak |
| Preserve gameplay logic and controls while improving visuals | Guard tests passed after reverting the failed projection experiment: `flutter test test/court_projection_test.dart test/court_layout_system_test.dart test/environment_layout_test.dart`; full suite passed before the latest doc-only commits | Partial |
| Environment reads denser and layered | `ClassicEnvironmentComponent`, `EnvironmentLayout.classicProps`, `park_background_overhaul.png`, shared park backdrop on menu/roster/settings/end-match | Done for current pass |
| Court/net polish without breaking geometry | `CourtComponent`, `NetComponent`, `court_projection_test.dart`, `court_layout_system_test.dart` | Partial: readable, but court texture remains procedural rather than a generated overlay package |
| Perspective should match concept art better and not feel top-down | `docs/art/visual-overhaul/perspective-fix-spec.md` documents the next safe approach; aggressive non-linear experiment was rejected because it clashed with art and gameplay | Missing |
| Player/opponent have distinct animation states | `PlayerComponent` and `OpponentComponent` route ready/run/swing/hit-confirm/point-win/point-loss; shot swings now apply distinct pose-specific lean/scale silhouettes; `player_component_test.dart` verifies different shot leans | Partial: states and shot silhouettes exist, but shot moves still share source sprite sheets rather than distinct generated dink/drive/lob/smash sheets |
| Dink/drive/lob/smash have distinct animation/VFX indicators | `VfxLayerComponent` maps shot types to generated `dinkSpark`, `driveArc`, `lobArc`, `smashBand`, and `missWhiff`; `vfx_layer_component_test.dart` verifies sprite selection | Partial |
| Hitbox indicators match active swing zones | `RacketComponent` draws committed swing lane from `ShotSystem.committedSwingPath`; miss VFX spawns on expired swing command | Partial |
| Remove assisted controls and obsolete swing-power affordances | `settings_screen_test.dart` verifies assisted toggle removal; `docs/art/phase-5.2-comparison.md` now states only serve charge has percentage/ring feedback | Done |
| Menu and result screens share gameplay visual identity | `ParkBackdrop`, updated menu/roster/settings/end-match screens, refreshed `phase-5g-*.png` goldens | Done |
| Asset manifests document generated sources and ownership | VFX manifest updated; generated VFX prompt/source documented; environment manifest exists | Partial |
| Emulator and physical Pixel screenshots are captured and archived | Pixel menu screenshot exists at `docs/art/visual-overhaul/evidence/pixel-latest-menu.png`; existing emulator smoke files are `docs/art/phase-5.2-emulator-smoke.png` and `docs/art/phase-5.2-gameplay-emulator-smoke.png`; current Pixel is not connected; latest emulator screenshot attempt is invalid because Android system ANR dialog covered the app | Missing: required final files `phase-5.2-final-serve.png`, `phase-5.2-final-rally.png`, `phase-5.2-final-feedback.png`, `phase-5.2-final-pause.png`, `phase-5.2-final-endmatch.png`, and `phase-5.2-final-menu.png` are absent |
| Physical Android gameplay readability and performance checked | Prior install passed on Pixel for commit `ba2222b`, but current physical Pixel is disconnected and no complete five-minute gameplay smoke is archived | Missing |
| Closeout has residual gap backlog | `docs/art/visual-overhaul/perspective-fix-spec.md` covers perspective; this audit lists remaining gaps | Partial |

## Current Evidence

Latest pushed commits:

- `a339983` `implement visual overhaul pass`
- `5dbfe5b` `unify screens with park backdrop`
- `ba2222b` `add generated shot vfx assets`
- `0e566f7` `document perspective fix plan`
- `a6bad40` `clarify control visual closeout`

Verification performed during this thread:

- `flutter analyze` passed after VFX integration.
- `flutter test` passed after VFX integration.
- `flutter build apk --debug` passed after VFX integration.
- `flutter install -d 58011FDCQ00992 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk` passed for the generated VFX build before the Pixel disconnected.
- `flutter test test/court_projection_test.dart test/court_layout_system_test.dart test/environment_layout_test.dart` passed after reverting the failed perspective experiment.
- `flutter test test/player_component_test.dart` passed after adding shot-specific character pose silhouettes.

Subagent validation:

- Visual QA Agent audited current visual gaps and identified missing physical
  Pixel QA, placeholder asset manifests, shot-specific VFX gaps, and weak
  gameplay visual automation.
- Closeout Agent audit was requested for a final read-only checklist.

## Remaining Gaps

1. Perspective still needs a safe visual-only pass.
   The next pass should follow `perspective-fix-spec.md`, capture baseline
   evidence first, and avoid aggressive non-linear projection changes unless
   environment props and controls are updated in the same branch.

2. Pixel gameplay evidence is incomplete.
   The Pixel disconnected after the latest installs. Do not mark visual closeout
   complete until fresh physical-device serve/rally/feedback screenshots and a
   short smoke run are archived.

3. Character sprites remain below the concept target.
   They have more states than before, but the gameplay-scale athletes still do
   not match the charm, readability, and identity requested by the concept art.
   The audit also found no complete generated-image provenance package for
   character gameplay sheets comparable to the new VFX prompt/contact sheet.
   The latest runtime pass improves shot readability with distinct silhouettes,
   but it is not a replacement for generated character sheets.

4. Gameplay visual automation is weak.
   UI goldens cover menus/screens, but Flame gameplay screenshots are still
   primarily device-captured and not robustly automated.

5. Emulator QA is currently unreliable.
   The latest emulator screenshot attempt showed a system ANR dialog rather than
   the app, so those captures were discarded.

6. Required final screenshot filenames are missing.
   `phase-5.2-delta-inventory.md` names final serve, rally, feedback, pause,
   end-match, and menu screenshots, but those exact artifacts are not present.

## Next Safe Work

1. Reconnect Pixel and reinstall current `master`.
2. Capture clean physical baseline screenshots named in
   `perspective-fix-spec.md`.
3. Make a small linear projection adjustment only after baseline capture.
4. Re-run environment overlap tests and install on Pixel.
5. Capture after screenshots and decide with human review whether the camera
   change is acceptable.
