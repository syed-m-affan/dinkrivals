# Phase 5.2 Art Direction

Date: 2026-05-11

## Palette and Tokens

Use `VisualPalette` for all Phase 5.2 colors. New runtime colors must be added as named tokens before use. Avoid inline color literals in components except short-lived alpha modulation of an existing token.

Core additions:

- court apron and kitchen-zone accents
- signage panel, sign border, and sign lettering
- feedback banner fill and border
- rally/last-shot text
- power meter fill, empty, and lightning accent
- deeper rear park/fence accents

## Layering

Back-to-front ordering:

1. ground gradient and rear tree band
2. rear fence and signage
3. court apron/contact shadow
4. court surface, kitchen, and lines
5. net cast shadow
6. characters, paddles, ball, ball shadow, and VFX
7. net posts/rail/mesh
8. scoreboard, pause, feedback banner, controls, and power meter

The top HUD row owns the upper safe area. The feedback banner sits below the scoreboard/pause row. Bottom controls and the power meter must stay inside the reduced Flame canvas and must not alter touch hit regions.

## AI Asset Rules

AI-assisted assets are allowed for Phase 5.2 when they are original and constrained:

- hard-edge retro sports game style
- transparent PNG for sprites/props that need alpha
- no black matte halos or premultiplied-alpha fringe
- consistent 2-3 px dark outline at source scale for character sprites
- consistent upper-left light, lower-right shadow direction
- no trademarked or copied sign text
- no image-search-derived production art
- preserve existing source dimensions unless the consuming component is updated and tested

Every generated or replaced asset should have a contact sheet or screenshot proof in `docs/art/` when practical.

## Prompt Packets

Character prompt seed:

> Hard-edge retro pixel-art pickleball character, mobile game sprite sheet, transparent background, chunky readable cap/head/torso/shorts/shoes, simple hand cue, no full gameplay paddle baked into sprite, consistent black outline, same foot baseline across frames.

Signage prompt seed:

> Original retro park-court banner sign for a fictional pickleball game, text reads DINK RIVALS or PARK COURTS, dark navy canvas, cream and orange lettering, hard-edge pixel-art, transparent or simple rectangular background, no trademarked logos.

VFX prompt seed:

> Small retro arcade pickleball impact effect, transparent background, short-lived bright shape, yellow-green trail or cream dust, minimal opacity, must not obscure ball.

Environment prompt seed:

> Low-contrast retro park court prop, lamp/bench/planter/tree-band, hard-edge pixel art, muted greens and browns, transparent background, readable at small mobile scale.
