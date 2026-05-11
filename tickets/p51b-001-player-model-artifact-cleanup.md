---
id: P51B-001
phase: 5.1B
status: done
priority: high
parallel_group: B
depends_on: [P51A-001, P5D-002]
blocks: [P51C-001, P51I-001]
owner: unassigned
last_updated: 2026-05-11
---

# P51B-001 - Player Model Artifact Cleanup

## Goal

Remove unintended black artifacts, matte halos, and shadow blobs around the player and opponent models while preserving gameplay readability and hit detection.

## Build Spec Coverage

Phase 5.1B - Player Sprite Artifact Cleanup:

- Cleaner player/opponent silhouettes.
- Consistent alpha handling and outline treatment.
- No accidental black matte artifacts around models.

## Suggested File Ownership

- `dink_rivals/assets/images/sprites/`
- `dink_rivals/lib/game/components/player_component.dart`
- `dink_rivals/lib/game/components/opponent_component.dart`
- `dink_rivals/lib/game/components/racket_component.dart` if paddle artifacts are involved
- `dink_rivals/lib/game/util/projected_shadow.dart` only if the artifact is shadow-related
- `dink_rivals/test/player_component_test.dart`
- `docs/art/phase-5.1-delta-inventory.md` (reference only)
- `tickets/status.md`

Do not edit movement, racket hitbox, shot, physics, scoring, AI, or rules systems.

## Requirements

- Determine whether the black artifacts come from:
  - sprite pixels
  - sprite alpha premultiplication/fringe
  - paddle placement
  - projected/contact shadow rendering
  - scaling/filtering
- Clean player and opponent silhouettes at near and far court scale.
- Keep paddle/racket hands readable.
- Preserve current foot baseline and component priority behavior.
- Add or update tests for state selection or helper behavior where practical.
- Document the root cause and cleanup approach in the ticket notes.

## Non-Goals

- No movement speed, hitbox, racket reach, swing timing, shot logic, character stats, or unlock changes.
- No new character designs beyond artifact cleanup.
- No roster portrait work unless a sprite artifact source is shared.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

If an Android device is available, install and capture a player/opponent close-read screenshot.

## Acceptance Criteria

- Black side blobs/artifacts around both characters are gone or clearly intentional paddles/shadows.
- No visible matte fringe around transparent sprite edges at gameplay scale.
- Paddle, racket hand, head, torso, legs, and feet remain readable.
- Ball/racket contact moment remains visible.
- No gameplay tests regress.

## Planning Notes

- This ticket should run before broader pose readability work so later sprite changes do not preserve a bad alpha/shadow pipeline.
