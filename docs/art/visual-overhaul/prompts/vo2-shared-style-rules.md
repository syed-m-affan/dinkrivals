# VO2 Shared Style Rules

All v2 prompt packets inherit from this file. A generated candidate that breaks these rules should return to generation before integration.

## Style Lock

- Medium: polished hard-edge pixel-art arcade sports, built for Flutter/Flame mobile gameplay.
- Perspective: fixed 3/4 portrait mobile court view. No isometric tile angle, side view, top-down flat board, or realistic camera lens.
- Pixel density: 1 source pixel should read close to 1 screen pixel at near-baseline gameplay scale. Use chunky forms and avoid details that only read when zoomed.
- Edges: crisp nearest-neighbor pixel edges. Runtime sprites and cutouts need transparent PNG-ready edges.
- Outline: 1 px dark hard outline at source scale. Use selective 2 px outer silhouette weight only where phone readability needs it.
- Lighting: upper-left key light, lower-right grounded shadows.
- Originality: no real brands, celebrity likenesses, trademarked uniforms, copied logos, watermarks, or image-search-derived production art.

## Locked Palette Card

Use this palette unless a packet explicitly narrows it. For generation, treat alpha colors from `VisualPalette` as opaque visual intentions and keep final art inside these hue/value families.

| Use | VisualPalette token | Hex |
|---|---|---|
| Court blue | `courtSurface` | #2B76AA |
| Court shade | `courtSurfaceShade` | #225E90 |
| Court highlight | `courtPlayingLight` | #3894C9 |
| Court/apron navy | `courtApronNavy` | #163B57 |
| Cream line/text | `courtLineWhite` | #F4F7E8 |
| Deep UI/navy | `uiBackground` | #10151B |
| Venue sign navy | `environmentSignPanel` | #102946 |
| Dark tree back | `environmentTreeLineBack` | #0C1B12 |
| Tree mid green | `environmentTreeLineMid` | #284523 |
| Ground green | `environmentGround` | #4F6241 |
| Player blue | `playerPrimary` | #3C86FF |
| Opponent red | `opponentPrimary` | #FF5F5F |
| Ball yellow | `ballPrimary` | #FFE24A |
| Warm accent | `uiAccent` | #FFCB47 |
| Skin | `playerSkin` | #E3A06C |
| Shadow | `projectedShadow` | #061211 |

Allowed support ramps: lighter cream highlights from `netRailHighlight` #FFFFFF, warm orange from `feedbackSmash` #FF6A3D, teal feedback from `feedbackDink` #77E6C6, and soft blue from `feedbackLob` #8FC7FF. Use them sparingly.

## Line and Shape Rules

- Characters: 1 px dark outline, blocky cap/head/torso/legs/shoes separation, minimal face detail, no soft hair strands.
- Environment: hard painted pixel clusters, larger value blocks, no single-pixel grass noise in gameplay areas.
- HUD: chunky 2-3 px plaque borders in final runtime scale, inner highlight on top-left edges, dark lower-right shadow.
- VFX: short-lived, high-contrast, small. It should explain contact direction without covering ball, paddle, score, or court lines.

## Transparency and Export Rules

- Sprites, VFX, props, signs, plaques, and portraits that need cutouts must be transparent PNG-ready.
- No matte color halos, black fringes, premultiplied-alpha haze, or semi-transparent dirty edges.
- Chroma-key sheets may use a flat key only if the packet asks for it; the key color must not appear in the art.
- Runtime sheets must have even cell spacing and enough padding for clean crop/normalization.

## Reject If

- Painterly shading, watercolor, oil-paint texture, 3D render, vector-flat icon style, or soft antialias haze.
- Unlisted dominant palette colors or a different lighting direction.
- Isometric mismatch, flat top-down mismatch, side-view mismatch, or changed camera angle.
- Fake/malformed text on assets where text must be legible.
- Black halos, transparent fringes, muddy alpha, glow clouds, or blur.
- Real logos, copied marks, celebrity likenesses, or trademarked apparel.
- Details only read in a zoomed contact sheet and disappear in a phone gameplay screenshot.
