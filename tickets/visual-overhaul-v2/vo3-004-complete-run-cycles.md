---
id: VO3-004
phase: visual-overhaul-v3
status: review
priority: high
parallel_group: character-animation
depends_on: [VO3-003]
owner: Asset Normalization Agent + Runtime Integration Agent + Visual QA Agent
last_updated: 2026-05-12
---

# VO3-004 - Complete Character Run Cycles

## Goal

Complete and validate the player and opponent run cycles so movement reads as intentional athletic motion instead of sliding, snapping, or partial-frame animation.

## Scope

- Validate the player run sheet has the required complete run cycle.
- Validate the opponent run sheet has the required complete run cycle.
- Normalize feet, pivots, frame order, and frame timing.
- Preserve the 48x72 footprint and existing runtime filenames.
- Do not alter movement speed, input handling, AI, physics, or hitboxes.

## Acceptance Criteria

- Player run animation loops cleanly while moving left, right, forward, and backward.
- Opponent run animation loops cleanly during AI movement and recovery.
- No frame pops, foot teleporting, horizontal anchor drift, or paddle disappearance at gameplay scale.
- Still screenshots and a short run-cycle QA note are archived with the final evidence.
- Art QA signs off that both run cycles are complete.

## Verification

Run from `dink_rivals/` after implementation:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Perform a rally smoke that forces both characters to move across the court.

## Recovery Notes

- 2026-05-12: Player and opponent run sheets are now native 64x64 chibi 12-frame runtime strips (`768x64`) instead of the shorter/tall cycle.
- `PlayerComponent` and `OpponentComponent` now allow up to 12 frames per sheet, use 64px frame-count detection, use integer source rects to prevent neighbor-frame sampling, and slow run playback to an 8 FPS max so the cycle no longer flashes by too quickly.
- Swing/hit-confirm playback durations were retimed for the expanded action sheets.
- Run cells now stay inside frame margins; the sprite audit reports 0 errors and 0 warnings.
- `test/player_component_test.dart` verifies the player and opponent run sheets are detected as 12 frames.
- Cleanup/preview evidence is archived under `docs/art/visual-overhaul/sprite-overhaul-run/`.
- Emulator rally evidence shows the opponent using the run strip during movement:
  - `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/rally_ui_latest.png`
- Remaining review item: a still screenshot cannot prove loop quality by itself; a short moving capture or human playtest is still the stronger final signoff.
