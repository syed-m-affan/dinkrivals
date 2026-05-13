---
id: VO2-001
phase: visual-overhaul-v2
status: review
priority: critical
parallel_group: environment
depends_on: [VO2-000]
blocks: [VO2-005, VO2-006, VO2-007, VO2-008]
owner: Asset Generation Agent + Runtime Integration Agent
last_updated: 2026-05-12
---

# VO2-001 - Environment Layer Split

## Goal

Replace monolithic `park_background_overhaul.png` with separately authored, layer-aligned generated assets without breaking court projection or style cohesion.

## Owned Files

- `dink_rivals/assets/images/environment/classic/layer_sky_trees.png`
- `dink_rivals/assets/images/environment/classic/layer_fence_signage.png`
- `dink_rivals/assets/images/environment/classic/layer_court_base.png`
- `dink_rivals/assets/images/environment/classic/layer_net.png`
- `dink_rivals/lib/game/config/environment_layout.dart`
- `dink_rivals/lib/game/components/classic_environment_component.dart`
- `dink_rivals/lib/game/components/net_component.dart`
- Evidence under `docs/art/visual-overhaul/evidence/vo2-env-split-*.png`

## Prompt Packet

- `docs/art/visual-overhaul/prompts/vo2-environment-layers.md`
- `docs/art/visual-overhaul/prompts/vo2-signage.md`
- Both inherit from `docs/art/visual-overhaul/prompts/vo2-shared-style-rules.md`.

## Tasks

- Generate four 941x1672 PNG layers: `layer_sky_trees.png`, `layer_fence_signage.png`, `layer_court_base.png`, `layer_net.png`.
- Include visible, legible "DINK RIVALS" banner and "PICKLEBALL LEGENDS" sign in the fence/signage layer.
- Update `EnvironmentLayout.generatedBackgroundAsset` from a single path to a typed list of `EnvironmentBackgroundLayer`.
- Rewrite `ClassicEnvironmentComponent` layer drawing order to sky_trees, fence_signage, court_base, cast shadows, existing props.
- Update `NetComponent` to draw `layer_net.png` directly instead of cropping the monolithic background.
- Preserve `court_layout_system.dart:15-32` perspective trapezoid control points.
- Overlay or otherwise verify gameplay logical bounds against `layer_court_base.png`.

## Acceptance Criteria

- Court projection unchanged: ball serve start, player baseline, opponent baseline, and net line land on the painted court within 2 px on emulator.
- Backdrop reads as an arcade pickleball venue with both required signs visible and legible.
- All four layer assets pass the `vo2-shared-style-rules.md` gate.
- Existing props from `EnvironmentLayout.classicProps` still layer correctly.
- Evidence exists: `vo2-env-split-rally.png`, `vo2-env-split-serve.png`.

## Closeout Status - 2026-05-12

Runtime layer splitting was implemented and automated checks passed, but art QA did not accept this ticket as complete. Signage replacement and net/court visibility still need focused follow-up before the environment work can be marked `done`.

Residual tickets:

- `VO3-005` replaces failed/placeholder signage with legible concept-matched signs.
- `VO3-006` corrects net readability, ball/player visibility at the net, and layer alignment.

## Verification

Run from `dink_rivals/`:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
flutter run -d emulator-5554
```

Screenshot helper:

```powershell
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell screencap -p /sdcard/vo2.png
& $adb -s emulator-5554 pull /sdcard/vo2.png ..\dink_rivals\docs\art\visual-overhaul\evidence\vo2-env-split-rally.png
```

## Risks

- Layer split can drift from court projection. Keep canvas size and control points fixed.
- Signage can style-break or become fake-logo-like. Reject candidates that violate the shared style rules or originality constraints.
