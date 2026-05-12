---
id: P2-008
phase: 2
status: in_progress
priority: medium
parallel_group: A
depends_on: []
blocks: [P2-007]
owner: claude
last_updated: 2026-05-10
---

# P2-008 - Game Screen Runs Into Notch / Notification Bar

## Problem

On Pixel 10 Pro XL the top of the game canvas overlaps the notch and the notification shade region. UI elements (pause button) sit at `top: 16` but the underlying `GameWidget` still paints behind the notch.

## Fix

Wrap the `GameWidget<DinkRivalsGame>` inside the `GameScreen` `Stack` with a `SafeArea` so the game canvas itself respects the device's top/bottom insets. Keep pause button positioned within the safe area.

## Verification

- `flutter analyze`, `flutter test`.
- On device: opponent area no longer overlaps the notch; pause button remains tappable.

## Acceptance Criteria

- Gameplay canvas does not extend under the notch / status bar.
- Existing widget tests still pass.
