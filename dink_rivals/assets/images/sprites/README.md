Generated character sprite notes
================================

The player and opponent sheets are normalized from the generated character atlas
archived at:

- `docs/art/visual-overhaul/contact-sheets/character-sprite-generated-atlas.png`
- `docs/art/visual-overhaul/contact-sheets/character-sprite-normalized-runtime-sheet.png`
- `docs/art/visual-overhaul/contact-sheets/character-sprite-mid-detail-runtime-sheet.png`
- `docs/art/visual-overhaul/contact-sheets/character-sprite-simple-mid-atlas.png`
- `docs/art/visual-overhaul/contact-sheets/character-sprite-simple-mid-runtime-sheet.png`
- `docs/art/visual-overhaul/prompts/character-sprite-generated-atlas.md`

Runtime sheets keep the existing 32x48 frame footprint and feet-on-bottom-row
anchor so the Flame renderer can use the same court-position logic. Dink, drive,
lob, and smash each have their own generated sheet instead of reusing a generic
swing sheet. The checked-in runtime sheets use the simple-mid generated atlas:
chunkier silhouettes, fewer colors, and less clothing/facial detail than the
first generated pass while still reading cleaner than the original placeholders.
These assets are visual only and do not change hitboxes, movement, or shot
timing.
