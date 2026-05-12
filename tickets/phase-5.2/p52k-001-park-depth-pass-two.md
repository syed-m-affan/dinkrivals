---
id: P52K-001
phase: 5.2J
status: done
priority: medium
parallel_group: D
depends_on: [P52E-001]
blocks: [P52M-001]
owner: codex
last_updated: 2026-05-11
---

# P52K-001 - Park Depth Pass Two

## Goal

Add a second layer of concept-like park depth behind and beside the court without reducing gameplay clarity.

## Build Spec Coverage

Phase 5.2J - Park Depth Pass Two:

- Lamp post.
- Planter or bench cluster.
- Darker rear tree band.
- Lower contrast than gameplay-critical elements.

## Suggested File Ownership

- `dink_rivals/lib/game/components/classic_environment_component.dart`
- `dink_rivals/lib/game/config/environment_layout.dart`
- `dink_rivals/assets/images/environment/classic/`
- `dink_rivals/test/environment_layout_test.dart`
- `docs/art/phase-5.2/phase-5.2-park-depth-contact-sheet.png`
- `docs/art/phase-5.2/phase-5.2-park-depth.png`
- `tickets/status.md`

Coordinate with P52E because both touch environment layout and assets.

## Requirements

- Add a lamp post on at least one sideline or rear corner.
- Add a planter or bench cluster that echoes the concept screenshot.
- Add or tune a darker rear tree band behind the fence/signage.
- Keep all props lower contrast than players, ball, court lines, net, scoreboard, pause, feedback, and controls.
- Preserve prop aspect ratios and data-driven placement.
- Include contact-sheet or screenshot proof.

## Non-Goals

- No animated crowd.
- No weather, day/night, seasonal variants, new courts, or dynamic billboard systems.
- No gameplay occluders.
- No third-party or copied art.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Park reads richer and closer to concept without visual clutter.
- New props do not hide gameplay-critical objects.
- Existing environment layout tests pass.
- P5H-006 is absorbed or explicitly superseded in status notes.

## Planning Notes

- This ticket absorbs P5H-006 and should run serially with P52E because both own environment layout.

## Implementation Notes

- Implemented: added lamp/planter/sign/tree-band park depth pass two through the environment layout and asset tests.
- Verification: `flutter analyze`, `flutter test`, `flutter build apk --debug`, emulator install/launch on `emulator-5554`, and `docs/art/phase-5.2/phase-5.2-gameplay-emulator-smoke.png`.
