---
id: P52F-001
phase: 5.2E
status: todo
priority: high
parallel_group: E
depends_on: [P52A-002, P51C-001]
blocks: [P52M-001]
owner: unassigned
last_updated: 2026-05-11
---

# P52F-001 - Character Identity Sprite Upgrade

## Goal

Upgrade gameplay sprites and matching roster portraits so characters read closer to the concept sheet at gameplay scale while preserving the separate `RacketComponent` and all hitbox behavior.

## Build Spec Coverage

Phase 5.2E - Character Identity Upgrade:

- Visible head/cap/outfit/hand cues.
- Rookie/Rally Queen/Veteran/Showman color identity.
- Matching roster portrait readability.
- No gameplay paddle baked into sprites.

## Suggested File Ownership

- `dink_rivals/assets/images/sprites/`
- `dink_rivals/assets/images/portraits/`
- `dink_rivals/lib/game/components/player_component.dart`
- `dink_rivals/lib/game/components/opponent_component.dart`
- `dink_rivals/lib/game/config/character_visuals.dart`
- `dink_rivals/test/player_component_test.dart`
- `dink_rivals/test/character_visuals_test.dart`
- `docs/art/phase-5.2-character-contact-sheet.png`
- `tickets/status.md`

Do not edit movement, hitboxes, racket reach, shot timing, physics, scoring, AI, or rules.

## Requirements

- Use P52A-002 prompt/export rules and palette ramps.
- Regenerate or refine cohesive gameplay sprite sheets with stable foot baselines and consistent outline weight.
- Add readable character identity at gameplay size:
  - head/cap/hair or face cue
  - torso/outfit color
  - shorts/legs/shoes
  - hand/paddle cue only
- Keep the swinging gameplay paddle in `RacketComponent`; do not bake the functional paddle into character sprites.
- Update roster portraits only as needed to match upgraded gameplay identity and close P5H-004/P5H-005.
- Run alpha-fringe and black-matte checks comparable to P51B.
- Produce a contact sheet comparing gameplay sprites and portraits.

## Non-Goals

- No new roster members.
- No character stats, unlocks, monetization, or tournament work.
- No animation-state-machine rewrite unless required for visual consistency.
- No gameplay paddle/hitbox changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Characters are recognizable at gameplay distance and match roster identity.
- No black halos, matte artifacts, or inconsistent baselines return.
- Roster portraits and gameplay sprites feel from the same art pass.
- Paddle/contact visualization remains controlled by `RacketComponent`.

## Planning Notes

- This ticket absorbs P5H-004 and P5H-005. Claude and subagents called paddle ambiguity a high-risk implementation trap.
