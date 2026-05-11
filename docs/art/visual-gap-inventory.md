# Phase 5 Visual Gap Inventory

Last updated: 2026-05-11

## References

- Current Phase 5 baseline: `docs/art/phase-5-current-serve.png`
- Concept target: `docs/art/concept-screenshot.png`
- Concept sheet: `docs/art/concept-sheet.png`
- Earlier perspective reference: `docs/art/p0-006-p0-007-perspective-screenshot.png`

## Capture Notes

`phase-5-current-serve.png` was copied from the latest local Phase 5 gameplay screenshot (`phase5_current.png`). Dedicated rally and point-feedback captures are still pending because those require either manual play or a deterministic screenshot harness. Later QA tickets should replace this single baseline with state-specific captures.

## Environment Gaps

- Current game still reads as a court on a dark void rather than a park court.
- Concept art has trees, fence, benches, lamps, signs, banners, and ground transitions around the playable court.
- Environment must stay lower contrast than the court; it should frame play rather than compete with ball or lines.
- Decorative props need explicit no-overlap rules for controls, scoreboard, feedback, and the active court.

## Court, Net, and Shadow Gaps

- Court surface is serviceable but still simple; concept target has subtle material texture, scuffs, and line wear.
- Kitchen zones are visible but not yet integrated into a polished court material.
- Net is readable but needs stronger post/rail/mesh identity and a cast shadow.
- Shadows are currently functional; concept target needs more coherent directional shadows for players, ball, paddles, props, and net.

## Character Gaps

- Current sprites establish silhouettes but are not yet characterful.
- Rookie, Rally Queen, Veteran, and Showman need distinct visual definitions before adding more variants.
- Gameplay sprites and roster portraits should share colors, silhouette language, and paddle styling.
- Animation lacks ready, hit-confirm, win, and loss poses.

## VFX Gaps

- Ball contact, bounce, lob arc, smash impact, and point outcome are mostly text/audio feedback.
- Concept target suggests short arcade juice: ball trails, hit sparks, bounce rings, and point bursts.
- Effects must be brief and must not hide the ball, shadow, court lines, or paddle contact.

## HUD and Screen Gaps

- Phase 5 scoreboard and feedback are functional but simpler than the concept's chunky arcade panels.
- Main menu, roster, settings, pause, and end-match screens need shared panel/button primitives.
- UI must remain SafeArea-aware and preserve the one-tap Quick Match path.
- Court cards can be prepared as assets, but should not introduce court selection, unlocks, or monetization.

## Readability Risks

- Blue/green court and environment colors can merge if contrast is not controlled.
- High-saturation green props near court edges can erase player and ball separation.
- Net mesh can hide the ball near contact if drawn too dark or too dense.
- Large VFX can obscure hit timing.
- Ball trails and point bursts can make ball direction ambiguous if they persist too long.
- Foreground props can break in/out readability if they cover baselines or sidelines.
- Busy foliage or ground texture behind translucent controls can reduce touch-control legibility.
- Rich HUD treatment can crowd the notch area on tall Android phones.
- Top banners, fence signs, far-player silhouette, score, pause, and feedback all compete in the upper third.
