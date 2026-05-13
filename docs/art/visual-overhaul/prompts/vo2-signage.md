# VO2 Signage Prompt Packet

Inherits from `vo2-shared-style-rules.md`.

## Purpose

Generate or refine branded venue signs that make the court read as an arcade pickleball venue.

## Target Output

- Main banner: transparent PNG or layer-ready rectangle, target visual width 38-44% of screen/canvas width.
- Secondary sign: transparent PNG or layer-ready rectangle, target visual width 23-28% of screen/canvas width.
- Optional sign icons: simple original pickleball dot, shield, trophy, or paddle mark.
- Text must be manually legible: `DINK RIVALS` and `PICKLEBALL LEGENDS`.

## Placement

- Main banner centered in the fence band behind the far baseline.
- Secondary sign on the right fence, aligned with benches/lamps and below HUD.
- Do not place text where the top-left score, top-center feedback plaque, or pause button covers it.

## Palette Pulls

Use `environmentSignPanel` #102946 for main navy canvas, `courtLineWhite` #F4F7E8 for cream letters and border, `feedbackSmash` #FF6A3D or `opponentPrimary` #FF5F5F for `RIVALS`, `uiAccent` #FFCB47 for small icon highlights, and `uiBackground` #10151B for outline/shadow.

## Generation Prompt

Create original hard-edge pixel-art arcade pickleball venue signage for a fictional mobile game. Make a dark navy fabric banner with large blocky text reading `DINK RIVALS`, cream `DINK`, warm red-orange `RIVALS`, and a small original pickleball icon. Also make a smaller framed right-side sign reading `PICKLEBALL LEGENDS` with a simple original trophy or paddle shield icon. Use crisp pixel edges, upper-left highlights, lower-right shadow, and the locked v2 palette. Keep text straight, bold, and readable at phone gameplay distance.

## Export Rules

- Prefer transparent PNG cutouts if signage is integrated as props.
- If embedded in `layer_fence_signage.png`, keep signs on the same perspective plane as the fence.
- Do not include real sponsor marks, real sports logos, or copied typography.

## Reject If

Reject if it violates `vo2-shared-style-rules.md`, contains misspelled or malformed text, uses fake brand marks, looks like a modern vector logo, has soft antialias haze, or overpowers the ball/player read.
