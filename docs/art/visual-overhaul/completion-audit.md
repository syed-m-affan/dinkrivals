# Visual Overhaul Completion Audit

Date: 2026-05-11

Objective audited: implement the visual overhaul plan as fully as possible
without human intervention, using generated bitmap assets where practical and
subagent validation for human-review-style checks.

## Verdict

Not complete.

The implementation has materially advanced environment density, screen cohesion,
shot VFX, HUD feedback, menu styling, generated character sheets, and Android
build/install coverage. It does not yet satisfy the visual-overhaul definition
of done because the perspective fix needs a separate safe pass and complete
final gameplay screenshot coverage is still missing.

## Requirement Checklist

| Requirement | Evidence | Status |
| --- | --- | --- |
| Use generated bitmap art for new core visuals | `assets/images/environment/classic/park_background_overhaul.png`, `assets/images/vfx/*_generated.png`, `assets/images/sprites/player_*.png`, `assets/images/sprites/opponent_*.png`, `docs/art/visual-overhaul/contact-sheets/shot-vfx-generated-sheet.png`, `docs/art/visual-overhaul/contact-sheets/character-sprite-generated-atlas.png`, `docs/art/visual-overhaul/contact-sheets/character-sprite-mid-detail-runtime-sheet.png`, `docs/art/visual-overhaul/prompts/shot-vfx-generated-sheet.md`, `docs/art/visual-overhaul/prompts/character-sprite-generated-atlas.md` | Partial: environment, VFX, and character sheets comply; court surface remains procedural rather than a generated overlay package |
| Preserve gameplay logic and controls while improving visuals | Guard tests passed after reverting the failed projection experiment: `flutter test test/court_projection_test.dart test/court_layout_system_test.dart test/environment_layout_test.dart`; full suite passed after the generated character integration | Partial |
| Environment reads denser and layered | `ClassicEnvironmentComponent`, `EnvironmentLayout.classicProps`, `park_background_overhaul.png`, shared park backdrop on menu/roster/settings/end-match | Done for current pass |
| Court/net polish without breaking geometry | `CourtComponent`, `NetComponent`, `court_projection_test.dart`, `court_layout_system_test.dart` | Partial: readable, but court texture remains procedural rather than a generated overlay package |
| Perspective should match concept art better and not feel top-down | `docs/art/visual-overhaul/perspective-fix-spec.md` documents the next safe approach; aggressive non-linear experiment was rejected because it clashed with art and gameplay | Missing |
| Player/opponent have distinct animation states | `PlayerComponent` and `OpponentComponent` route ready/run/swing/hit-confirm/point-win/point-loss and now load generated dink/drive/lob/smash sheets; `player_component_test.dart` verifies shot-specific pose selection and asset presence | Done for current pass |
| Dink/drive/lob/smash have distinct animation/VFX indicators | `VfxLayerComponent` maps shot types to generated `dinkSpark`, `driveArc`, `lobArc`, `smashBand`, and `missWhiff`; character components load generated shot-specific animation sheets; `vfx_layer_component_test.dart` and `player_component_test.dart` verify sprite/pose selection | Done for current pass |
| Hitbox indicators match active swing zones | `RacketComponent` draws committed swing lane from `ShotSystem.committedSwingPath`; miss VFX spawns on expired swing command | Partial |
| Remove assisted controls and obsolete swing-power affordances | `settings_screen_test.dart` verifies assisted toggle removal; `docs/art/phase-5.2-comparison.md` now states only serve charge has percentage/ring feedback | Done |
| Menu and result screens share gameplay visual identity | `ParkBackdrop`, updated menu/roster/settings/end-match screens, refreshed `phase-5g-*.png` goldens | Done |
| Asset manifests document generated sources and ownership | VFX manifest updated; generated VFX prompt/source documented; environment manifest exists | Partial |
| Emulator and physical Pixel screenshots are captured and archived | Pixel menu screenshot exists at `docs/art/visual-overhaul/evidence/pixel-latest-menu.png`; generated character pass Pixel screenshot exists at `docs/art/visual-overhaul/evidence/pixel-character-pass-menu.png`; existing emulator smoke files are `docs/art/phase-5.2-emulator-smoke.png` and `docs/art/phase-5.2-gameplay-emulator-smoke.png` | Missing: required final files `phase-5.2-final-serve.png`, `phase-5.2-final-rally.png`, `phase-5.2-final-feedback.png`, `phase-5.2-final-pause.png`, `phase-5.2-final-endmatch.png`, and `phase-5.2-final-menu.png` are absent |
| Physical Android gameplay readability and performance checked | Current generated character build installed and launched on Pixel 10 Pro XL; no complete five-minute gameplay smoke is archived. Per user direction, physical Pixel evidence is no longer a blocker for continuing implementation unless the device is currently available. | Missing for final closeout only |
| Closeout has residual gap backlog | `docs/art/visual-overhaul/perspective-fix-spec.md` covers perspective; this audit lists remaining gaps | Partial |

## Current Evidence

Latest pushed commits:

- `a339983` `implement visual overhaul pass`
- `5dbfe5b` `unify screens with park backdrop`
- `ba2222b` `add generated shot vfx assets`
- `0e566f7` `document perspective fix plan`
- `a6bad40` `clarify control visual closeout`
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
   The current build installed and launched on Pixel, but do not mark visual
   closeout complete until fresh serve/rally/feedback screenshots and a short
   smoke run are archived.

3. Court surface is still not generated art.
   The environment, VFX, and gameplay character sheets now have generated
   provenance, but the court itself remains a procedural/runtime composition.

4. Gameplay visual automation is weak.
   UI goldens cover menus/screens, but Flame gameplay screenshots are still
   primarily device-captured and not robustly automated.

5. Emulator QA needs a fresh pass after reboot.
   The prior emulator screenshot attempt showed a system ANR dialog rather than
   the app, so those captures were discarded. The emulator can be used for
   continued work when available.

6. Required final screenshot filenames are missing.
   `phase-5.2-delta-inventory.md` names final serve, rally, feedback, pause,
   end-match, and menu screenshots, but those exact artifacts are not present.

## Next Safe Work

1. Capture clean emulator baselines named in `perspective-fix-spec.md`; capture
   Pixel baselines only when the physical Pixel is already connected.
2. Make a small linear projection adjustment only after baseline capture.
3. Re-run environment overlap tests and install on Pixel only if available.
4. Capture after screenshots and decide with human review whether the camera
   change is acceptable.
