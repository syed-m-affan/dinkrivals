Generated character sprite notes
================================

The player and opponent sheets are normalized from the generated character atlas
archived at:

- `docs/art/visual-overhaul/contact-sheets/character-sprite-generated-atlas.png`
- `docs/art/visual-overhaul/contact-sheets/character-sprite-normalized-runtime-sheet.png`
- `docs/art/visual-overhaul/contact-sheets/character-sprite-mid-detail-runtime-sheet.png`
- `docs/art/visual-overhaul/prompts/character-sprite-generated-atlas.md`

Runtime sheets keep the existing 32x48 frame footprint and feet-on-bottom-row
anchor so the Flame renderer can use the same court-position logic. Dink, drive,
lob, and smash each have their own generated sheet instead of reusing a generic
swing sheet. The checked-in runtime sheets are simplified from the detailed
generated atlas into a mid-detail style so they sit between the original local
placeholders and the higher-detail generated output. These assets are visual
only and do not change hitboxes, movement, or shot timing.
