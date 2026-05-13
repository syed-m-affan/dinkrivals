# VO2 Portraits Prompt Packet

Inherits from `vo2-shared-style-rules.md`.

## Purpose

Refresh roster and out-of-match portraits so menu screens match the v2 gameplay sprites.

## Target Output

- Four square transparent or framed PNG portraits:
  - Rookie/player identity
  - Rally Queen
  - Veteran
  - Showman
- Recommended source size: 512x512 px per portrait before runtime resizing.
- Crop: bust or half-body, 3/4 arcade portrait, face and cap/hair readable at roster-card scale.
- Player and opponent portraits must visibly resemble the final VO2 gameplay sprites.

## Character Identity Pulls

- Rookie/player: blue cap, white shirt with red trim, navy support colors.
- Rally Queen: `rallyQueenPrimary` #FF5FA8 and `rallyQueenSecondary` #FFD65A, confident athletic expression.
- Veteran: `veteranPrimary` #526072 and `veteranSecondary` #C7E3D2, older composed athlete read.
- Showman: `showmanPrimary` #FF6A3D and `showmanSecondary` #7CE7FF, expressive arcade athlete read.

Use `courtLineWhite` #F4F7E8, `uiBackground` #10151B, `uiAccent` #FFCB47, and `playerSkin` #E3A06C as shared supports.

## Generation Prompt

Create four cohesive hard-edge pixel-art arcade pickleball roster portraits for a mobile game. Use the same locked v2 palette, 1 px dark outlines, upper-left lighting, and chunky pixel forms as the gameplay sprites. Each portrait is a square 512x512 source image, bust or half-body crop, transparent or simple arcade plaque background. The player portrait has a blue cap, white shirt with red trim, and navy support colors. Rally Queen uses pink and warm yellow. Veteran uses slate and pale green. Showman uses orange and bright cyan. Keep all characters original, readable, athletic, and consistent with the on-court sprite style.

## Export Rules

- Keep silhouettes clean against dark UI panels.
- Avoid tiny facial detail; prioritize headwear, hair/cap shape, clothing color blocks, and expression.
- Use the same border/plaque chrome as `vo2-hud.md` if a framed portrait is requested.

## Reject If

Reject if it violates `vo2-shared-style-rules.md`, diverges from gameplay sprite identities, uses different lighting, becomes painterly/anime-realistic, includes fake logos, or loses readability at roster-card size.
