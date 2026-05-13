# VO2 Environment Layers Prompt Packet

Inherits from `vo2-shared-style-rules.md`.

## Purpose

Generate the classic court as separate aligned bitmap layers while preserving the existing 3/4 projection and 941x1672 source canvas.

## Target Output

Create four aligned PNG layers, each exactly 941x1672 px:

- `layer_sky_trees.png`: sky and far tree canopy only; transparent below the tree/fence transition where possible.
- `layer_fence_signage.png`: chain-link fence, main banner zone, secondary sign zone, benches, lamps, bags, planters; transparent outside the venue band where possible.
- `layer_court_base.png`: apron, court paint, kitchen, service boxes, white lines, subtle texture, court-edge shadows. This is the projection anchor.
- `layer_net.png`: net posts, rail, mesh, net shadow accents, transparent everywhere else.

## Composition

Use the depth bands from `visual-overhaul-v2-decomp.md`:

- sky/trees: top 0-13%
- fence/signage: 13-26%
- far apron/opponent staging: 26-36%
- court playfield: 36-74%
- near apron/player staging: 74-83%
- control quiet zone: 83-100%

The generated court must keep the same visual court footprint and net placement as the v1 environment. Do not invent a new camera angle, new court trapezoid, or new baseline position.

## Palette Pulls

Court: `courtSurface` #2B76AA, `courtSurfaceShade` #225E90, `courtPlayingLight` #3894C9, `courtLineWhite` #F4F7E8.

Venue: `environmentTreeLineBack` #0C1B12, `environmentTreeLineMid` #284523, `environmentGround` #4F6241, `environmentSignPanel` #102946, `environmentFenceRail` family, `courtApronNavy` #163B57.

Accents: `uiAccent` #FFCB47, `opponentPrimary` #FF5F5F, `feedbackSmash` #FF6A3D only on signage and tiny props.

## Generation Prompt

Create a polished hard-edge pixel-art arcade pickleball park venue for a mobile portrait game, using a 3/4 court perspective on a 941x1672 canvas. The scene has a deep blue pickleball court with cream white lines, muted green apron and park paving, chain-link fence, dark tree canopy, benches, lamps, planters, backpack, a centered main banner zone, and a right-side secondary sign zone. Lighting comes from upper-left with grounded lower-right shadows. Keep the court readable and avoid noise in the bottom control zone.

Generate as aligned layer assets, not a single flattened illustration. Every layer must line up perfectly when stacked. Keep the court trapezoid, baselines, service boxes, kitchen, and net position stable. Use chunky pixel forms, restrained detail, crisp hard edges, and the locked palette.

## Layer-Specific Notes

- Sky/trees: dark green canopy behind HUD, no high-contrast leaves behind white text.
- Fence/signage: fence mesh lower contrast than signs; signs sit behind far baseline.
- Court base: line wear is subtle but lines remain brighter than texture.
- Net: rail is cream, posts dark, mesh visible but not noisy. Use transparent pixels outside the net.

## Reject If

Reject if it violates `vo2-shared-style-rules.md`, changes perspective, shifts court geometry, bakes HUD or players into the environment, makes court lines low contrast, creates unreadable generated text, or produces layers that cannot stack cleanly.
