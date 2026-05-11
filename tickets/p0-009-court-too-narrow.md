---
id: P0-009
phase: 0
status: in_progress
priority: high
parallel_group: perspective
depends_on: []
blocks: [P0-008]
owner: claude
last_updated: 2026-05-11
---

# P0-009 - Court Too Narrow After P0-006

## Problem

After P0-006 the court fills vertically but is now far too narrow — it occupies ~55-65% of the screen width on a Pixel 10 Pro XL portrait viewport. Reference: `docs/art/p0-006-p0-007-perspective-screenshot.png`. Concept fills ~95%.

## Root Cause

`DinkRivalsGame.onGameResize` reserves `_minBottomControlReserve = 340` logical pixels for the bottom controls (capped at 28% of screen height). On a typical phone that consumes ~250 logical px, plus 72px top reserve, leaving 60-65% of the screen height for the court. With `yCompression = 1.08`, the projected court aspect is 237.6/518.4 ≈ 0.46. The available area aspect on a typical phone is ~0.62, so the scale clamps by height and the court ends up much narrower than the screen.

The bottom controls actually only occupy ~130 logical px (movement joystick + SERVE + swing stick centered around `size.y - 96..-132` with radius 58). The 340 reserve is overcautious.

## Fix

- Drop `_minBottomControlReserve`: 340 → 180 and cap: 28% → 18%.
- Lower `CourtProjection.yCompression`: 1.08 → ~0.88 so the projected court is closer to square aspect 0.58, leaving room for width when scaling to fit the taller available area.
- Update the court-projection aspect test threshold to the new value.

## Verification

- `flutter analyze`, `flutter test`.
- On device: court occupies ≥ 88% of the screen width on Pixel 10 Pro XL.

## Acceptance Criteria

- Court width visibly fills the screen, similar to concept.
- Bottom controls still clear the player baseline.
- Existing tests pass; aspect test updated.
