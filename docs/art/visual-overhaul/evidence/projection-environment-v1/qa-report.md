# Projection Environment V1 QA Report

Date: 2026-05-14

## Scope

This pass replaces the flat gray runtime background with a generated
projection-locked court/environment asset:

- Runtime asset:
  `dink_rivals/assets/images/environment/classic/projection_environment_v1.png`
- Generator:
  `dink_rivals/tool/generate_projection_environment.py`
- Manifest:
  `docs/art/visual-overhaul/projection-environment-v1-manifest.json`

The concept screenshot and concept sheet were used for visual direction: blue
court, green park apron, dark fence/signage band, side benches, planters, lamps,
and chunky arcade pixel styling that sits with the accepted player/opponent
sprites.

## Runtime Evidence

Captured on Android emulator `emulator-5554` after installing
`build/app/outputs/flutter-apk/app-debug.apk`.

- Menu: `docs/art/visual-overhaul/evidence/projection-environment-v1/menu.png`
- Settings:
  `docs/art/visual-overhaul/evidence/projection-environment-v1/settings.png`
- Roster: `docs/art/visual-overhaul/evidence/projection-environment-v1/roster.png`
- Game: `docs/art/visual-overhaul/evidence/projection-environment-v1/game.png`
- Serve: `docs/art/visual-overhaul/evidence/projection-environment-v1/serve.png`
- Debug rally:
  `docs/art/visual-overhaul/evidence/projection-environment-v1/debug-rally.png`
- Debug dink/passive contact:
  `docs/art/visual-overhaul/evidence/projection-environment-v1/dink.png`
- Debug drive gesture:
  `docs/art/visual-overhaul/evidence/projection-environment-v1/drive.png`
- Debug lob gesture:
  `docs/art/visual-overhaul/evidence/projection-environment-v1/lob.png`
- Debug smash gesture:
  `docs/art/visual-overhaul/evidence/projection-environment-v1/smash.png`
- Point aftermath:
  `docs/art/visual-overhaul/evidence/projection-environment-v1/point.png`
- Shot feedback:
  `docs/art/visual-overhaul/evidence/projection-environment-v1/point-feedback.png`
- Pause overlay:
  `docs/art/visual-overhaul/evidence/projection-environment-v1/pause.png`
- End-match widget:
  `docs/art/visual-overhaul/evidence/projection-environment-v1/end-match-widget.png`
- End-match live app capture:
  `docs/art/visual-overhaul/evidence/projection-environment-v1/end-match-live.png`

## Verification

- `flutter analyze`: pass
- Focused projection/backdrop/control tests: pass (`16` tests)
- Focused QA launch tests: pass (`4` tests)
- `flutter test --update-goldens test\phase5g_visual_golden_test.dart`: pass;
  refreshed the Phase 5G menu/settings/end-match golden evidence against the
  projection environment.
- `flutter test`: pass (`206` tests)
- `flutter build apk --debug`: pass
- `flutter install -d emulator-5554 --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk`: pass
- QA end-match evidence build:
  `flutter build apk --debug --dart-define=DINK_RIVALS_INITIAL_ROUTE=/end-match --dart-define=DINK_RIVALS_QA_END_MATCH=true --dart-define=DINK_RIVALS_QA_END_MATCH_WINNER=player`
  followed by emulator install, launch, and screenshot capture.
- QA debug-rally launch build for dink evidence:
  `flutter build apk --debug --dart-define=DINK_RIVALS_INITIAL_ROUTE=/debug-rally`
  followed by emulator install, launch, wait for passive contact, and screenshot
  capture.

## Notes

The court/environment bitmap is 979x1606 and is rendered with the same cover-fit
transform as `CourtLayoutSystem`. Gameplay lines remain procedural so boundary,
kitchen, service-line, and net-plane reads are tied to `CourtProjection`.

`ParkBackdrop` now uses the same projection environment asset, so menu,
settings, roster, and end-match widget surfaces no longer reference the retired
`park_background_overhaul.png` art.

The refreshed game capture also verifies the bottom shot chips fit inside the
portrait canvas after the `LOB/SMASH` clipping fix.

The dink/drive/lob/smash images are debug-rally gesture or passive-contact
captures. They are useful visual evidence for the new environment during shot
inputs, but they do not replace final human shot-acceptance signoff.

`end-match-widget.png` is widget-rendered evidence from the refreshed Phase 5G
golden. `end-match-live.png` is a running emulator capture using the QA launch
seed guarded by `DINK_RIVALS_INITIAL_ROUTE` and `DINK_RIVALS_QA_END_MATCH`; it
proves the live app renders the end-match surface over the projection
environment, but it is not an organic full-match playthrough. Physical-device
capture and human visual signoff remain final closeout gates.
