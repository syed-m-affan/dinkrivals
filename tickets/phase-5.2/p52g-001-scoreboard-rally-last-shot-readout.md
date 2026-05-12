---
id: P52G-001
phase: 5.2F
status: done
priority: high
parallel_group: F
depends_on: [P52A-002, P52D-001]
blocks: [P52H-001, P52M-001]
owner: codex
last_updated: 2026-05-11
---

# P52G-001 - Scoreboard, Rally Counter, and Last-Shot Readout

## Goal

Restyle the in-match scoreboard into concept-like YOU/RIVAL panels with a serving dot, rally counter, and last-shot readout without changing scoring or shot classification behavior.

## Build Spec Coverage

Phase 5.2F - Scoreboard, Rally Counter, and Last-Shot Readout:

- YOU/RIVAL labels.
- Serving-side indicator dot.
- RALLY counter.
- LAST SHOT readout.

## Suggested File Ownership

- `dink_rivals/lib/game/components/score_component.dart`
- `dink_rivals/lib/game/dink_rivals_game.dart` only for read-only last-shot/rally state exposure if needed
- `dink_rivals/lib/game/config/visual_palette.dart` token usage only
- `dink_rivals/test/score_component_test.dart`
- `docs/art/phase-5.2/phase-5.2-scoreboard.png`
- `tickets/status.md`

Coordinate with P52H before changing feedback state names or top-band layout.

## Requirements

- Render concept-like blue/red panels with YOU/RIVAL labels and clear numerals.
- Move the serving indicator into the active score panel.
- Add top-left rally and last-shot labels fed from existing rally count and shot classification state.
- Use read-only state where possible; do not mutate scoring, rules, or shot outcomes.
- Respect SafeArea and leave room for pause and the P52H top-center feedback banner.
- Add tests for serving indicator side, rally display, and last-shot display where practical.

## Non-Goals

- No new scoring rules.
- No match-flow changes.
- No feedback banner implementation; P52H owns that.
- No control or power-meter work.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Scoreboard reads closer to concept and remains notch-safe.
- Serving indicator is clearly associated with the active side.
- Rally and last-shot text update correctly without changing game logic.
- No score/rule tests regress.

## Planning Notes

- Subagents recommended serializing P52G/P52H because both compete for upper HUD space and may touch feedback state.

## Implementation Notes

- Implemented: scoreboard now has YOU/RIVAL panels, serving dot, rally counter, and last-shot readout with tests.
- Verification: `flutter analyze`, `flutter test`, `flutter build apk --debug`, emulator install/launch on `emulator-5554`, and `docs/art/phase-5.2/phase-5.2-gameplay-emulator-smoke.png`.
