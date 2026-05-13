# VO2 Character Opponent Prompt Packet

Inherits from `vo2-shared-style-rules.md`.

## Purpose

Generate the on-court opponent sprite family as a distinct rival to the player while sharing the same v2 style lock.

## Target Output

- Asset type: transparent PNG sprite sheets.
- Frame size: 48x72 px per frame.
- Foot pivot: y=70 with 2 px foot padding.
- Background: transparent, or flat chroma-key only for source sheets before normalization.
- Orientation: 3/4 mobile court view, opponent facing generally down-court.
- Required states and frame counts:
  - idle: 2
  - ready: 3
  - run: 6
  - dink: 2
  - drive: 3
  - lob: 3
  - smash: 3
  - miss: 2
  - hitConfirm: 2
  - pointWin: 3
  - pointLoss: 2

## Character Identity

Red cap or red upper kit, dark shorts, white shoes, visible dark paddle, confident rival posture. The silhouette must differ from the player through cap brim angle, shirt color block, stance, and swing shapes while keeping the same proportions and pixel density.

## Palette Pulls

Use `opponentPrimary` #FF5F5F and `scoreboardOpponent` #A83E3E for red identity, `courtLineWhite` #F4F7E8 for light clothing/shoe accents, `courtApronNavy` #163B57 for shorts/shadows, `playerSkin` #E3A06C for skin, `uiBackground` #10151B and `projectedShadow` #061211 for outlines. Paddle should be dark navy with a small red or cream edge accent.

## Generation Prompt

Create a cohesive hard-edge pixel-art mobile arcade pickleball opponent sprite sheet, transparent-background-ready, 48x72 px per frame. The character is a stylized rival athlete wearing a red cap or red athletic top, dark shorts, white shoes, and holding a dark pickleball paddle. Use the same 3/4 portrait court perspective and upper-left lighting as the player packet, but face the opponent down-court. Keep one consistent body, face block, cap shape, proportions, outfit, paddle size, outline weight, and lighting across every state.

Make the opponent visually distinct from the player: stronger red identity, slightly different ready stance, different cap brim silhouette, and more assertive shot poses. Arrange frames by state with generous padding, no labels, no text, no baked ground shadow, and no overlap between frames.

## Normalization Notes

- Normalize every frame to 48x72.
- Keep feet on y=70.
- Horizontal pivot should stay within +/-1 px for idle, ready, shot, hitConfirm, pointWin, and pointLoss states.
- Run may shift limbs, but torso center should remain stable within +/-2 px.

## Reject If

Reject if it violates `vo2-shared-style-rules.md`, looks like a recolored player without silhouette differences, changes outfit between states, hides the paddle, uses soft illustrated antialiasing, adds a baked ground shadow, changes camera angle, or becomes unreadable at phone gameplay scale.
