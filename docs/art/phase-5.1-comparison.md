# Phase 5.1 Comparison

Last updated: 2026-05-11

## Inputs

- Concept target: `docs/art/concept-screenshot.png`
- Baseline: `docs/art/phase-5.1-screenshot.png`
- Final Android serve screenshot: `docs/art/phase-5.1-final-serve.png`
- Final Android rally screenshot: `docs/art/phase-5.1-final-rally.png`
- Final Android pause screenshot: `docs/art/phase-5.1-final-pause.png`
- Build artifact for manual validation: `dink_rivals-debug.apk`

## Implemented Corrections

1. **Black player artifacts**
   - Removed high-priority racket-head shadow rendering from `RacketComponent`.
   - Refreshed paddle sprites from pure black heads to dark rimmed navy heads.

2. **Player model consistency**
   - Rebuilt player/opponent sprite sheets as chunkier transparent pixel sprites.
   - Idle, ready, hit-confirm, point-win, and point-loss sheets now share the same body/cap/feet baseline.
   - Player and opponent sprite render sizes were increased for better phone readability.

3. **Environment de-stretching**
   - Added aspect-preserving prop geometry.
   - Retuned fence placements away from horizontally stretched dimensions.
   - Added procedural back fence mesh/posts so the court has a continuous fence read without stretching one raster asset.

4. **Court grounding**
   - Added layered ground gradient, wider apron feather, court contact shadow, and court edge shade.
   - Reduced the floating-slab read by putting apron/ground transition and shadow under the court footprint.

5. **Park richness**
   - Added a procedural layered tree line, hedge band, richer backdrop fence, more tree/bag placements, and retained side foliage/bench/lamp props.

6. **HUD/control proportions**
   - Preserved movement/swing/serve hit regions.
   - Reduced visual control radii and knob sizes so bottom controls are less dominant.
   - Tightened score panel sizing while preserving readability.

## Verification

- `flutter analyze`: pass
- `flutter test`: pass, 133 tests
- `flutter build apk --debug`: pass
- Sprite alpha QA: pass, no magenta pixels and no opaque border pixels in gameplay sprite sheets
- `flutter install --debug -d 58011FDCQ00992 --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk`: pass
- Android launch: pass, `am start` returned `Status: ok`
- Android screenshots: pass for serve, rally, and pause states
- Android uptime smoke: partial only. A long-running smoke was interrupted at about 3 minutes, then the Pixel disconnected from Flutter/ADB before a clean 5-minute run could restart.
- `flutter build web --debug`: blocked because the project is not configured for web
- `flutter build windows --debug`: blocked because the project is not configured for Windows desktop

## Closeout Decision

P51I remains in review. The implementation and Android screenshot evidence are complete enough for visual review, but the full 5-minute Android performance/readability smoke is still unverified because the device disconnected.

Captured:

- waiting-to-serve state
- rally state
- pause state

Remaining:

- 5-minute performance/readability smoke on a connected Android device

The latest APK is copied to `dink_rivals-debug.apk` at the workspace root and is ignored by git.
