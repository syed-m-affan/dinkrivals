# Perspective Metrics

Date: 2026-05-11

This records the current linear projection before the next camera tuning pass.
It is paired with:

- `docs/art/visual-overhaul/evidence/perspective-before-menu.png`
- `docs/art/visual-overhaul/evidence/perspective-before-serve.png`

## Current Constants

- `CourtProjection.yCompression`: `0.66`
- `CourtProjection.farWidthScale`: `0.50`
- `CourtProjection.nearWidthScale`: `1.18`
- `CourtProjection.zDisplacement`: `1.10`

## Projected Court-Space Metrics

- Far baseline width: `110.0`
- Net width: `184.8`
- Near baseline width: `259.6`
- Projected court height: `316.8`
- Near/far baseline width ratio: `2.36`
- Opponent start depth scale at `y=80`: `0.78`
- Player start depth scale at `y=400`: `1.02`

## First Safe Tuning Window

Use only a small linear adjustment for the first camera pass:

- Reduce `yCompression` slightly.
- Reduce `farWidthScale` slightly.
- Increase `nearWidthScale` only a little, if needed.
- Keep `depthScaleForY` close to current values.

Do not change physics, hitboxes, controls, serve flow, draw priority direction,
or shot logic as part of this projection pass.
