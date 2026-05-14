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

## Verification

- `flutter analyze`: pass
- Focused projection/backdrop/control tests: pass (`16` tests)
- `flutter test --update-goldens test\phase5g_visual_golden_test.dart`: pass;
  refreshed the Phase 5G menu/settings/end-match golden evidence against the
  projection environment.
- `flutter test`: pass (`202` tests)
- `flutter build apk --debug`: pass
- `flutter install -d emulator-5554 --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk`: pass

## Notes

The court/environment bitmap is 979x1606 and is rendered with the same cover-fit
transform as `CourtLayoutSystem`. Gameplay lines remain procedural so boundary,
kitchen, service-line, and net-plane reads are tied to `CourtProjection`.

`ParkBackdrop` now uses the same projection environment asset, so menu,
settings, roster, and end-match widget surfaces no longer reference the retired
`park_background_overhaul.png` art.

The refreshed game capture also verifies the bottom shot chips fit inside the
portrait canvas after the `LOB/SMASH` clipping fix.

The drive/lob/smash images are debug-rally gesture and animation captures. They
are useful visual evidence for the new environment during shot inputs, but they
do not replace final shot-acceptance signoff.

`end-match-widget.png` is widget-rendered evidence from the refreshed Phase 5G
golden, not an emulator capture reached by completing a full match. Physical
device capture and human visual signoff remain final closeout gates.
