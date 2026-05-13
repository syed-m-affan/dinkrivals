# VO2 Character Player Prompt Packet

Inherits from `vo2-shared-style-rules.md`.

## Purpose

Generate the on-court player sprite family for the v2 48x72 runtime footprint.

## Target Output

- Asset type: transparent PNG sprite sheets.
- Frame size: 48x72 px per frame.
- Foot pivot: y=70 with 2 px foot padding.
- Background: transparent, or flat chroma-key only for source sheets before normalization.
- Orientation: 3/4 mobile court view, player facing generally up-court.
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

Blue cap, white shirt with red trim, navy shorts, white shoes, visible dark paddle in right hand. Stylized athlete, not a mascot. Cap brim, head/face block, torso, shorts, legs, shoes, and paddle must all read at gameplay scale.

## Palette Pulls

Use `playerPrimary` #3C86FF for cap/blue identity, `courtLineWhite` #F4F7E8 for shirt and shoe highlights, `opponentPrimary` #FF5F5F only as small shirt trim, `courtApronNavy` #163B57 for shorts/shadows, `playerSkin` #E3A06C for skin, `uiBackground` #10151B and `projectedShadow` #061211 for outlines. Paddle should be dark navy/black with small cream highlight.

## Generation Prompt

Create a cohesive hard-edge pixel-art mobile arcade pickleball player sprite sheet, transparent-background-ready, 48x72 px per frame. The character is a stylized athlete wearing a blue cap, white shirt with red trim, navy shorts, white shoes, and holding a dark pickleball paddle in the right hand. Use a fixed 3/4 portrait court perspective with the character facing up-court. Keep one consistent body, face block, cap shape, proportions, outfit, paddle size, outline weight, and upper-left lighting across every state. Make the poses athletic and readable: compact ready stance, small soft dink, horizontal drive swing, upward lob scoop, overhead smash, clear miss, hit confirmation, point win, and point loss.

Arrange frames by state with generous padding, no labels, no text, no shadows baked into the transparent cutout, and no overlap between frames. Keep feet aligned to the same baseline except during run frames, where foot motion may alternate but the pivot must remain stable.

## Normalization Notes

- Normalize every frame to 48x72.
- Keep feet on y=70.
- Horizontal pivot should stay within +/-1 px for idle, ready, shot, hitConfirm, pointWin, and pointLoss states.
- Run may shift limbs, but torso center should remain stable within +/-2 px.

## Reject If

Reject if it violates `vo2-shared-style-rules.md`, changes the outfit between states, hides the paddle, uses soft illustrated antialiasing, adds a baked ground shadow, produces malformed anatomy, changes camera angle, or makes the cap/torso/paddle unreadable at phone gameplay scale.
