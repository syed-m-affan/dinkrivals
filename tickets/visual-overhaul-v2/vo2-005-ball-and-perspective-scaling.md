---
id: VO2-005
phase: visual-overhaul-v2
status: done
priority: high
parallel_group: ball-vfx
depends_on: [VO2-001, VO2-003, VO2-004]
blocks: [VO2-008]
owner: Runtime Integration Agent + Visual QA Agent + Performance QA Agent
last_updated: 2026-05-11
---

# VO2-005 - Ball and Perspective Scaling

## Goal

Re-tune ball size, trail, VFX scale, shadow contrast, and depthScale so 3D ball motion reads coherently against the larger characters.

## Owned Files

- `dink_rivals/lib/game/components/ball_component.dart`
- `dink_rivals/lib/game/components/vfx/vfx_layer_component.dart`
- `dink_rivals/lib/game/util/court_projection.dart`
- `dink_rivals/lib/game/config/tuning_constants.dart`
- Evidence under `docs/art/visual-overhaul/evidence/vo2-ball-*.png`

## Tasks

- In `ball_component.dart:86-89`, re-tune the radius formula.
- Promote ball radius constants to `Tuning.ballRadiusBase` and `Tuning.ballRadiusAltitudeBoost`.
- Target ball readability around 14 px on a 1920-tall canvas at near-baseline.
- Keep the ball larger than the racket contact point but never large enough to obscure the paddle.
- Re-verify `court_projection.dart:71-75` `depthScale` range, currently 0.40 far to 1.15 near.
- Sweep near, mid, and far baseline positions.
- If the near player reads too large at 1.15, clamp near edge to about 1.05 or raise far edge to about 0.50.
- Record final depthScale values and rationale.
- In `vfx_layer_component.dart`, review trail, bounce ring, and contact burst sizes.
- If needed, bump emit sizes about 1.2x and centralize configurable values in `tuning_constants.dart`.
- Verify ball shadow contrast at arc apex and bump if needed.

## Acceptance Criteria

- Ball is readable at every altitude across a full rally on Pixel.
- Trail clearly conveys arc: lob reads tall and drive reads flat.
- Scale chain is coherent at the same y: ball < racket < player.
- Ball/VFX tuning constants are centralized; no new magic numbers in `ball_component.dart`.
- Final `depthScale` values are documented.
- `flutter analyze` clean and `flutter test` green.

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

Capture serve, rally, dink, drive, lob, and smash evidence under `docs/art/visual-overhaul/evidence/vo2-ball-*`.

## Risks

- Bigger characters can hide ball contact. Tune ball and VFX with real gameplay screenshots, not isolated frames.
- Perspective retuning can affect visual feel without changing physics; do not change deterministic court math or rally outcomes.
