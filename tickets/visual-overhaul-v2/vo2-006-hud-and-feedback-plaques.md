---
id: VO2-006
phase: visual-overhaul-v2
status: done
priority: high
parallel_group: hud
depends_on: [VO2-001]
blocks: [VO2-007, VO2-008]
owner: Runtime Integration Agent
last_updated: 2026-05-11
---

# VO2-006 - HUD and Feedback Plaques

## Goal

Replace flat procedural HUD surfaces with compact concept-matched arcade plaques while preserving safe areas and input ergonomics.

## Owned Files

- `dink_rivals/lib/game/components/score_component.dart`
- `dink_rivals/lib/game/components/rally_feedback_component.dart`
- `dink_rivals/lib/game/components/rally_strip_component.dart`
- `dink_rivals/lib/game/components/touch_controls_component.dart`
- `dink_rivals/lib/game/config/visual_palette.dart`
- `dink_rivals/lib/game/config/debug_flags.dart`
- Evidence under `docs/art/visual-overhaul/evidence/vo2-hud-*.png`

## Prompt Packet

- `docs/art/visual-overhaul/prompts/vo2-hud.md`
- Inherits from `docs/art/visual-overhaul/prompts/vo2-shared-style-rules.md`.

## Tasks

- Restyle `score_component.dart` into a top-left two-panel block.
- Score text format: `YOU 05` with yellow accent and `RIVAL 03` with red accent.
- Use a 2-px gap and remove the central divider chip.
- Move rally/last-shot readout out of the score component.
- Add `rally_strip_component.dart`, a left-anchored two-line strip reading `RALLY: 6` and `LAST SHOT: DINK`.
- Rally strip uses monospace text, drop shadow, and no border.
- Rally strip reads `game.matchState.rallyCount` and `game.lastShotType`.
- Rebuild `rally_feedback_component.dart` into a two-line bordered plaque such as `DINK!` / `NICE SHOT`.
- Feedback plaque timing: pop-on 0.15s, hold 0.6s, fade 0.25s.
- Keep existing feedback triggers unchanged.
- Tighten the move stick and swing knob in `touch_controls_component.dart`.
- Remove the `AIM` label text.
- Reposition `SERVE` button to bottom-center, small and visible only during own serve.
- Keep all control hit targets at least 48 dp.
- Gate the debug overlay behind `DebugFlags.showHud`; it is off by default in gameplay builds.

## Acceptance Criteria

- Top-left score block matches concept proportions on Pixel.
- Feedback plaque triggers on every shot type with correct two-line text.
- Rally strip updates live during rallies.
- Controls pass the 48 dp thumb-target audit.
- Controls do not overlap important court surface paint.
- No text overlap or safe-area violations on Pixel.
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

Capture serve, rally, dink feedback, drive feedback, lob feedback, smash feedback, fault, point, and pause evidence under `docs/art/visual-overhaul/evidence/vo2-hud-*`.

## Risks

- Compact HUD can regress readability. Test on Pixel screenshots, not only desktop previews.
- Control visual compaction must not shrink actual touch regions below 48 dp.
