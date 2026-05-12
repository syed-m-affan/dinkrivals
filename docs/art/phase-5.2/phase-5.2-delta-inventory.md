# Phase 5.2 Delta Inventory

Date: 2026-05-11

## References

- Concept target: `docs/art/concepts/concept-screenshot.png`
- Product concept sheet: `docs/art/concepts/concept-sheet.png`
- Phase 5.1 baseline: `docs/art/phase-5.1/phase-5.1-final-screenshot.png`
- Additional Phase 5.1 captures: `docs/art/phase-5.1/phase-5.1-final-rally.png`, `docs/art/phase-5.1/phase-5.1-final-serve.png`, `docs/art/phase-5.1/phase-5.1-final-pause.png`

## Prior Gate Handling

`P51I-001` remains in `review` because the full physical-device five-minute smoke was not completed. Phase 5.2 accepts the existing Phase 5.1 screenshot/build evidence as enough to begin implementation, and absorbs final visual smoke into `P52M-001`. If physical Android validation is still unavailable at closeout, `P52M-001` must stay in `review`.

Open visual follow-ups are handled as follows:

- `P5H-003`: absorbed by Phase 5.2 comparison/closeout for menu composition.
- `P5H-004` and `P5H-005`: absorbed by `P52F-001`.
- `P5H-006`: absorbed by `P52K-001`.
- `P5H-007`: deferred unless character-sheet work can include a low-risk idle/readability improvement.

## Numbered Deltas

1. **Projection and framing:** The Phase 5.1 court still reads more vertical/top-down than the concept. Target: stronger near-baseline width, clearer far-court compression, and a court shape that feels tilted toward the player without hiding kitchens.
2. **Court zoning:** The baseline court is mostly one blue field. Target: a darker apron/frame, brighter service courts, a distinct but readable kitchen tint, and high-contrast white lines.
3. **Net presentation:** The baseline net is readable but still close to a flat band. Target: stronger posts, rail thickness, mesh cadence, and one coherent cast shadow.
4. **Serving indicator:** The current indicator visually competes with the net/center line. Target: move serving state into the score panel.
5. **Backdrop signage:** Baseline has trees/fence but no strong Dink Rivals banner or secondary sign. Target: rear-fence signage that echoes the concept without copied text.
6. **Character identity:** Baseline sprites are cleaner than Phase 5, but still simple block bodies at gameplay scale. Target: clearer cap/head/outfit/hand cue and matching portrait accents without changing `RacketComponent`.
7. **Scoreboard identity:** Baseline panels show scores but not the concept's labeled YOU/RIVAL hierarchy. Target: labeled panels, serving dot, rally count, and last-shot readout.
8. **Feedback callout:** Baseline feedback does not read like the concept's top-center callout. Target: banner below the top HUD row, clear shot/fault/point text, no mid-court rally number.
9. **Ball trail and impact juice:** Baseline VFX is brief and subtle. Target: short arcing trail plus stronger contact/bounce effects while keeping the ball dominant.
10. **Serve meter and controls:** Baseline controls are usable but lack concept chevrons and clear serve-charge readout. Target: serve charge meter, D-pad chevrons, refined swing/aim presentation, unchanged hit regions. Do not restore the rejected swing power meter.
11. **Park depth:** Baseline has a richer park than earlier phases but still lacks the concept's dense courtside dressing. Target: darker rear tree band plus lamp/bench/planter accents at lower contrast than gameplay objects.
12. **Menu/end-match carry-through:** Baseline non-game screens are styled, but Phase 5.2 should check the new HUD/signage language does not make menu/end-match feel unrelated. Target: comparison notes only unless small style alignment is needed.

## Required Final Evidence

`P52M-001` should capture:

- `docs/art/phase-5.2/phase-5.2-final-serve.png`
- `docs/art/phase-5.2/phase-5.2-final-rally.png`
- `docs/art/phase-5.2/phase-5.2-final-feedback.png`
- `docs/art/phase-5.2/phase-5.2-final-pause.png`
- `docs/art/phase-5.2/phase-5.2-final-endmatch.png`
- `docs/art/phase-5.2/phase-5.2-final-menu.png`
- `docs/art/phase-5.2/phase-5.2-comparison.md`
